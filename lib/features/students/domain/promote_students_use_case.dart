import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/services/audit_logger_service.dart';

final promoteStudentsUseCaseProvider = Provider<PromoteStudentsUseCase>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PromoteStudentsUseCase(
    db: db,
    siswaDao: SiswaDao(db),
    auditLogger: ref.watch(auditLoggerProvider),
  );
});

class StudentPromotionCandidate {
  StudentPromotionCandidate({
    required this.student,
    this.currentKelas,
    this.targetKelas,
    required this.currentTingkat,
    this.targetTingkat,
    required this.willGraduate,
    this.isRetained = false,
  });

  final SiswaData student;
  final KelasData? currentKelas;
  final KelasData? targetKelas;
  final int currentTingkat;
  final int? targetTingkat;
  final bool willGraduate;
  bool isRetained;

  /// Action description for UI display
  String get actionLabel {
    if (isRetained) return 'Tinggal di Kelas $currentTingkat';
    if (willGraduate) return 'Lulus';
    if (targetKelas != null) return 'Naik ke ${targetKelas!.namaKelas}';
    return 'Kelas $currentTingkat';
  }
}

class PromotionExecutionResult {
  const PromotionExecutionResult({
    required this.totalProcessed,
    required this.promotedCount,
    required this.graduatedCount,
    required this.retainedCount,
    required this.newAcademicYear,
  });

  final int totalProcessed;
  final int promotedCount;
  final int graduatedCount;
  final int retainedCount;
  final String newAcademicYear;
}

class PromoteStudentsUseCase {
  const PromoteStudentsUseCase({
    required AppDatabase db,
    required SiswaDao siswaDao,
    required AuditLoggerService auditLogger,
  })  : _db = db,
        _siswaDao = siswaDao,
        _auditLogger = auditLogger;

  final AppDatabase _db;
  final SiswaDao _siswaDao;
  final AuditLoggerService _auditLogger;

  /// Retrieves the active academic year (e.g. '2026/2027').
  Future<String> getActiveAcademicYear() async {
    final active = await (_db.select(_db.tahunAjaran)
          ..where((t) => t.isAktif.equals(1)))
        .getSingleOrNull();
    return active?.namaTa ?? '2026/2027';
  }

  /// Calculates the next academic year from a given TA string (e.g. '2026/2027' -> '2027/2028').
  String computeNextAcademicYear(String currentTa) {
    final parts = currentTa.split('/');
    if (parts.length == 2) {
      final y1 = int.tryParse(parts[0].trim());
      final y2 = int.tryParse(parts[1].trim());
      if (y1 != null && y2 != null) {
        return '${y1 + 1}/${y2 + 1}';
      }
    }
    final now = DateTime.now().year;
    return '${now + 1}/${now + 2}';
  }

  /// Evaluates all active students and returns their promotion candidates with target classes.
  Future<List<StudentPromotionCandidate>> getPromotionCandidates({
    int? sekolahId,
  }) async {
    // 1. Fetch active students
    final students = await (_db.select(_db.siswa)
          ..where((s) {
            var predicate = s.status.equals('AKTIF');
            if (sekolahId != null) {
              predicate = predicate & s.sekolahId.equals(sekolahId);
            }
            return predicate;
          }))
        .get();

    // 2. Fetch all classes
    final classes = await _db.select(_db.kelas).get();

    final candidates = <StudentPromotionCandidate>[];

    for (final s in students) {
      final currentKelas = classes.where((k) => k.id == s.kelasId).firstOrNull;
      final currentTingkat = currentKelas?.tingkat ?? 1;
      final schoolId = s.sekolahId;

      bool willGraduate = false;
      int? targetTingkat;
      KelasData? targetKelas;

      if (schoolId == 1) {
        // SD IT: Tingkat 1-6
        if (currentTingkat >= 6) {
          willGraduate = true;
        } else {
          targetTingkat = currentTingkat + 1;
          targetKelas = classes
              .where((k) => k.sekolahId == 1 && k.tingkat == targetTingkat)
              .firstOrNull;
        }
      } else if (schoolId == 2) {
        // SMP IT: Tingkat 7-9
        if (currentTingkat >= 9) {
          willGraduate = true;
        } else {
          targetTingkat = currentTingkat + 1;
          targetKelas = classes
              .where((k) => k.sekolahId == 2 && k.tingkat == targetTingkat)
              .firstOrNull;
        }
      }

      candidates.add(
        StudentPromotionCandidate(
          student: s,
          currentKelas: currentKelas,
          targetKelas: targetKelas,
          currentTingkat: currentTingkat,
          targetTingkat: targetTingkat,
          willGraduate: willGraduate,
          isRetained: false,
        ),
      );
    }

    // Sort by school, tingkat descending, student name
    candidates.sort((a, b) {
      final schoolComp = a.student.sekolahId.compareTo(b.student.sekolahId);
      if (schoolComp != 0) return schoolComp;
      final tingkatComp = b.currentTingkat.compareTo(a.currentTingkat);
      if (tingkatComp != 0) return tingkatComp;
      return a.student.namaLengkap.compareTo(b.student.namaLengkap);
    });

    return candidates;
  }

  /// Executes grade promotion atomically across all candidates and updates academic year.
  Future<PromotionExecutionResult> executePromotion({
    required List<StudentPromotionCandidate> candidates,
    required String newAcademicYear,
    required String operatorName,
  }) async {
    return _db.transaction(() async {
      int promotedCount = 0;
      int graduatedCount = 0;
      int retainedCount = 0;

      for (final candidate in candidates) {
        if (candidate.isRetained) {
          retainedCount++;
          // Retained: status remains AKTIF, kelasId remains unchanged.
        } else if (candidate.willGraduate) {
          await _siswaDao.updateKelasAndStatus(
            candidate.student.id,
            status: 'LULUS',
          );
          graduatedCount++;
        } else if (candidate.targetKelas != null) {
          await _siswaDao.updateKelasAndStatus(
            candidate.student.id,
            kelasId: candidate.targetKelas!.id,
            status: 'AKTIF',
          );
          promotedCount++;
        }
      }

      // Transition academic year:
      // Set all existing academic years to isAktif = 0
      await (_db.update(_db.tahunAjaran))
          .write(const TahunAjaranCompanion(isAktif: Value(0)));

      // Upsert target academic year with isAktif = 1
      final existingTa = await (_db.select(_db.tahunAjaran)
            ..where((t) => t.namaTa.equals(newAcademicYear)))
          .getSingleOrNull();

      if (existingTa != null) {
        await (_db.update(_db.tahunAjaran)
              ..where((t) => t.id.equals(existingTa.id)))
            .write(const TahunAjaranCompanion(isAktif: Value(1)));
      } else {
        await _db.into(_db.tahunAjaran).insert(
              TahunAjaranCompanion.insert(
                namaTa: newAcademicYear,
                isAktif: const Value(1),
              ),
            );
      }

      // Log audit
      await _auditLogger.log(
        userRole: operatorName,
        actionType: 'KENAIKAN_KELAS',
        entityAffected: 'siswa',
        details:
            'Kenaikan kelas ke TA $newAcademicYear: $promotedCount naik kelas, '
            '$graduatedCount lulus, $retainedCount tinggal kelas (total: ${candidates.length})',
      );

      return PromotionExecutionResult(
        totalProcessed: candidates.length,
        promotedCount: promotedCount,
        graduatedCount: graduatedCount,
        retainedCount: retainedCount,
        newAcademicYear: newAcademicYear,
      );
    });
  }
}
