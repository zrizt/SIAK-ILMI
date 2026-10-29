import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/errors/app_exception.dart';

final autoNisGeneratorUseCaseProvider = Provider<AutoNisGeneratorUseCase>(
  (ref) => AutoNisGeneratorUseCase(SiswaDao(ref.watch(appDatabaseProvider))),
);

/// Generates student NIS following the formula:
/// NIS = [YY][SchoolCode][Sequence]
///
/// - YY: 2-digit entry year (e.g., 26 for 2026)
/// - SchoolCode: 1 (SD IT Baitul Akbar) or 2 (SMP IT Darul Ilmi)
/// - Sequence: 3-digit zero-padded integer (001-999), scoped per school+year
///
/// Example: 25th SD student in 2026 -> '261025'
///          12th SMP student in 2026 -> '262012'
class AutoNisGeneratorUseCase {
  const AutoNisGeneratorUseCase(this._siswaDao);

  final SiswaDao _siswaDao;

  /// Generates the next available NIS for [sekolahId] and [tahunMasuk].
  ///
  /// Throws [NisGenerationException] if the sequence has reached 999.
  Future<String> generate({
    required int sekolahId,
    required int kodeSekolah, // 1 or 2
    required int tahunMasuk,
  }) async {
    final existingCount =
        await _siswaDao.countBySekolahAndYear(sekolahId, tahunMasuk);
    final nextSequence = existingCount + 1;

    if (nextSequence > 999) {
      throw const NisGenerationException(
        'Nomor urut NIS melebihi batas maksimum 999 untuk sekolah dan tahun ini.',
      );
    }

    final yy = (tahunMasuk % 100).toString().padLeft(2, '0');
    final schoolCode = kodeSekolah.toString();
    final seq = nextSequence.toString().padLeft(3, '0');

    return '$yy$schoolCode$seq';
  }
}
