import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/database/database_seeder.dart';
import 'package:siak_ilmi/core/database/daos/siswa_dao.dart';
import 'package:siak_ilmi/core/database/daos/tagihan_dao.dart';
import 'package:siak_ilmi/core/database/daos/pembayaran_dao.dart';
import 'package:siak_ilmi/core/database/daos/audit_dao.dart';
import 'package:siak_ilmi/core/database/tables/tagihan_siswa_table.dart';
import 'package:siak_ilmi/core/database/tables/tagihan_item_table.dart';
import 'package:siak_ilmi/core/database/tables/siswa_table.dart';
import 'package:siak_ilmi/core/services/audit_logger_service.dart';
import 'package:siak_ilmi/features/payments/domain/process_payment_use_case.dart';
import 'package:drift/drift.dart';

AppDatabase buildTestDb() => AppDatabase(NativeDatabase.memory());

void main() {
  group('ProcessPaymentUseCase — Atomic Transaction (AC-04, AC-05)', () {
    late AppDatabase db;

    setUp(() async {
      db = buildTestDb();
      await DatabaseSeeder(db).seedIfEmpty();
    });

    tearDown(() => db.close());

    test('AC-04: Checking two items creates 1 transaksi + 2 alokasi', () async {
      // Insert test student
      final siswaDao = SiswaDao(db);
      final siswaId = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261001',
          namaLengkap: 'Test AC04',
          jenisKelamin: 'L',
          kelasId: 1,
          tahunMasuk: 2026,
        ),
      );

      // Create a tagihan with 2 items
      final tagihanDao = TagihanDao(db);
      final tagihanId = await tagihanDao.insertTagihanSiswa(
        TagihanSiswaCompanion.insert(
          siswaId: siswaId,
          periode: 'Oktober 2026',
        ),
      );
      final item1Id = await tagihanDao.insertTagihanItem(
        TagihanItemCompanion.insert(
          tagihanId: tagihanId,
          kategoriBiayaId: 1, // SPP
          namaItem: 'SPP Oktober 2026',
          nominalAwal: 150000,
          nominalAkhir: 150000,
        ),
      );
      final item2Id = await tagihanDao.insertTagihanItem(
        TagihanItemCompanion.insert(
          tagihanId: tagihanId,
          kategoriBiayaId: 2, // Infaq
          namaItem: 'Infaq Gedung',
          nominalAwal: 400000,
          nominalAkhir: 400000,
        ),
      );

      // Execute payment: SPP full + Infaq partial Rp200.000
      final useCase = ProcessPaymentUseCase(
        db: db,
        pembayaranDao: PembayaranDao(db),
        tagihanDao: tagihanDao,
        auditLogger: AuditLoggerService(db),
      );

      final result = await useCase.execute(
        ProcessPaymentParams(
          siswaId: siswaId,
          metodeBayar: 'Tunai',
          createdBy: 'Admin',
          allocations: [
            PaymentAllocation(
                tagihanItemId: item1Id, nominalDialokasikan: 150000),
            PaymentAllocation(
                tagihanItemId: item2Id, nominalDialokasikan: 200000),
          ],
        ),
      );

      // AC-04: total should be 350.000
      expect(result.totalBayar, 350000);
      expect(result.nomorKuitansi, startsWith('KW-'));

      // Verify 2 alokasi records exist
      final alokasi =
          await PembayaranDao(db).getAlokasiByTransaksi(result.transaksiId);
      expect(alokasi.length, 2);

      // AC-05: SPP should be lunas, Infaq sisa 200.000
      final items = await tagihanDao.getItemsByTagihan(tagihanId);
      final spp = items.firstWhere((i) => i.id == item1Id);
      final infaq = items.firstWhere((i) => i.id == item2Id);

      expect(spp.isLunas, 1);
      expect(spp.terbayar, 150000);
      expect(infaq.isLunas, 0);
      expect(infaq.terbayar, 200000);
      // AC-05: Remaining arrears = 400000 - 200000 = 200000
      expect(infaq.nominalAkhir - infaq.terbayar, 200000);
    });

    test('EC-02: Voiding a transaction reverses tagihan_item amounts', () async {
      final siswaDao = SiswaDao(db);
      final siswaId = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261002',
          namaLengkap: 'Test EC02',
          jenisKelamin: 'P',
          kelasId: 1,
          tahunMasuk: 2026,
        ),
      );

      final tagihanDao = TagihanDao(db);
      final tagihanId = await tagihanDao.insertTagihanSiswa(
        TagihanSiswaCompanion.insert(
            siswaId: siswaId, periode: 'November 2026'),
      );
      final itemId = await tagihanDao.insertTagihanItem(
        TagihanItemCompanion.insert(
          tagihanId: tagihanId,
          kategoriBiayaId: 1,
          namaItem: 'SPP November 2026',
          nominalAwal: 150000,
          nominalAkhir: 150000,
        ),
      );

      final useCase = ProcessPaymentUseCase(
        db: db,
        pembayaranDao: PembayaranDao(db),
        tagihanDao: tagihanDao,
        auditLogger: AuditLoggerService(db),
      );

      final result = await useCase.execute(
        ProcessPaymentParams(
          siswaId: siswaId,
          metodeBayar: 'Tunai',
          createdBy: 'Admin',
          allocations: [
            PaymentAllocation(
                tagihanItemId: itemId, nominalDialokasikan: 150000),
          ],
        ),
      );

      // Item should be lunas
      var items = await tagihanDao.getItemsByTagihan(tagihanId);
      expect(items.first.isLunas, 1);

      // Void the transaction
      await useCase.voidTransaction(
        transaksiId: result.transaksiId,
        voidedBy: 'Admin',
      );

      // Item should be reset
      items = await tagihanDao.getItemsByTagihan(tagihanId);
      expect(items.first.isLunas, 0);
      expect(items.first.terbayar, 0);
    });
  });
}
