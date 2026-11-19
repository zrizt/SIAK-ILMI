import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import 'supabase_backup_adapter.dart';

export 'supabase_backup_adapter.dart' show SupabaseBackupService;

// ── Abstract BackupService interface ──────────────────────────────────────

/// Abstract interface for the backup adapter.
/// Isolates cloud dependency behind a clean contract.
/// Can be swapped with any cloud provider without touching core app code.
abstract interface class BackupService {
  /// Creates a local .zip snapshot and attempts cloud upload.
  /// MUST NEVER throw — all failures are returned as [BackupResult].
  Future<BackupResult> performBackup();

  /// Returns the path to the most recent local .zip, or null.
  Future<String?> getLocalBackupPath();

  /// Restores the SQLite database from a local .zip backup archive.
  Future<void> restoreFromZip(String zipPath);
}

/// Result model returned by [BackupService.performBackup].
class BackupResult {
  const BackupResult({
    required this.localZipPath,
    required this.cloudUploaded,
    this.cloudError,
  });

  final String localZipPath;
  final bool cloudUploaded;
  final String? cloudError; // Non-null if cloud upload was skipped/failed

  bool get hasLocalBackup => localZipPath.isNotEmpty;
}

// ── Provider ───────────────────────────────────────────────────────────────

/// Provides the concrete [BackupService] backed by [SupabaseBackupService].
/// Supabase cloud sync is attempted fail-silently while always guaranteeing
/// local .zip creation.
final backupServiceProvider = Provider<BackupService>(
  (ref) => ref.watch(supabaseBackupServiceProvider),
);

// ── Local-only Backup Implementation (legacy / test use) ──────────────────

/// Local-only backup implementation used for unit tests and fallback scenarios.
/// Does NOT depend on any cloud adapter.
class BackupServiceImpl implements BackupService {
  const BackupServiceImpl({this.db});

  final AppDatabase? db;

  @override
  Future<BackupResult> performBackup() async {
    String localPath = '';
    try {
      localPath = await _createLocalZip();
    } catch (e) {
      return BackupResult(
        localZipPath: '',
        cloudUploaded: false,
        cloudError: 'Local backup failed: $e',
      );
    }

    return BackupResult(
      localZipPath: localPath,
      cloudUploaded: false,
      cloudError: 'Local-only mode. No cloud upload configured.',
    );
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

  @override
  Future<void> restoreFromZip(String zipPath) async {
    // Delegate to SupabaseBackupService for safe restore with rollback guard
    final supabase = SupabaseBackupService(db: db);
    await supabase.restoreFromZip(zipPath);
  }

  Future<String> _createLocalZip() async {
    if (db != null) {
      try {
        await db!.customStatement('PRAGMA wal_checkpoint(FULL);');
      } catch (_) {}
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docsDir.path, 'siak_ilmi.db'));

    if (!dbFile.existsSync()) {
      throw const BackupException('Database file not found.');
    }

    final backupDir = await _backupDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);
    final zipPath = p.join(backupDir.path, 'SIAK_ILMI_Backup_$timestamp.zip');

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    encoder.addFile(dbFile);
    encoder.close();

    return zipPath;
  }

  Future<Directory> _backupDirectory() async {
    Directory? dir;
    try {
      final extDirs = await getExternalStorageDirectories();
      if (extDirs != null && extDirs.isNotEmpty) {
        dir = Directory(p.join(extDirs.first.parent.parent.parent.parent.path,
            'Download', 'SIAK-ILMI-Backup'));
      }
    } catch (_) {}
    dir ??= Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'backups'));

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
