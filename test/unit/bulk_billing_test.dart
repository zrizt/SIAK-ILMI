import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/database/daos/siswa_dao.dart';
import 'package:siak_ilmi/core/database/daos/tagihan_dao.dart';
import 'package:siak_ilmi/core/database/daos/tarif_dao.dart';
import 'package:siak_ilmi/core/database/database_seeder.dart';
import 'package:siak_ilmi/features/fee_management/domain/bill_generator_engine.dart';
import 'package:siak_ilmi/features/fee_management/domain/bulk_billing_use_case.dart';
import 'package:siak_ilmi/features/fee_management/domain/tariff_resolver_use_case.dart';

AppDatabase buildTestDatabase() => AppDatabase(NativeDatabase.memory());

void main() {
  group('BulkBillingUseCase Tests', () {
    late AppDatabase db;
    late DatabaseSeeder seeder;
    late SiswaDao siswaDao;
    late TagihanDao tagihanDao;
    late TarifDao tarifDao;
    late BillGeneratorEngine billEngine;
    late BulkBillingUseCase bulkUseCase;

    setUp(() async {
      db = buildTestDatabase();
      seeder = DatabaseSeeder(db);
      await seeder.seedIfEmpty();

      siswaDao = SiswaDao(db);
      tagihanDao = TagihanDao(db);
      tarifDao = TarifDao(db);

      final tariffResolver = TariffResolverUseCase(tarifDao);
      billEngine = BillGeneratorEngine(
        db: db,
        tariffResolver: tariffResolver,
        tarifDao: tarifDao,
        siswaDao: siswaDao,
        tagihanDao: tagihanDao,
      );

      bulkUseCase = BulkBillingUseCase(
        siswaDao: siswaDao,
        tagihanDao: tagihanDao,
        tarifDao: tarifDao,
        billEngine: billEngine,
      );
    });

    tearDown(() => db.close());

    test('Bulk billing generates charges for all active students', () async {
      // 1. Insert 2 active students
      final s1 = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261001',
          namaLengkap: 'Ahmad Santoso',
          jenisKelamin: 'L',
          kelasId: 1,
          tahunMasuk: 2026,
        ),
      );
      final s2 = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 2,
          nis: '262001',
          namaLengkap: 'Fatimah Zahra',
          jenisKelamin: 'P',
          kelasId: 7,
          tahunMasuk: 2026,
        ),
      );

      // Insert 1 inactive student
      await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261002',
          namaLengkap: 'Siswa Drop Out',
          jenisKelamin: 'L',
          kelasId: 1,
          tahunMasuk: 2026,
          status: const Value('DROP_OUT'),
        ),
      );

      // Find SPP category
      final categories = await tarifDao.getAllKategori();
      final sppKat = categories.firstWhere((c) => c.namaBiaya.contains('SPP'));

      // 6 months for Semester 1 (Juli-Desember 2026)
      final months = List.generate(6, (i) => (7 + i, 2026));

      // 2. Execute Bulk Billing
      final result = await bulkUseCase.execute(
        BulkBillingParams(
          semesterLabel: 'Semester 1 TA 2026/2027',
          months: months,
          sppKategoriBiayaId: sppKat.id,
          createdBy: 'Petugas Test',
        ),
      );

      // 2 active students * 6 months = 12 bills created
      expect(result.successCount, 12);
      expect(result.skippedCount, 0);
      expect(result.failedCount, 0);

      // Verify student 1 has 6 bills
      final billsS1 = await tagihanDao.watchUnpaidItemsByStudent(s1).first;
      expect(billsS1.length, 6);

      // Verify student 2 has 6 bills
      final billsS2 = await tagihanDao.watchUnpaidItemsByStudent(s2).first;
      expect(billsS2.length, 6);
    });

    test('Duplicate prevention skips already-billed periods', () async {
      await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261003',
          namaLengkap: 'Zaidan Pratama',
          jenisKelamin: 'L',
          kelasId: 2,
          tahunMasuk: 2026,
        ),
      );

      final categories = await tarifDao.getAllKategori();
      final sppKat = categories.firstWhere((c) => c.namaBiaya.contains('SPP'));
      final months = List.generate(6, (i) => (7 + i, 2026));

      final params = BulkBillingParams(
        semesterLabel: 'Semester 1 TA 2026/2027',
        months: months,
        sppKategoriBiayaId: sppKat.id,
        createdBy: 'Petugas Test',
      );

      // First run: creates 6 bills
      final firstRun = await bulkUseCase.execute(params);
      expect(firstRun.successCount, 6);
      expect(firstRun.skippedCount, 0);

      // Second run with same parameters: skips all 6 bills
      final secondRun = await bulkUseCase.execute(params);
      expect(secondRun.successCount, 0);
      expect(secondRun.skippedCount, 6);
      expect(secondRun.failedCount, 0);
    });
  });
}
