import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/siswa_table.dart';
import '../tables/kelas_table.dart';
import '../tables/sekolah_table.dart';

part 'siswa_dao.g.dart';

/// Result class for the student list join query.
class SiswaWithKelasAndSekolah {
  const SiswaWithKelasAndSekolah({
    required this.siswa,
    required this.kelas,
    required this.sekolah,
  });

  final SiswaData siswa;
  final KelasData kelas;
  final SekolahData sekolah;
}

@DriftAccessor(tables: [Siswa, Kelas, Sekolah])
class SiswaDao extends DatabaseAccessor<AppDatabase> with _$SiswaDaoMixin {
  SiswaDao(super.db);

  // ────────── Read ──────────

  /// Returns all active students (status = 'AKTIF').
  Future<List<SiswaData>> getActiveSiswa() =>
      (select(siswa)..where((s) => s.status.equals('AKTIF'))).get();

  /// Watches all active students across all schools as a reactive stream.
  Stream<List<SiswaData>> watchActiveSiswa() =>
      (select(siswa)..where((s) => s.status.equals('AKTIF'))).watch();

  /// Watches active students scoped to a specific school.
  Stream<List<SiswaData>> watchActiveSiswaBySekolah(int sekolahId) =>
      (select(siswa)
            ..where(
              (s) => s.sekolahId.equals(sekolahId) & s.status.equals('AKTIF'),
            )
            ..orderBy([(s) => OrderingTerm.asc(s.namaLengkap)]))
          .watch();

  /// Fetches a single student by their auto-generated NIS.
  Future<SiswaData?> getByNis(String nis) =>
      (select(siswa)..where((s) => s.nis.equals(nis))).getSingleOrNull();

  /// Fetches a single student by their NISN (Dapodik import deduplication).
  Future<SiswaData?> getByNisn(String nisn) =>
      (select(siswa)..where((s) => s.nisn.equals(nisn))).getSingleOrNull();

  /// Returns the student by primary key id.
  Future<SiswaData?> getById(int id) =>
      (select(siswa)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Counts existing students for a specific school AND entry year.
  /// Used by [AutoNisGeneratorUseCase] to compute the next sequence.
  Future<int> countBySekolahAndYear(int sekolahId, int tahunMasuk) async {
    final countExpr = siswa.id.count();
    final query = selectOnly(siswa)
      ..addColumns([countExpr])
      ..where(
        siswa.sekolahId.equals(sekolahId) &
            siswa.tahunMasuk.equals(tahunMasuk),
      );
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  // ────────── Write ──────────

  /// Inserts a new student and returns the generated primary key id.
  Future<int> insertSiswa(SiswaCompanion entry) =>
      into(siswa).insert(entry);

  /// Updates an existing student record.
  Future<bool> updateSiswa(SiswaData entry) =>
      update(siswa).replace(entry);

  /// Updates only the [status] field of a student (lifecycle management).
  Future<void> updateStatus(int id, String newStatus) async {
    await (update(siswa)..where((s) => s.id.equals(id))).write(
      SiswaCompanion(status: Value(newStatus)),
    );
  }
}
