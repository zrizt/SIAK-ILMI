// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:siak_ilmi/core/errors/app_exception.dart';
import 'package:siak_ilmi/features/backup_restore/data/backup_service.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  MockPathProviderPlatform(this.tempPath);
  final String tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;

  @override
  Future<String?> getTemporaryPath() async => tempPath;

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async =>
      [tempPath];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late MockPathProviderPlatform mockPlatform;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('backup_service_test_');
    mockPlatform = MockPathProviderPlatform(tempDir.path);
    PathProviderPlatform.instance = mockPlatform;
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('BackupService and SupabaseBackupService Tests', () {
    test('BackupServiceImpl performBackup handles missing db fail-silently', () async {
      const service = BackupServiceImpl();
      final result = await service.performBackup();

      expect(result, isA<BackupResult>());
      expect(result.cloudUploaded, isFalse);
      expect(result.hasLocalBackup, isFalse);
      expect(result.cloudError, contains('Database file not found'));
    });

    test('SupabaseBackupService restoreFromZip throws on non-existent zip', () async {
      final supabaseService = SupabaseBackupService();
      expect(
        () => supabaseService.restoreFromZip('${tempDir.path}/non_existent.zip'),
        throwsA(isA<BackupException>()),
      );
    });

    test('SupabaseBackupService restoreFromZip rejects corrupt archive (bad magic)', () async {
      final supabaseService = SupabaseBackupService();

      // Create a zip containing a fake db with invalid SQLite magic bytes
      final fakeDb = File('${tempDir.path}/siak_ilmi_source.db');
      fakeDb.writeAsBytesSync(List.filled(200, 0x00)); // Not a valid SQLite file

      final zipPath = '${tempDir.path}/test_bad_backup.zip';
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      encoder.addFile(fakeDb, 'siak_ilmi.db');
      encoder.close();

      // Should throw BackupException due to bad SQLite magic number
      expect(
        () => supabaseService.restoreFromZip(zipPath),
        throwsA(isA<BackupException>()),
      );
    });
  });
}
