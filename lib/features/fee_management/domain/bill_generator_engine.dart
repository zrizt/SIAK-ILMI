import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/database/daos/tagihan_dao.dart';
import '../../../core/database/daos/tarif_dao.dart';
import '../../../core/database/tables/tagihan_siswa_table.dart';
import '../../../core/database/tables/tagihan_item_table.dart';
import '../../../core/database/tables/kategori_biaya_table.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatter.dart';
import 'tariff_resolver_use_case.dart';

final billGeneratorEngineProvider = Provider<BillGeneratorEngine>(
  (ref) => BillGeneratorEngine(
    db: ref.watch(appDatabaseProvider),
    tariffResolver: ref.watch(tariffResolverUseCaseProvider),
    tarifDao: TarifDao(ref.watch(appDatabaseProvider)),
    siswaDao: SiswaDao(ref.watch(appDatabaseProvider)),
    tagihanDao: TagihanDao(ref.watch(appDatabaseProvider)),
  ),
);

/// Parameters needed to generate a single fee line item.
class BillLineItemParam {
  const BillLineItemParam({
    required this.kategoriBiayaId,
    required this.namaItem,
    required this.nominalDiskon,
  });

  final int kategoriBiayaId;
  final String namaItem; // Descriptive name snapshot e.g. 'SPP Juli 2026'
  final int nominalDiskon; // PPDB wave discount amount (0 if none)
}

/// Result of a bill generation operation.
class BillGenerationResult {
  const BillGenerationResult({
    required this.tagihanSiswaId,
    required this.itemIds,
  });

  final int tagihanSiswaId;
  final List<int> itemIds;
}

/// Implements PRD Section 7, Epic 3, F3.2 & F3.3:
/// Generates immutable bill snapshots for a student.
///
/// CRITICAL: Writes nominal_awal, nominal_diskon, and nominal_akhir directly
/// into tagihan_item rows. Future tarif_master changes MUST NOT affect these.
class BillGeneratorEngine {
  const BillGeneratorEngine({
    required this.db,
    required this.tariffResolver,
    required this.tarifDao,
    required this.siswaDao,
    required this.tagihanDao,
  });

  final AppDatabase db;
  final TariffResolverUseCase tariffResolver;
  final TarifDao tarifDao;
  final SiswaDao siswaDao;
  final TagihanDao tagihanDao;

  /// Generates a tagihan (bill header + item snapshots) for [siswaId].
  ///
  /// [periode] - Bill period string e.g. 'Juli 2026' or 'PPDB 2026/2027'
  /// [items] - List of line items with discount amounts pre-calculated
  /// [tingkat] - Student's current grade level (for tariff lookup)
  ///
  /// Wrapped in an atomic DB transaction per PRD Non-Negotiable Rule #5.
  Future<BillGenerationResult> generateBill({
    required int siswaId,
    required int tingkat,
    required String periode,
    required List<BillLineItemParam> items,
  }) async {
    return db.transaction(() async {
      // 1. Create the tagihan_siswa header.
      final tagihanId = await tagihanDao.insertTagihanSiswa(
        TagihanSiswaCompanion.insert(
          siswaId: siswaId,
          periode: periode,
        ),
      );

      final itemIds = <int>[];

      // 2. For each line item, resolve the effective tariff and snapshot.
      for (final param in items) {
        final resolved = await tariffResolver.resolve(
          siswaId: siswaId,
          kategoriBiayaId: param.kategoriBiayaId,
          tingkat: tingkat,
        );

        final nominalAwal = resolved.effectiveNominal;
        final nominalDiskon = param.nominalDiskon;
        // PRD Formula: nominal_akhir = max(0, nominalAwal - nominalDiskon)
        final nominalAkhir = (nominalAwal - nominalDiskon).clamp(0, nominalAwal);

        // 3. Write the SNAPSHOTTED values directly into tagihan_item.
        //    These values are IMMUTABLE after this write.
        final itemId = await tagihanDao.insertTagihanItem(
          TagihanItemCompanion.insert(
            tagihanId: tagihanId,
            kategoriBiayaId: param.kategoriBiayaId,
            namaItem: param.namaItem,
            nominalAwal: nominalAwal,
            nominalDiskon: nominalDiskon,
            nominalAkhir: nominalAkhir,
          ),
        );

        itemIds.add(itemId);
      }

      return BillGenerationResult(
        tagihanSiswaId: tagihanId,
        itemIds: itemIds,
      );
    });
  }

  /// Calculates the PPDB wave discount for a given [registrationDate].
  /// PRD Section 7, Epic 3, F3.2 Wave Discount Matrix.
  static WaveDiscount calculateWaveDiscount(DateTime registrationDate) {
    // Wave 1: Oct 1 - Dec 31, 2026
    final wave1Start = DateTime(2026, 10, 1);
    final wave1End = DateTime(2026, 12, 31, 23, 59, 59);

    // Wave 2: Jan 1 - Mar 31, 2027
    final wave2Start = DateTime(2027, 1, 1);
    final wave2End = DateTime(2027, 3, 31, 23, 59, 59);

    // Wave 3: Apr 1 - Jun 30, 2027
    final wave3Start = DateTime(2027, 4, 1);
    final wave3End = DateTime(2027, 6, 30, 23, 59, 59);

    if (!registrationDate.isBefore(wave1Start) &&
        !registrationDate.isAfter(wave1End)) {
      return const WaveDiscount(
        wave: 1,
        pendaftaranDiskon: 100000, // 100% free
        infaqDiskon: 400000,       // 100% free
        sppDiskon: 150000,         // 100% free
      );
    } else if (!registrationDate.isBefore(wave2Start) &&
        !registrationDate.isAfter(wave2End)) {
      return const WaveDiscount(
        wave: 2,
        pendaftaranDiskon: 100000, // 100% free
        infaqDiskon: 200000,       // 50% discount
        sppDiskon: 75000,          // 50% discount
      );
    } else if (!registrationDate.isBefore(wave3Start) &&
        !registrationDate.isAfter(wave3End)) {
      return const WaveDiscount(
        wave: 3,
        pendaftaranDiskon: 100000, // 100% free
        infaqDiskon: 200000,       // 50% discount
        sppDiskon: 0,              // Normal 100%
      );
    }

    // Outside any PPDB wave -> no discount
    return const WaveDiscount(
      wave: 0,
      pendaftaranDiskon: 0,
      infaqDiskon: 0,
      sppDiskon: 0,
    );
  }
}

/// Discount values for a PPDB admission wave.
class WaveDiscount {
  const WaveDiscount({
    required this.wave,
    required this.pendaftaranDiskon,
    required this.infaqDiskon,
    required this.sppDiskon,
  });

  final int wave; // 0 = no wave, 1/2/3 = PPDB wave
  final int pendaftaranDiskon;
  final int infaqDiskon;
  final int sppDiskon;

  bool get hasDiscount =>
      pendaftaranDiskon > 0 || infaqDiskon > 0 || sppDiskon > 0;
}
