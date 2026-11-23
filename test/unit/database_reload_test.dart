import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/security/operator_service.dart';
import 'package:siak_ilmi/features/settings/presentation/pin_auth_screen.dart';

void main() {
  group('DatabaseNotifier and Hot Reload Tests', () {
    test('reloadDatabase replaces database instance and preserves auth session',
        () async {
      int openCount = 0;
      AppDatabase factory() {
        openCount++;
        return AppDatabase(NativeDatabase.memory());
      }

      final initialDb = factory();
      final container = ProviderContainer(
        overrides: [
          databaseNotifierProvider.overrideWith(
            (ref) => DatabaseNotifier(initialDb, dbFactory: factory),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Verify initial state
      final db1 = container.read(appDatabaseProvider);
      expect(db1, equals(initialDb));
      expect(openCount, 1);

      // Simulate an active user session (Admin role & active operator)
      container.read(authRoleProvider.notifier).state = PinRole.admin;
      container.read(activeOperatorProvider.notifier).state = const OperatorData(
        id: 1,
        fullName: 'Test Operator',
        nip: '1234567890',
        username: 'operator',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        isActive: 1,
        createdAt: '2026-11-23T00:00:00',
        updatedAt: '2026-11-23T00:00:00',
      );

      // Verify session exists
      expect(container.read(authRoleProvider), equals(PinRole.admin));
      expect(container.read(activeOperatorProvider)?.fullName,
          equals('Test Operator'));

      // Perform hot database reload
      await container.read(databaseNotifierProvider.notifier).reloadDatabase();

      // Verify that database was reloaded to a new instance
      final db2 = container.read(appDatabaseProvider);
      expect(db2, isNot(equals(db1)));
      expect(openCount, 2);

      // Verify that operator and auth role are completely preserved (no logout)
      expect(container.read(authRoleProvider), equals(PinRole.admin));
      expect(container.read(activeOperatorProvider)?.fullName,
          equals('Test Operator'));
      expect(container.read(activeOperatorProvider)?.nip, equals('1234567890'));
    });
  });
}
