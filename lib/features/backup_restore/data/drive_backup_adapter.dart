// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';
import 'backup_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider yang mengekspos [DriveBackupService] sebagai [BackupService].
/// Gunakan provider ini setelah OAuth dikonfigurasi di aplikasi.
final driveBackupServiceProvider = Provider<BackupService>(
  (ref) => DriveBackupService(),
);

// ─────────────────────────────────────────────────────────────────────────────
// _GoogleAuthClient — menyuntikkan Bearer token ke setiap HTTP request
// ─────────────────────────────────────────────────────────────────────────────

/// HTTP client yang menambahkan header Authorization (Bearer) dari
/// [authHeaders] milik [GoogleSignInAccount] ke setiap permintaan.
class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  /// Header autentikasi dari [GoogleSignInAccount.authHeaders].
  final Map<String, String> _headers;

  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Tambahkan seluruh header Google Sign-In ke setiap request
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DriveBackupService
// ─────────────────────────────────────────────────────────────────────────────

/// Implementasi [BackupService] yang:
/// 1. Membuat salinan lokal database dalam format .zip.
/// 2. Mengunggah file .zip ke Google Drive (folder "SIAK-ILMI-Backups").
///
/// Semua error cloud ditangkap secara silent — TIDAK PERNAH melempar exception.
class DriveBackupService implements BackupService {
  DriveBackupService()
      : _googleSignIn = GoogleSignIn(
          scopes: [drive.DriveApi.driveFileScope],
        );

  /// Instance Google Sign-In dengan scope Drive File.
  final GoogleSignIn _googleSignIn;

  /// Nama folder tujuan di Google Drive pengguna.
  static const _driveFolderName = 'SIAK-ILMI-Backups';

  // ── BackupService interface ────────────────────────────────────────────────

  @override
  Future<BackupResult> performBackup() async {
    // ── Langkah 1: Buat zip lokal (WAJIB berhasil) ──────────────────────────
    String localPath = '';
    try {
      localPath = await _createLocalZip();
    } catch (e) {
      // Zip lokal gagal — kembalikan error tanpa crash
      return BackupResult(
        localZipPath: '',
        cloudUploaded: false,
        cloudError: 'Gagal membuat backup lokal: $e',
      );
    }

    // ── Langkah 2: Upload ke Google Drive (silent on failure) ───────────────
    try {
      await _uploadToDrive(localPath);
      return BackupResult(
        localZipPath: localPath,
        cloudUploaded: true,
      );
    } catch (e) {
      // Aturan PRD: error cloud TIDAK PERNAH menyebabkan crash atau throw.
      // Path zip lokal tetap dikembalikan agar data tidak hilang.
      return BackupResult(
        localZipPath: localPath,
        cloudUploaded: false,
        cloudError: 'Upload Google Drive gagal: $e',
      );
    }
  }

  @override
  Future<String?> getLocalBackupPath() async {
    final dir = await _backupDirectory();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files.isEmpty ? null : files.first.path;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Mengompres file SQLite database ke dalam arsip .zip di direktori backup.
  /// Melempar [BackupException] jika file database tidak ditemukan.
  Future<String> _createLocalZip() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docsDir.path, 'siak_ilmi.db'));

    if (!dbFile.existsSync()) {
      throw const BackupException('File database tidak ditemukan.');
    }

    final backupDir = await _backupDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);
    final zipPath =
        p.join(backupDir.path, 'SIAK_ILMI_Backup_$timestamp.zip');

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    encoder.addFile(dbFile);
    encoder.close();

    return zipPath;
  }

  /// Mengunggah [zipPath] ke Google Drive.
  /// Membuat folder "SIAK-ILMI-Backups" jika belum ada.
  /// Lempar exception jika sign-in gagal atau upload gagal —
  /// [performBackup] yang akan menangkap dan menjadikannya [cloudError].
  Future<void> _uploadToDrive(String zipPath) async {
    // ── Sign-in: coba silent dulu, prompt jika diperlukan ──────────────────
    GoogleSignInAccount? account = await _googleSignIn.signInSilently();
    account ??= await _googleSignIn.signIn();

    if (account == null) {
      throw Exception('Pengguna membatalkan proses masuk Google.');
    }

    final authHeaders = await account.authHeaders;
    final httpClient = _GoogleAuthClient(authHeaders);

    try {
      final driveApi = drive.DriveApi(httpClient);

      // ── Cari atau buat folder tujuan di Drive ───────────────────────────
      final folderId =
          await _getOrCreateDriveFolder(driveApi, _driveFolderName);

      // ── Siapkan metadata file ────────────────────────────────────────────
      final fileName =
          'siak_ilmi_backup_${p.basenameWithoutExtension(zipPath)}.zip';
      final fileMetadata = drive.File()
        ..name = fileName
        ..mimeType = 'application/zip'
        ..parents = [folderId];

      // ── Unggah file sebagai media stream ────────────────────────────────
      final file = File(zipPath);
      final media = drive.Media(
        file.openRead(),
        file.lengthSync(),
        contentType: 'application/zip',
      );

      await driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
      );
    } finally {
      // Pastikan HTTP client ditutup setelah operasi selesai
      httpClient.close();
    }
  }

  /// Mendapatkan direktori backup lokal.
  /// Menggunakan external storage (Downloads) jika tersedia, atau
  /// fallback ke direktori dokumen aplikasi.
  Future<Directory> _backupDirectory() async {
    Directory? dir;
    try {
      final extDirs = await getExternalStorageDirectories();
      if (extDirs != null && extDirs.isNotEmpty) {
        dir = Directory(
          p.join(
            extDirs.first.parent.parent.parent.parent.path,
            'Download',
            'SIAK-ILMI-Backup',
          ),
        );
      }
    } catch (_) {
      // Fallback ke direktori dokumen aplikasi
    }
    dir ??= Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'backups'),
    );

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: _getOrCreateDriveFolder
// ─────────────────────────────────────────────────────────────────────────────

/// Mencari folder bernama [folderName] di Drive root pengguna.
/// Jika belum ada, folder baru dibuat secara otomatis.
/// Mengembalikan Drive file-ID folder yang ditemukan atau dibuat.
Future<String> _getOrCreateDriveFolder(
  drive.DriveApi api,
  String folderName,
) async {
  // Query mencari folder dengan nama yang sesuai yang tidak di-trash
  final query =
      "mimeType='application/vnd.google-apps.folder' "
      "and name='$folderName' "
      "and trashed=false";

  final result = await api.files.list(
    q: query,
    spaces: 'drive',
    $fields: 'files(id, name)',
  );

  final existingFiles = result.files;
  if (existingFiles != null && existingFiles.isNotEmpty) {
    // Folder sudah ada — kembalikan ID-nya
    return existingFiles.first.id!;
  }

  // Folder belum ada — buat folder baru
  final folderMetadata = drive.File()
    ..name = folderName
    ..mimeType = 'application/vnd.google-apps.folder';

  final created = await api.files.create(
    folderMetadata,
    $fields: 'id',
  );

  return created.id!;
}
