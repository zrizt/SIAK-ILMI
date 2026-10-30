import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/services/audit_logger_service.dart';
import '../domain/auto_nis_generator_use_case.dart';

final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepository(
    siswaDao: SiswaDao(ref.watch(appDatabaseProvider)),
    nisGenerator: ref.watch(autoNisGeneratorUseCaseProvider),
    auditLogger: ref.watch(auditLoggerProvider),
  ),
);

class StudentRepository {
  const StudentRepository({
    required this.siswaDao,
    required this.nisGenerator,
    required this.auditLogger,
  });

  final SiswaDao siswaDao;
  final AutoNisGeneratorUseCase nisGenerator;
  final AuditLoggerService auditLogger;

  // ── Reads ──
  Stream<List<SiswaData>> watchActive({int? sekolahId}) {
    if (sekolahId != null) {
      return siswaDao.watchActiveSiswaBySekolah(sekolahId);
    }
    return siswaDao.watchActiveSiswa();
  }

  Future<SiswaData?> getById(int id) => siswaDao.getById(id);

  Future<SiswaData?> getByNisn(String nisn) => siswaDao.getByNisn(nisn);

  // ── Writes ──
  Future<SiswaData> registerStudent({
    required int sekolahId,
    required int kodeSekolah,
    required int tahunMasuk,
    required String namaLengkap,
    required String jenisKelamin,
    required int kelasId,
    String? nisn,
    String? kontakWali,
    required String createdBy,
  }) async {
    final nis = await nisGenerator.generate(
      sekolahId: sekolahId,
      kodeSekolah: kodeSekolah,
      tahunMasuk: tahunMasuk,
    );

    final id = await siswaDao.insertSiswa(
      SiswaCompanion.insert(
        sekolahId: sekolahId,
        nis: nis,
        nisn: Value(nisn),
        namaLengkap: namaLengkap,
        jenisKelamin: jenisKelamin,
        kelasId: kelasId,
        tahunMasuk: tahunMasuk,
        kontakWali: Value(kontakWali),
      ),
    );

    await auditLogger.log(
      userRole: createdBy,
      actionType: AuditAction.insertSiswa,
      entityAffected: 'siswa',
      entityId: id,
      details: 'NIS: $nis | Nama: $namaLengkap',
    );

    return (await siswaDao.getById(id))!;
  }

  Future<void> updateStatus(int id, String status, String updatedBy) async {
    await siswaDao.updateStatus(id, status);
    await auditLogger.log(
      userRole: updatedBy,
      actionType: AuditAction.updateSiswaStatus,
      entityAffected: 'siswa',
      entityId: id,
      details: 'New status: $status',
    );
  }

  /// Bulk import from Dapodik parse result.
  /// Skips duplicates by NISN. Returns count of inserted rows.
  Future<int> bulkImport(List<DapodikImportRow> rows, String createdBy) async {
    int inserted = 0;
    for (final row in rows) {
      if (row.nisn != null) {
        final existing = await siswaDao.getByNisn(row.nisn!);
        if (existing != null) continue; // Skip duplicate
      }
      await registerStudent(
        sekolahId: row.sekolahId,
        kodeSekolah: row.kodeSekolah,
        tahunMasuk: row.tahunMasuk,
        namaLengkap: row.namaLengkap,
        jenisKelamin: row.jenisKelamin,
        kelasId: row.kelasId,
        nisn: row.nisn,
        kontakWali: row.kontakWali,
        createdBy: createdBy,
      );
      inserted++;
    }
    return inserted;
  }
}

/// Parsed row from a Dapodik .xlsx/.csv import file.
class DapodikImportRow {
  const DapodikImportRow({
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.kelasId,
    required this.sekolahId,
    required this.kodeSekolah,
    required this.tahunMasuk,
    this.nisn,
    this.kontakWali,
  });

  final String namaLengkap;
  final String jenisKelamin; // 'L' or 'P'
  final int kelasId;
  final int sekolahId;
  final int kodeSekolah;
  final int tahunMasuk;
  final String? nisn;
  final String? kontakWali;
}
