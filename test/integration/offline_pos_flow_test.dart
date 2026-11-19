import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/database/database_seeder.dart';
import 'package:siak_ilmi/core/database/daos/siswa_dao.dart';
import 'package:siak_ilmi/core/database/daos/tagihan_dao.dart';
import 'package:siak_ilmi/core/database/daos/pembayaran_dao.dart';
import 'package:siak_ilmi/core/database/daos/tarif_dao.dart';
import 'package:siak_ilmi/core/services/audit_logger_service.dart';
import 'package:siak_ilmi/features/students/domain/auto_nis_generator_use_case.dart';
import 'package:siak_ilmi/features/fee_management/domain/tariff_resolver_use_case.dart';
import 'package:siak_ilmi/features/fee_management/domain/bill_generator_engine.dart';
import 'package:siak_ilmi/features/payments/domain/process_payment_use_case.dart';
import 'package:siak_ilmi/features/backup_restore/data/backup_service.dart';

AppDatabase createTestDb() => AppDatabase(NativeDatabase.memory());

void main() {
  group('SIAK-ILMI Offline POS End-to-End Flow (AC-01, AC-04, AC-05)', () {
    late AppDatabase db;
    late SiswaDao siswaDao;
    late TagihanDao tagihanDao;
    late PembayaranDao pembayaranDao;
    late TarifDao tarifDao;
    late AuditLoggerService auditLogger;
    late AutoNisGeneratorUseCase nisGenerator;
    late TariffResolverUseCase tariffResolver;
    late BillGeneratorEngine billEngine;
    late ProcessPaymentUseCase paymentUseCase;

    setUp(() async {
      db = createTestDb();
      await DatabaseSeeder(db).seedIfEmpty();

      siswaDao = SiswaDao(db);
      tagihanDao = TagihanDao(db);
      pembayaranDao = PembayaranDao(db);
      tarifDao = TarifDao(db);
      auditLogger = AuditLoggerService(db);

      nisGenerator = AutoNisGeneratorUseCase(siswaDao);
      tariffResolver = TariffResolverUseCase(tarifDao);
      billEngine = BillGeneratorEngine(
        db: db,
        tariffResolver: tariffResolver,
        tarifDao: tarifDao,
        siswaDao: siswaDao,
        tagihanDao: tagihanDao,
      );
      paymentUseCase = ProcessPaymentUseCase(
        db: db,
        pembayaranDao: pembayaranDao,
        tagihanDao: tagihanDao,
        auditLogger: auditLogger,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('AC-01 & AC-02: Offline student registration and auto-NIS generation', () async {
      // 1. Generate NIS for SD student (Kode 1, Year 2026)
      final nis = await nisGenerator.generate(
        sekolahId: 1,
        kodeSekolah: 1,
        tahunMasuk: 2026,
      );
      expect(nis, equals('261001'));

      // 2. Insert student
      final siswaId = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: nis,
          namaLengkap: 'Ahmad Fauzi',
          jenisKelamin: 'L',
          kelasId: 1,
          tahunMasuk: 2026,
        ),
      );
      expect(siswaId, isPositive);

      final siswa = await siswaDao.getById(siswaId);
      expect(siswa, isNotNull);
      expect(siswa!.nis, equals('261001'));
      expect(siswa.status, equals('AKTIF'));
    });

    test('AC-04 & AC-05: Bill generation and atomic multi-item POS payment with installment', () async {
      // 1. Register student
      final siswaId = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261001',
          namaLengkap: 'Fatimah Zahra',
          jenisKelamin: 'P',
          kelasId: 1,
          tahunMasuk: 2026,
        ),
      );

      // 2. Generate bill with SPP (150,000) and Infaq Gedung (400,000)
      final billResult = await billEngine.generateBill(
        siswaId: siswaId,
        tingkat: 1,
        periode: 'Juli 2026',
        items: const [
          BillLineItemParam(
            kategoriBiayaId: 1, // SPP
            namaItem: 'SPP Juli 2026',
            nominalDiskon: 0,
          ),
          BillLineItemParam(
            kategoriBiayaId: 2, // Infaq Gedung
            namaItem: 'Infaq Gedung',
            nominalDiskon: 0,
          ),
        ],
      );
      expect(billResult.itemIds.length, equals(2));

      final sppItemId = billResult.itemIds[0];
      final infaqItemId = billResult.itemIds[1];

      // 3. Process payment: Pay SPP fully (150,000) + Infaq Gedung installment partial (200,000)
      final paymentResult = await paymentUseCase.execute(
        ProcessPaymentParams(
          siswaId: siswaId,
          metodeBayar: 'Tunai',
          createdBy: 'Kasir Utama',
          allocations: [
            PaymentAllocation(
              tagihanItemId: sppItemId,
              nominalDialokasikan: 150000,
            ),
            PaymentAllocation(
              tagihanItemId: infaqItemId,
              nominalDialokasikan: 200000,
            ),
          ],
        ),
      );

      expect(paymentResult.totalBayar, equals(350000));
      expect(paymentResult.nomorKuitansi, startsWith('KW-'));

      // 4. Verify SPP item is now fully paid (Lunas)
      final sppItem = await tagihanDao.getItemById(sppItemId);
      expect(sppItem, isNotNull);
      expect(sppItem!.terbayar, equals(150000));
      expect(sppItem.isLunas, equals(1));

      // 5. Verify Infaq item is partially paid (Not Lunas)
      final infaqItem = await tagihanDao.getItemById(infaqItemId);
      expect(infaqItem, isNotNull);
      expect(infaqItem!.terbayar, equals(200000));
      expect(infaqItem.nominalAkhir, equals(400000));
      expect(infaqItem.isLunas, equals(0));

      // 6. Complete remaining installment for Infaq (200,000)
      final secondPayment = await paymentUseCase.execute(
        ProcessPaymentParams(
          siswaId: siswaId,
          metodeBayar: 'Transfer',
          createdBy: 'Kasir Utama',
          allocations: [
            PaymentAllocation(
              tagihanItemId: infaqItemId,
              nominalDialokasikan: 200000,
            ),
          ],
        ),
      );
      expect(secondPayment.totalBayar, equals(200000));

      final infaqUpdated = await tagihanDao.getItemById(infaqItemId);
      expect(infaqUpdated!.terbayar, equals(400000));
      expect(infaqUpdated.isLunas, equals(1));

      // Unpaid items stream should now be completely empty for this student
      final unpaid = await tagihanDao.watchUnpaidItemsByStudent(siswaId).first;
      expect(unpaid, isEmpty);
    });

    test('EC-02: Payment void and reversal rollback restores unpaid status', () async {
      // 1. Create student and bill
      final siswaId = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 2,
          nis: '262001',
          namaLengkap: 'Budi Santoso',
          jenisKelamin: 'L',
          kelasId: 7,
          tahunMasuk: 2026,
        ),
      );

      final billResult = await billEngine.generateBill(
        siswaId: siswaId,
        tingkat: 7,
        periode: 'Agustus 2026',
        items: const [
          BillLineItemParam(
            kategoriBiayaId: 1,
            namaItem: 'SPP Agustus 2026',
            nominalDiskon: 0,
          ),
        ],
      );
      final itemId = billResult.itemIds.first;

      // 2. Pay bill
      final payResult = await paymentUseCase.execute(
        ProcessPaymentParams(
          siswaId: siswaId,
          metodeBayar: 'Tunai',
          createdBy: 'Kasir',
          allocations: [
            PaymentAllocation(
              tagihanItemId: itemId,
              nominalDialokasikan: 150000,
            ),
          ],
        ),
      );

      var item = await tagihanDao.getItemById(itemId);
      expect(item!.isLunas, equals(1));
      expect(item.terbayar, equals(150000));

      // 3. Void transaction
      await paymentUseCase.voidTransaction(
        transaksiId: payResult.transaksiId,
        voidedBy: 'Admin',
      );

      // 4. Verify transaction status and reversed bill status
      final txns = await pembayaranDao.getAlokasiByTransaksi(payResult.transaksiId);
      expect(txns, isNotEmpty);

      item = await tagihanDao.getItemById(itemId);
      expect(item!.isLunas, equals(0));
      expect(item.terbayar, equals(0));

      final unpaid = await tagihanDao.watchUnpaidItemsByStudent(siswaId).first;
      expect(unpaid.length, equals(1));
      expect(unpaid.first.id, equals(itemId));
    });

    test('EC-04: Historical bill snapshot immutability guarantee', () async {
      // 1. Create student and bill with current standard tariff (SPP = 150,000)
      final siswaId = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261005',
          namaLengkap: 'Siti Nurhaliza',
          jenisKelamin: 'P',
          kelasId: 2,
          tahunMasuk: 2026,
        ),
      );

      final billResult = await billEngine.generateBill(
        siswaId: siswaId,
        tingkat: 2,
        periode: 'September 2026',
        items: const [
          BillLineItemParam(
            kategoriBiayaId: 1,
            namaItem: 'SPP September 2026',
            nominalDiskon: 0,
          ),
        ],
      );
      final itemId = billResult.itemIds.first;

      final snapshotBefore = await tagihanDao.getItemById(itemId);
      expect(snapshotBefore!.nominalAkhir, equals(150000));

      // 2. Future tariff change: Increase SPP in tarif_master from 150,000 to 250,000
      await tarifDao.upsertTarifMaster(
        const TarifMasterCompanion(
          kategoriBiayaId: Value(1),
          tingkat: Value(2),
          nominal: Value(250000),
        ),
      );

      // 3. Historical bill MUST remain 150,000 (never re-calculated from tarif_master)
      final snapshotAfter = await tagihanDao.getItemById(itemId);
      expect(snapshotAfter!.nominalAwal, equals(150000));
      expect(snapshotAfter.nominalAkhir, equals(150000));
    });

    test('EC-03: Offline backup service handles local backup without throwing', () async {
      const backupService = BackupServiceImpl();
      final result = await backupService.performBackup();

      // In unit test environment, local db file path may or may not exist,
      // but performBackup() MUST NEVER throw and always return BackupResult.
      expect(result, isA<BackupResult>());
      expect(result.cloudUploaded, isFalse);
    });
  });
}
