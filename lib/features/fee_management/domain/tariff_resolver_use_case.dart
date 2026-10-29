import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/tarif_dao.dart';
import '../../../core/errors/app_exception.dart';

final tariffResolverUseCaseProvider = Provider<TariffResolverUseCase>(
  (ref) => TariffResolverUseCase(TarifDao(ref.watch(appDatabaseProvider))),
);

/// Resolved tariff result returned by [TariffResolverUseCase].
class ResolvedTariff {
  const ResolvedTariff({
    required this.effectiveNominal,
    required this.isCustomOverride,
  });

  /// The effective base tariff (before PPDB wave discount).
  final int effectiveNominal;

  /// True if this came from skema_pembayaran_siswa (custom override).
  final bool isCustomOverride;
}

/// Implements PRD Section 7, Epic 3, F3.1 Tariff Priority Resolution:
///
/// Resolution order:
///   1. skema_pembayaran_siswa.nominal_kustom  (student-specific custom rate)
///   2. tarif_master.nominal                   (school-wide standard rate)
///
/// Throws [NotFoundException] if no rate is found for the given parameters.
class TariffResolverUseCase {
  const TariffResolverUseCase(this._tarifDao);

  final TarifDao _tarifDao;

  /// Resolves the effective base tariff for a student and fee category.
  ///
  /// [siswaId] - Student primary key
  /// [kategoriBiayaId] - Fee category primary key
  /// [tingkat] - Grade level (1-9) for master tariff lookup
  Future<ResolvedTariff> resolve({
    required int siswaId,
    required int kategoriBiayaId,
    required int tingkat,
  }) async {
    // Priority 1: Check for custom student-specific override
    final customRate = await _tarifDao.getCustomRate(
      siswaId: siswaId,
      kategoriBiayaId: kategoriBiayaId,
    );

    if (customRate != null) {
      return ResolvedTariff(
        effectiveNominal: customRate.nominalKustom,
        isCustomOverride: true,
      );
    }

    // Priority 2: Fall back to master tariff
    final masterTarif = await _tarifDao.getStandardTarif(
      kategoriBiayaId: kategoriBiayaId,
      tingkat: tingkat,
    );

    if (masterTarif != null) {
      return ResolvedTariff(
        effectiveNominal: masterTarif.nominal,
        isCustomOverride: false,
      );
    }

    throw NotFoundException(
      'Tarif tidak ditemukan untuk kategori ID $kategoriBiayaId '
      'dan tingkat $tingkat.',
    );
  }
}
