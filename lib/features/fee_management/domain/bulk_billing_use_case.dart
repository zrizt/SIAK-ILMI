import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/database/daos/tagihan_dao.dart';
import '../../../core/database/daos/tarif_dao.dart';
import 'bill_generator_engine.dart';

final bulkBillingUseCaseProvider = Provider<BulkBillingUseCase>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BulkBillingUseCase(
    siswaDao: SiswaDao(db),
    tagihanDao: TagihanDao(db),
    tarifDao: TarifDao(db),
    billEngine: ref.watch(billGeneratorEngineProvider),
  );
});

const List<String> _indonesianMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Parameters for a bulk-semester billing run.
class BulkBillingParams {
  const BulkBillingParams({
    required this.semesterLabel,
    required this.months,
    required this.sppKategoriBiayaId,
    required this.createdBy,
  });

  /// Human-readable semester label, e.g. 'Semester 1 TA 2026/2027'.
  final String semesterLabel;

  /// Month/year pairs to generate (6 for a full semester).
  final List<(int month, int year)> months;

  /// Foreign key to kategori_biaya for SPP.
  final int sppKategoriBiayaId;

  /// Operator/admin name string recorded in audit log.
  final String createdBy;
}

/// Result summary from a bulk billing run.
class BulkBillingResult {
  const BulkBillingResult({
    required this.successCount,
    required this.skippedCount,
    required this.failedCount,
    required this.failedNames,
  });

  /// Number of new tagihan_item rows created.
  final int successCount;

  /// Bills skipped because they already existed (duplicate guard).
  final int skippedCount;

  /// Bills that failed due to an unexpected error.
  final int failedCount;

  /// Human-readable list of failed student+periode combinations.
  final List<String> failedNames;
}

/// Generates SPP semester bills for all AKTIF students in a single batch.
///
/// For each student × each month in the semester:
///   1. Check if tagihan_item already exists for that (siswaId, periode, kategoriBiayaId).
///   2. If yes → skip (increment skippedCount).
///   3. If no  → call [BillGeneratorEngine.generateBill] atomically.
///
/// PRD Non-Negotiables preserved:
/// - Each month is a separate tagihan_siswa so AC-05 partial installments work.
/// - Historical snapshots (nominal_awal/akhir) are immutable.
/// - Inactive students are skipped by bill engine validation.
class BulkBillingUseCase {
  const BulkBillingUseCase({
    required this.siswaDao,
    required this.tagihanDao,
    required this.tarifDao,
    required this.billEngine,
  });

  final SiswaDao siswaDao;
  final TagihanDao tagihanDao;
  final TarifDao tarifDao;
  final BillGeneratorEngine billEngine;

  Future<BulkBillingResult> execute(BulkBillingParams params) async {
    // 1. Fetch all currently AKTIF students
    final allStudents = await siswaDao.getActiveSiswa();

    int success = 0;
    int skipped = 0;
    int failed = 0;
    final failedNames = <String>[];

    // 2. For each student × each month in the semester
    for (final student in allStudents) {
      for (final (month, year) in params.months) {
        final monthName = _indonesianMonths[month - 1];
        final periode = 'SPP $monthName $year';

        try {
          // 3. Duplicate guard
          final alreadyBilled = await tagihanDao.itemExistsForPeriodeAndKategori(
            student.id,
            periode,
            params.sppKategoriBiayaId,
          );

          if (alreadyBilled) {
            skipped++;
            continue;
          }

          // 4. Generate bill (atomic inside BillGeneratorEngine)
          // kelasId == tingkat per seeder convention (grade 1 → kelas_id 1, etc.)
          await billEngine.generateBill(
            siswaId: student.id,
            tingkat: student.kelasId,
            periode: periode,
            items: [
              BillLineItemParam(
                kategoriBiayaId: params.sppKategoriBiayaId,
                namaItem: 'SPP $monthName $year',
                nominalDiskon: 0,
              ),
            ],
          );
          success++;
        } catch (e) {
          failed++;
          failedNames.add('${student.namaLengkap} ($periode): $e');
        }
      }
    }

    return BulkBillingResult(
      successCount: success,
      skippedCount: skipped,
      failedCount: failed,
      failedNames: failedNames,
    );
  }
}
