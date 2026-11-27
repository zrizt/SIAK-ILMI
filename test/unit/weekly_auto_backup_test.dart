import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siak_ilmi/features/backup_restore/data/backup_service.dart';
import 'package:siak_ilmi/features/backup_restore/data/weekly_auto_backup_service.dart';

class _FakeBackupService implements BackupService {
  int callCount = 0;
  BackupResult nextResult = const BackupResult(
    localZipPath: '/tmp/backup.zip',
    cloudUploaded: true,
  );
  bool shouldThrow = false;
  Duration delay = Duration.zero;

  @override
  Future<BackupResult> performBackup() async {
    callCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (shouldThrow) {
      throw Exception('Simulated unexpected backup error');
    }
    return nextResult;
  }

  @override
  Future<String?> getLocalBackupPath() async => null;

  @override
  Future<void> restoreFromZip(String zipPath) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WeeklyAutoBackupService', () {
    test('runs on first launch when online and records timestamp', () async {
      final fakeBackup = _FakeBackupService();
      final now = DateTime.utc(2026, 11, 24, 8, 0); // Tuesday

      final service = WeeklyAutoBackupService(
        backupService: fakeBackup,
        checkOnline: () async => true,
        nowProvider: () => now,
      );

      final ran = await service.runIfDue();
      expect(ran, isTrue);
      expect(fakeBackup.callCount, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(WeeklyAutoBackupService.prefsKeyLastAutoBackup),
        now.toIso8601String(),
      );
    });

    test('skips backup when offline without calling performBackup', () async {
      final fakeBackup = _FakeBackupService();
      final now = DateTime.utc(2026, 11, 24, 8, 0);

      final service = WeeklyAutoBackupService(
        backupService: fakeBackup,
        checkOnline: () async => false,
        nowProvider: () => now,
      );

      final ran = await service.runIfDue();
      expect(ran, isFalse);
      expect(fakeBackup.callCount, 0);
    });

    test('skips when fewer than 5 days elapsed even in a new ISO week',
        () async {
      final fakeBackup = _FakeBackupService();
      // Saturday Nov 28, 2026
      final lastBackup = DateTime.utc(2026, 11, 28, 10, 0);
      SharedPreferences.setMockInitialValues({
        WeeklyAutoBackupService.prefsKeyLastAutoBackup:
            lastBackup.toIso8601String(),
      });

      // Tuesday Dec 1, 2026 (new ISO week, but only 3 days elapsed)
      final now = DateTime.utc(2026, 12, 1, 10, 0);
      final service = WeeklyAutoBackupService(
        backupService: fakeBackup,
        checkOnline: () async => true,
        nowProvider: () => now,
      );

      final ran = await service.runIfDue();
      expect(ran, isFalse);
      expect(fakeBackup.callCount, 0);
    });

    test('caps at 1 automatic online backup per ISO week even if >= 5 days',
        () async {
      final fakeBackup = _FakeBackupService();
      // Monday Nov 23, 2026 08:00 (W48)
      final lastBackup = DateTime.utc(2026, 11, 23, 8, 0);
      SharedPreferences.setMockInitialValues({
        WeeklyAutoBackupService.prefsKeyLastAutoBackup:
            lastBackup.toIso8601String(),
      });

      // Saturday Nov 28, 2026 12:00 (5+ days elapsed, STILL W48)
      final sameWeekNow = DateTime.utc(2026, 11, 28, 12, 0);
      final service = WeeklyAutoBackupService(
        backupService: fakeBackup,
        checkOnline: () async => true,
        nowProvider: () => sameWeekNow,
      );

      final ran = await service.runIfDue();
      expect(ran, isFalse);
      expect(fakeBackup.callCount, 0);
    });

    test('runs when >= 5 days elapsed AND in a new ISO week (5-6 day cadence)',
        () async {
      final fakeBackup = _FakeBackupService();
      // Tuesday Nov 24, 2026 08:00 (W48)
      final lastBackup = DateTime.utc(2026, 11, 24, 8, 0);
      SharedPreferences.setMockInitialValues({
        WeeklyAutoBackupService.prefsKeyLastAutoBackup:
            lastBackup.toIso8601String(),
      });

      // Monday Nov 30, 2026 09:00 (6 days elapsed, new week W49)
      final nextWeekNow = DateTime.utc(2026, 11, 30, 9, 0);
      final service = WeeklyAutoBackupService(
        backupService: fakeBackup,
        checkOnline: () async => true,
        nowProvider: () => nextWeekNow,
      );

      final ran = await service.runIfDue();
      expect(ran, isTrue);
      expect(fakeBackup.callCount, 1);
    });

    test('does not record timestamp if cloud upload failed', () async {
      final fakeBackup = _FakeBackupService()
        ..nextResult = const BackupResult(
          localZipPath: '/tmp/backup.zip',
          cloudUploaded: false,
          cloudError: 'Network timeout',
        );
      final now = DateTime.utc(2026, 11, 24, 8, 0);

      final service = WeeklyAutoBackupService(
        backupService: fakeBackup,
        checkOnline: () async => true,
        nowProvider: () => now,
      );

      final ran = await service.runIfDue();
      expect(ran, isFalse);
      expect(fakeBackup.callCount, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(WeeklyAutoBackupService.prefsKeyLastAutoBackup),
        isNull,
      );
    });

    test('prevents concurrent duplicate backup runs', () async {
      final fakeBackup = _FakeBackupService()
        ..delay = const Duration(milliseconds: 80);
      final now = DateTime.utc(2026, 11, 24, 8, 0);

      final service = WeeklyAutoBackupService(
        backupService: fakeBackup,
        checkOnline: () async => true,
        nowProvider: () => now,
      );

      final results = await Future.wait([
        service.runIfDue(),
        service.runIfDue(),
      ]);

      expect(results, containsAllInOrder([true, false]));
      expect(fakeBackup.callCount, 1);
    });

    test('remains fail-silent when performBackup throws', () async {
      final fakeBackup = _FakeBackupService()..shouldThrow = true;
      final service = WeeklyAutoBackupService(
        backupService: fakeBackup,
        checkOnline: () async => true,
        nowProvider: () => DateTime.utc(2026, 11, 24, 8, 0),
      );

      final ran = await service.runIfDue();
      expect(ran, isFalse);
    });
  });
}
