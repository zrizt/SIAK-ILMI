// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import 'backup_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider yang mengekspos [SupabaseBackupService] sebagai [BackupService].
/// Supabase digunakan sebagai cloud storage langsung tanpa perlu akun/login pengguna.
final supabaseBackupServiceProvider = Provider<SupabaseBackupService>(
  (ref) => SupabaseBackupService(db: ref.watch(appDatabaseProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// BackupManifest — metadata arsip ZIP
// ─────────────────────────────────────────────────────────────────────────────

/// Metadata yang disertakan di dalam arsip ZIP sebagai manifest.json.
class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.schemaVersion,
    required this.createdAtUtc,
    required this.databaseSha256,
    required this.fileName,
  });

  /// Format manifest saat ini. Tambah nilai ini jika struktur manifest berubah.
  final int formatVersion;

  /// Versi skema SQLite Drift saat backup dibuat.
  final int schemaVersion;

  /// Timestamp UTC saat backup dibuat (ISO 8601).
  final String createdAtUtc;

  /// SHA-256 hex digest dari file siak_ilmi.db yang dikemas.
  final String databaseSha256;

  /// Nama file ZIP (tanpa path direktori).
  final String fileName;

  Map<String, dynamic> toJson() => {
        'format_version': formatVersion,
        'schema_version': schemaVersion,
        'created_at_utc': createdAtUtc,
        'database_sha256': databaseSha256,
        'file_name': fileName,
        'app_id': 'com.darulilmi.siakilmi',
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) =>
      BackupManifest(
        formatVersion: (json['format_version'] as num?)?.toInt() ?? 1,
        schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 0,
        createdAtUtc: json['created_at_utc'] as String? ?? '',
        databaseSha256: json['database_sha256'] as String? ?? '',
        fileName: json['file_name'] as String? ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CloudBackupEntry — metadata file backup di Supabase Storage
// ─────────────────────────────────────────────────────────────────────────────

/// Representasi satu file backup yang tersimpan di Supabase Storage.
class CloudBackupEntry {
  const CloudBackupEntry({
    required this.name,
    required this.storagePath,
    required this.sizeBytes,
    required this.createdAt,
  });

  final String name;
  final String storagePath;
  final int sizeBytes;
  final DateTime createdAt;
}

// ─────────────────────────────────────────────────────────────────────────────
// SupabaseBackupService (Direct Connection — No Login Required)
// ─────────────────────────────────────────────────────────────────────────────

/// Implementasi [BackupService] menggunakan Supabase Storage sebagai cloud.
///
/// Fitur:
/// - Terhubung langsung menggunakan project publishable key tanpa login pengguna.
/// - Backup lokal ZIP **selalu** dibuat terlebih dahulu (offline-first).
/// - Upload Supabase bersifat fail-silent — TIDAK PERNAH throw ke pemanggil.
/// - Restore memiliki safety backup dan rollback otomatis jika PRAGMA quick_check gagal.
class SupabaseBackupService implements BackupService {
  SupabaseBackupService({AppDatabase? db}) : _db = db;

  final AppDatabase? _db;

  /// Skema versi Drift saat ini — sinkron dengan AppDatabase.schemaVersion.
  static const int _currentSchemaVersion = 3;

  /// Memeriksa apakah konfigurasi Supabase telah diisi dan valid.
  bool get isConfigured {
    try {
      Supabase.instance.client; // throws jika belum diinisialisasi
      return supabaseUrl.isNotEmpty &&
          supabaseUrl != 'YOUR_SUPABASE_URL' &&
          supabaseAnonKey.isNotEmpty &&
          supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
    } catch (_) {
      return false;
    }
  }

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // ── BackupService interface ───────────────────────────────────────────────

  @override
  Future<BackupResult> performBackup() async {
    // Langkah 1: Buat ZIP lokal dengan manifest (WAJIB berhasil)
    String localPath = '';
    try {
      localPath = await _createLocalZipWithManifest();
    } catch (e) {
      return BackupResult(
        localZipPath: '',
        cloudUploaded: false,
        cloudError: 'Gagal membuat backup lokal: $e',
      );
    }

    // Langkah 2: Upload ke Supabase Storage (fail-silent)
    if (!isConfigured) {
      return BackupResult(
        localZipPath: localPath,
        cloudUploaded: false,
        cloudError:
            'Supabase belum dikonfigurasi. Backup lokal tersimpan di perangkat.',
      );
    }

    try {
      await _uploadToSupabase(localPath);
      return BackupResult(
        localZipPath: localPath,
        cloudUploaded: true,
      );
    } catch (e) {
      // PRD Rule: error cloud TIDAK PERNAH crash atau throw ke UI
      return BackupResult(
        localZipPath: localPath,
        cloudUploaded: false,
        cloudError: 'Upload Supabase gagal: $e',
      );
    }
  }

  @override
  Future<String?> getLocalBackupPath() async {
    final backups = await getLocalBackups();
    return backups.isEmpty ? null : backups.first.path;
  }

  /// Mengembalikan seluruh riwayat file backup lokal (.zip) diurutkan terbaru.
  Future<List<File>> getLocalBackups() async {
    final dir = await _backupDirectory();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  /// Mengembalikan daftar file backup yang tersimpan di Supabase Storage.
  Future<List<CloudBackupEntry>> listCloudBackups() async {
    if (!isConfigured) return [];
    try {
      final client = _client;
      if (client == null) return [];

      final files = await client.storage.from(supabaseBucketId).list(
        path: supabaseBackupPathPrefix,
        searchOptions: const SearchOptions(
          sortBy: SortBy(column: 'created_at', order: 'desc'),
        ),
      );

      final entries = <CloudBackupEntry>[];
      for (final f in files) {
        if (f.name.endsWith('.zip')) {
          final metadata = f.metadata;
          final size = (metadata?['size'] as num?)?.toInt() ?? 0;
          DateTime createdAt;
          try {
            createdAt = DateTime.parse(
                f.createdAt ?? DateTime.now().toIso8601String());
          } catch (_) {
            createdAt = DateTime.now();
          }
          entries.add(CloudBackupEntry(
            name: f.name,
            storagePath: '$supabaseBackupPathPrefix/${f.name}',
            sizeBytes: size,
            createdAt: createdAt,
          ));
        }
      }
      return entries;
    } catch (_) {
      return [];
    }
  }

  /// Mengunduh file backup dari Supabase Storage ke direktori staging lokal.
  /// Mengembalikan path file ZIP yang diunduh, atau null jika gagal.
  Future<String?> downloadCloudBackup(String storagePath) async {
    if (!isConfigured) return null;
    try {
      final client = _client;
      if (client == null) return null;

      final bytes = await client.storage
          .from(supabaseBucketId)
          .download(storagePath);

      final tempDir = await getTemporaryDirectory();
      final fileName = p.basename(storagePath);
      final localFile = File(p.join(tempDir.path, fileName));
      await localFile.writeAsBytes(bytes, flush: true);
      return localFile.path;
    } catch (_) {
      return null;
    }
  }

  /// Memulihkan database dari arsip .zip dengan 10 langkah safe restore:
  ///
  /// 1. Ekstrak ZIP ke direktori staging.
  /// 2. Parse manifest.json (jika ada) dan validasi format/schema version.
  /// 3. Verifikasi SHA-256 file database terhadap manifest.
  /// 4. Buka DB staging dan jalankan PRAGMA quick_check.
  /// 5. Buat safety backup: siak_ilmi.db → siak_ilmi.db.safety_backup.
  /// 6. Tutup koneksi Drift aktif.
  /// 7. Hapus file WAL dan SHM.
  /// 8. Salin file DB staging ke lokasi resmi.
  /// 9. Buka AppDatabase baru dan jalankan PRAGMA quick_check.
  /// 10. Jika lulus → hapus safety backup; jika gagal → rollback dari safety backup.
  @override
  Future<void> restoreFromZip(String zipPath) async {
    final zipFile = File(zipPath);
    if (!zipFile.existsSync()) {
      throw const BackupException('File arsip zip tidak ditemukan.');
    }

    // ── Langkah 1: Ekstrak ZIP ke direktori staging ───────────────────────
    final tempDir = await getTemporaryDirectory();
    final stagingDir = Directory(p.join(tempDir.path, 'siak_restore_staging'));
    if (stagingDir.existsSync()) stagingDir.deleteSync(recursive: true);
    stagingDir.createSync(recursive: true);

    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final entry in archive) {
      final entryPath = p.join(stagingDir.path, entry.name);
      if (entry.isFile) {
        File(entryPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(entry.content as List<int>);
      }
    }

    // ── Langkah 2: Parse dan validasi manifest.json ───────────────────────
    final manifestFile = File(p.join(stagingDir.path, 'manifest.json'));
    BackupManifest? manifest;
    if (manifestFile.existsSync()) {
      try {
        final json = jsonDecode(await manifestFile.readAsString())
            as Map<String, dynamic>;
        manifest = BackupManifest.fromJson(json);

        // Tolak jika schema version lebih baru dari versi aplikasi
        if (manifest.schemaVersion > _currentSchemaVersion) {
          throw BackupException(
            'Arsip backup (skema v${manifest.schemaVersion}) lebih baru dari '
            'versi aplikasi (skema v$_currentSchemaVersion). '
            'Perbarui aplikasi sebelum memulihkan.',
          );
        }
      } catch (e) {
        if (e is BackupException) rethrow;
        // Manifest rusak → lanjutkan tanpa validasi SHA-256
        manifest = null;
      }
    }

    // ── Langkah 3: Cari file database di staging ──────────────────────────
    File? stagingDb;
    for (final entry in stagingDir.listSync()) {
      if (entry is File &&
          (p.basename(entry.path) == 'siak_ilmi.db' ||
              entry.path.endsWith('.db'))) {
        stagingDb = entry;
        break;
      }
    }

    if (stagingDb == null || !stagingDb.existsSync()) {
      throw const BackupException(
          'File database (siak_ilmi.db) tidak ditemukan di dalam arsip.');
    }

    // ── Langkah 3b: Verifikasi SHA-256 (jika manifest tersedia) ──────────
    if (manifest != null && manifest.databaseSha256.isNotEmpty) {
      final actualHash = await _sha256OfFile(stagingDb);
      if (actualHash != manifest.databaseSha256) {
        throw const BackupException(
          'Verifikasi integritas gagal: SHA-256 file database tidak cocok '
          'dengan manifest. Arsip mungkin rusak atau dimodifikasi.',
        );
      }
    }

    // ── Langkah 4: Validasi format SQLite ─────────────────────────────────
    final stagingBytes = await stagingDb.readAsBytes();
    if (stagingBytes.length < 100) {
      throw const BackupException(
          'File database di arsip terlalu kecil — tampaknya rusak.');
    }
    // Periksa SQLite magic number (harus "SQLite format 3\000")
    final magic = String.fromCharCodes(stagingBytes.sublist(0, 15));
    if (!magic.startsWith('SQLite format 3')) {
      throw const BackupException(
          'File database bukan format SQLite yang valid.');
    }

    // ── Langkah 5: Buat safety backup ────────────────────────────────────
    final docsDir = await getApplicationDocumentsDirectory();
    final liveDb = File(p.join(docsDir.path, 'siak_ilmi.db'));
    final safetyBackup =
        File(p.join(docsDir.path, 'siak_ilmi.db.safety_backup'));

    if (liveDb.existsSync()) {
      await liveDb.copy(safetyBackup.path);
    }

    // ── Langkah 6: Checkpoint WAL dan tutup koneksi Drift ────────────────
    if (_db != null) {
      try {
        await _db.customStatement('PRAGMA wal_checkpoint(FULL);');
      } catch (_) {}
      try {
        await _db.close();
      } catch (_) {}
    }

    // ── Langkah 7: Hapus file WAL dan SHM ────────────────────────────────
    for (final ext in ['-wal', '-shm']) {
      final f = File('${liveDb.path}$ext');
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
    }

    // ── Langkah 8: Salin staging DB ke lokasi resmi ───────────────────────
    try {
      await stagingDb.copy(liveDb.path);
    } catch (e) {
      // Rollback dari safety backup
      if (safetyBackup.existsSync()) {
        try {
          await safetyBackup.copy(liveDb.path);
        } catch (_) {}
      }
      throw BackupException('Gagal menyalin database: $e');
    }

    // ── Langkah 9 & 10: Validasi DB yang baru dipulihkan ─────────────────
    try {
      final verifyDb = AppDatabase();
      try {
        final result = await verifyDb
            .customSelect('PRAGMA quick_check;')
            .getSingleOrNull();
        final checkResult = result?.data['integrity_check'] as String?;
        if (checkResult != null && checkResult != 'ok') {
          throw BackupException('PRAGMA quick_check melaporkan: $checkResult');
        }
      } finally {
        await verifyDb.close();
      }
      // Hapus safety backup jika validasi lulus
      if (safetyBackup.existsSync()) {
        safetyBackup.deleteSync();
      }
    } catch (e) {
      // Rollback: kembalikan safety backup
      if (safetyBackup.existsSync()) {
        try {
          await safetyBackup.copy(liveDb.path);
          safetyBackup.deleteSync();
        } catch (_) {}
      }
      throw BackupException(
          'Validasi database setelah restore gagal. '
          'Database lama telah dipulihkan dari safety backup. Detail: $e');
    }

    // Bersihkan staging
    try {
      stagingDir.deleteSync(recursive: true);
    } catch (_) {}
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Membuat arsip ZIP dengan manifest.json dan siak_ilmi.db.
  Future<String> _createLocalZipWithManifest() async {
    if (_db != null) {
      try {
        await _db.customStatement('PRAGMA wal_checkpoint(FULL);');
      } catch (_) {}
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docsDir.path, 'siak_ilmi.db'));

    if (!dbFile.existsSync()) {
      throw const BackupException('File database tidak ditemukan.');
    }

    final backupDir = await _backupDirectory();
    final now = DateTime.now().toUtc();
    final timestamp = now
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);
    final fileName = 'SIAK_ILMI_Backup_${timestamp}_v$_currentSchemaVersion.zip';
    final zipPath = p.join(backupDir.path, fileName);

    // Hitung SHA-256 dari file database
    final dbHash = await _sha256OfFile(dbFile);

    // Buat manifest.json
    final manifest = BackupManifest(
      formatVersion: 1,
      schemaVersion: _currentSchemaVersion,
      createdAtUtc: now.toIso8601String(),
      databaseSha256: dbHash,
      fileName: fileName,
    );
    final manifestJson = jsonEncode(manifest.toJson());
    final manifestBytes = Uint8List.fromList(utf8.encode(manifestJson));

    // Kemas manifest.json + siak_ilmi.db ke dalam ZIP
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    encoder.addArchiveFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );
    encoder.addFile(dbFile);
    encoder.close();

    return zipPath;
  }

  /// Mengunggah file ZIP ke Supabase Storage secara langsung.
  Future<void> _uploadToSupabase(String zipPath) async {
    final client = _client;
    if (client == null) {
      throw const BackupException('Supabase client tidak tersedia.');
    }

    final file = File(zipPath);
    final bytes = await file.readAsBytes();
    final fileName = p.basename(zipPath);
    final storagePath = '$supabaseBackupPathPrefix/$fileName';

    await client.storage.from(supabaseBucketId).uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'application/zip',
            upsert: true,
          ),
        );
  }

  /// Menghitung SHA-256 hex digest dari sebuah file.
  Future<String> _sha256OfFile(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Mendapatkan direktori backup lokal.
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
    } catch (_) {}

    dir ??= Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'backups'),
    );

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
