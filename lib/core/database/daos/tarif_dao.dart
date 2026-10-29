import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tarif_master_table.dart';
import '../tables/skema_pembayaran_siswa_table.dart';
import '../tables/kategori_biaya_table.dart';

part 'tarif_dao.g.dart';

@DriftAccessor(tables: [TarifMaster, SkemaPembayaranSiswa, KategoriBiaya])
class TarifDao extends DatabaseAccessor<AppDatabase> with _$TarifDaoMixin {
  TarifDao(super.db);

  // ────────── Tarif Master (standard rates) ──────────

  /// Returns the standard tariff for a given category and grade level.
  Future<TarifMasterData?> getStandardTarif({
    required int kategoriBiayaId,
    required int tingkat,
  }) =>
      (select(tarifMaster)
            ..where(
              (t) =>
                  t.kategoriBiayaId.equals(kategoriBiayaId) &
                  t.tingkat.equals(tingkat),
            ))
          .getSingleOrNull();

  /// Fetches all master tariffs.
  Stream<List<TarifMasterData>> watchAllTarifMaster() =>
      select(tarifMaster).watch();

  /// Upserts a master tariff record.
  Future<void> upsertTarifMaster(TarifMasterCompanion entry) =>
      into(tarifMaster).insertOnConflictUpdate(entry);

  // ────────── Skema Pembayaran Siswa (custom overrides) ──────────

  /// Returns a custom rate override for a specific student + fee category.
  /// Returns null if no custom rate is configured (fallback to master tariff).
  Future<SkemaPembayaranSiswaData?> getCustomRate({
    required int siswaId,
    required int kategoriBiayaId,
  }) =>
      (select(skemaPembayaranSiswa)
            ..where(
              (s) =>
                  s.siswaId.equals(siswaId) &
                  s.kategoriBiayaId.equals(kategoriBiayaId),
            ))
          .getSingleOrNull();

  /// Watches all custom rates for a student.
  Stream<List<SkemaPembayaranSiswaData>> watchCustomRatesBySiswa(
          int siswaId) =>
      (select(skemaPembayaranSiswa)
            ..where((s) => s.siswaId.equals(siswaId)))
          .watch();

  /// Inserts or updates a custom rate override.
  Future<void> upsertCustomRate(SkemaPembayaranSiswaCompanion entry) =>
      into(skemaPembayaranSiswa).insertOnConflictUpdate(entry);

  /// Deletes a custom rate override (reverts student to standard tariff).
  Future<int> deleteCustomRate(int id) =>
      (delete(skemaPembayaranSiswa)
            ..where((s) => s.id.equals(id)))
          .go();

  // ────────── Fee Categories ──────────

  Future<List<KategoriBiayaData>> getAllKategori() =>
      select(kategoriBiaya).get();

  Stream<List<KategoriBiayaData>> watchAllKategori() =>
      select(kategoriBiaya).watch();
}
