import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/database/daos/operator_dao.dart';
import 'package:siak_ilmi/core/database/database_seeder.dart';
import 'package:siak_ilmi/core/security/operator_service.dart';

AppDatabase buildTestDatabase() => AppDatabase(NativeDatabase.memory());

void main() {
  group('OperatorService Tests', () {
    late AppDatabase db;
    late DatabaseSeeder seeder;
    late OperatorService operatorService;

    setUp(() async {
      db = buildTestDatabase();
      seeder = DatabaseSeeder(db);
      await seeder.seedIfEmpty();
      operatorService = OperatorService(OperatorDao(db));
    });

    tearDown(() => db.close());

    test('Seeder creates default administrator account', () async {
      final count = await operatorService.count();
      expect(count, greaterThanOrEqualTo(1));

      final admin = await operatorService.login('admin', 'admin123');
      expect(admin, isNotNull);
      expect(admin!.username, 'admin');
      expect(admin.fullName, 'Administrator');
      expect(admin.isActive, 1);
    });

    test('Login with wrong password returns null', () async {
      final failed = await operatorService.login('admin', 'wrongpassword');
      expect(failed, isNull);
    });

    test('Create new operator and login successfully', () async {
      final id = await operatorService.createOperator(
        fullName: 'Budi Santoso',
        username: 'budis',
        password: 'password123',
      );
      expect(id, greaterThan(0));

      final op = await operatorService.login('budis', 'password123');
      expect(op, isNotNull);
      expect(op!.fullName, 'Budi Santoso');
      expect(op.username, 'budis');
    });

    test('Deactivated operator cannot log in', () async {
      final id = await operatorService.createOperator(
        fullName: 'Siti Aminah',
        username: 'siti',
        password: 'secretpassword',
      );

      // Verify active
      final activeLogin = await operatorService.login('siti', 'secretpassword');
      expect(activeLogin, isNotNull);

      // Deactivate
      await operatorService.setActive(id, active: false);

      // Login should fail
      final inactiveLogin =
          await operatorService.login('siti', 'secretpassword');
      expect(inactiveLogin, isNull);
    });

    test('Change password successfully updates authentication', () async {
      final id = await operatorService.createOperator(
        fullName: 'Kasir Darul Ilmi',
        username: 'kasir1',
        password: 'oldpassword',
      );

      // Wrong old password fails
      final wrongOld = await operatorService.changePassword(
        operatorId: id,
        currentPassword: 'wrongoldpassword',
        newPassword: 'newpassword123',
      );
      expect(wrongOld, isFalse);

      // Correct old password succeeds
      final success = await operatorService.changePassword(
        operatorId: id,
        currentPassword: 'oldpassword',
        newPassword: 'newpassword123',
      );
      expect(success, isTrue);

      // Old password no longer works
      expect(await operatorService.login('kasir1', 'oldpassword'), isNull);

      // New password works
      final newLogin = await operatorService.login('kasir1', 'newpassword123');
      expect(newLogin, isNotNull);
    });

    test('Create new operator with optional NIP persists correctly', () async {
      final id = await operatorService.createOperator(
        fullName: 'Dra. Nurhayati',
        username: 'nurhayati',
        password: 'password123',
        nip: '197505122000032001',
      );
      expect(id, greaterThan(0));

      final op = await operatorService.login('nurhayati', 'password123');
      expect(op, isNotNull);
      expect(op!.nip, '197505122000032001');

      // Operator without NIP defaults to null
      final id2 = await operatorService.createOperator(
        fullName: 'Ahmad Tanpa NIP',
        username: 'ahmad_nonip',
        password: 'password123',
      );
      expect(id2, greaterThan(0));
      final op2 = await operatorService.login('ahmad_nonip', 'password123');
      expect(op2, isNotNull);
      expect(op2!.nip, isNull);
    });
  });
}
