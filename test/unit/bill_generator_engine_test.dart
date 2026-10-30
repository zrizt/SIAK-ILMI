import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/database/database_seeder.dart';
import 'package:siak_ilmi/core/database/daos/siswa_dao.dart';
import 'package:siak_ilmi/core/database/daos/tagihan_dao.dart';
import 'package:siak_ilmi/core/database/daos/tarif_dao.dart';
import 'package:siak_ilmi/features/fee_management/domain/tariff_resolver_use_case.dart';
import 'package:siak_ilmi/features/fee_management/domain/bill_generator_engine.dart';

AppDatabase buildTestDatabase() => AppDatabase(NativeDatabase.memory());

void main() {
  group('BillGeneratorEngine - Snapshot Immutability (AC-06)', () {
    late AppDatabase db;
    late DatabaseSeeder seeder;

    setUp(() async {
      db = buildTestDatabase();
      seeder = DatabaseSeeder(db);
      await seeder.seedIfEmpty();
    });

    tearDown(() => db.close());

    test('AC-06: Changing tarif_master does NOT alter existing tagihan_item', () async {
      final tarifDao = TarifDao(db);
      final siswaDao = SiswaDao(db);
      final tagihanDao = TagihanDao(db);
      final tariffResolver = TariffResolverUseCase(tarifDao);
      final engine = BillGeneratorEngine(
        db: db,
        tariffResolver: tariffResolver,
        tarifDao: tarifDao,
        siswaDao: siswaDao,
        tagihanDao: tagihanDao,
      );

      // Insert a test student in grade 1 SD
      final siswaId = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261001',
          namaLengkap: 'Test Siswa',
          jenisKelamin: 'L',
          kelasId: 1, // Grade 1
          tahunMasuk: 2026,
        ),
      );

      // Get SPP kategori ID (should be 1 after seed)
      final kategoris = await tarifDao.getAllKategori();
      final sppKategori = kategoris.firstWhere((k) => k.namaBiaya == 'SPP');

      // Generate a bill with current tariff (150,000)
      final result = await engine.generateBill(
        siswaId: siswaId,
        tingkat: 1,
        periode: 'Oktober 2026',
        items: [
          BillLineItemParam(
            kategoriBiayaId: sppKategori.id,
            namaItem: 'SPP Oktober 2026',
            nominalDiskon: 0,
          ),
        ],
      );

      // Verify snapshotted amount
      final items = await tagihanDao.getItemsByTagihan(result.tagihanSiswaId);
      expect(items.length, 1);
      expect(items.first.nominalAwal, 150000); // standard rate

      // NOW change tarif_master to 180,000 (simulating a future rate change)
      final masterTarif = await tarifDao.getStandardTarif(
        kategoriBiayaId: sppKategori.id,
        tingkat: 1,
      );
      await tarifDao.upsertTarifMaster(
        TarifMasterCompanion(
          id: Value(masterTarif!.id),
          kategoriBiayaId: Value(masterTarif.kategoriBiayaId),
          tingkat: Value(masterTarif.tingkat),
          nominal: const Value(180000), // Changed!
        ),
      );

      // Re-fetch the EXISTING tagihan_item — it MUST still show 150,000
      final itemsAfterChange =
          await tagihanDao.getItemsByTagihan(result.tagihanSiswaId);
      expect(
        itemsAfterChange.first.nominalAwal,
        150000,
        reason: 'Snapshot must be immutable after tarif_master change',
      );
      expect(
        itemsAfterChange.first.nominalAkhir,
        150000,
        reason: 'nominal_akhir snapshot must be immutable',
      );
    });
  });

  group('BillGeneratorEngine - PPDB Wave Discounts (AC-03)', () {
    test('Wave 1 (Oct-Dec 2026): all fees 100% free', () {
      final discount = BillGeneratorEngine.calculateWaveDiscount(
        DateTime(2026, 10, 15),
      );
      expect(discount.wave, 1);
      expect(discount.pendaftaranDiskon, 100000);
      expect(discount.infaqDiskon, 400000);
      expect(discount.sppDiskon, 150000);
    });

    test('Wave 2 (Jan-Mar 2027): pendaftaran free, infaq/SPP 50% off', () {
      final discount = BillGeneratorEngine.calculateWaveDiscount(
        DateTime(2027, 2, 10),
      );
      expect(discount.wave, 2);
      expect(discount.pendaftaranDiskon, 100000);
      expect(discount.infaqDiskon, 200000);
      expect(discount.sppDiskon, 75000);
    });

    test('Wave 3 (Apr-Jun 2027): pendaftaran free, infaq 50% off, SPP normal', () {
      final discount = BillGeneratorEngine.calculateWaveDiscount(
        DateTime(2027, 5, 1),
      );
      expect(discount.wave, 3);
      expect(discount.pendaftaranDiskon, 100000);
      expect(discount.infaqDiskon, 200000);
      expect(discount.sppDiskon, 0);
    });

    test('Outside all waves: no discount', () {
      final discount = BillGeneratorEngine.calculateWaveDiscount(
        DateTime(2027, 8, 1),
      );
      expect(discount.wave, 0);
      expect(discount.hasDiscount, false);
    });
  });
}
