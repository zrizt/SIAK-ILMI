import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';

// ── Abstract BackupService interface ──────────────────────────────────────

/// Abstract interface for the backup adapter.
/// Isolates Google Drive dependency behind a clean contract.
/// Can be swapped with Supabase / WebDAV without touching core app code.
abstract interface class BackupService {
  /// Creates a local .zip snapshot and attempts cloud upload.
  /// MUST NEVER throw — all failures are returned as [BackupResult].
  Future<BackupResult> performBackup();

  /// Returns the path to the most recent local .zip, or null.
  Future<String?> getLocalBackupPath();
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

/// Provides the concrete [BackupServiceImpl] as [BackupService].
/// Google Drive adapter is disabled by default — set [driveEnabled] = true
/// after configuring OAuth in Phase 6.
final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupServiceImpl(driveEnabled: false),
);

// ── Local-only Backup Implementation ──────────────────────────────────────

class BackupServiceImpl implements BackupService {
  const BackupServiceImpl({this.driveEnabled = false});

  /// Set to true when Drive OAuth is configured (Phase 6).
  final bool driveEnabled;

  @override
  Future<BackupResult> performBackup() async {
    String localPath = '';
    try {
      localPath = await _createLocalZip();
    } catch (e) {
      // Local zip failed — should not happen but catch defensively
      return BackupResult(
        localZipPath: '',
        cloudUploaded: false,
        cloudError: 'Local backup failed: $e',
      );
    }

    // Attempt Google Drive upload only if enabled (Phase 6)
    if (!driveEnabled) {
      return BackupResult(
        localZipPath: localPath,
        cloudUploaded: false,
        cloudError: 'Drive backup not configured. Local .zip saved.',
      );
    }

    try {
      await _uploadToDrive(localPath);
      return BackupResult(
        localZipPath: localPath,
        cloudUploaded: true,
      );
    } catch (e) {
      // FAIL-SILENT: Cloud error must never crash the app (PRD Rule #1)
      return BackupResult(
        localZipPath: localPath,
        cloudUploaded: false,
        cloudError: 'Drive upload failed: $e',
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

  /// Compresses the SQLite database file into a .zip archive in
  /// Android's Downloads-equivalent directory.
  Future<String> _createLocalZip() async {
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

  /// Placeholder for Google Drive upload (Phase 6).
  Future<void> _uploadToDrive(String zipPath) async {
    // TODO Phase 6: Implement googleapis Drive v3 upload
    throw UnimplementedError('Drive upload not implemented yet.');
  }

  Future<Directory> _backupDirectory() async {
    // On Android, external storage / Downloads
    Directory? dir;
    try {
      // Try external storage first (accessible from Files app)
      final extDirs = await getExternalStorageDirectories();
      if (extDirs != null && extDirs.isNotEmpty) {
        dir = Directory(p.join(extDirs.first.parent.parent.parent.parent.path,
            'Download', 'SIAK-ILMI-Backup'));
      }
    } catch (_) {
      // Fall back to app documents
    }
    dir ??= Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'backups'));

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
