import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Riverpod provider for the [DatabaseSeeder].
final databaseSeederProvider = Provider<DatabaseSeeder>(
  (ref) => DatabaseSeeder(ref.watch(appDatabaseProvider)),
);

/// Seeds the database with initial data on first launch:
/// - 2 school entities (SD & SMP)
/// - Active academic year 2026/2027
/// - 15 grade/class records (SD: 1-6, SMP: 7-9)
/// - 3 fee categories (SPP Rutin, Infaq Gedung Sekali, Pendaftaran Sekali)
/// - Standard tariffs per grade level
///
/// This is idempotent: uses INSERT OR IGNORE semantics so re-runs are safe.
class DatabaseSeeder {
  const DatabaseSeeder(this._db);

  final AppDatabase _db;

  Future<void> seedIfEmpty() async {
    final sekolahCountExpr = _db.sekolah.id.count();
    final sekolahCountQuery = _db.selectOnly(_db.sekolah)
      ..addColumns([sekolahCountExpr]);
    final sekolahCountRow = await sekolahCountQuery.getSingle();
    final sekolahCount = sekolahCountRow.read(sekolahCountExpr) ?? 0;

    if (sekolahCount > 0) return; // Already seeded

    await _db.transaction(() async {
      await _seedSekolah();
      await _seedTahunAjaran();
      await _seedKelas();
      await _seedKategoriBiaya();
      await _seedTarifMaster();
    });
  }

  // ─────────────────────────────────────────
  // 1. Schools
  // ─────────────────────────────────────────
  Future<void> _seedSekolah() async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.sekolah,
        [
          SekolahCompanion.insert(
            namaSekolah: 'SD IT Baitul Akbar Parabek',
            kodeSekolah: 1,
            jenjang: 'SD',
          ),
          SekolahCompanion.insert(
            namaSekolah: 'SMP IT Darul Ilmi',
            kodeSekolah: 2,
            jenjang: 'SMP',
          ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  // ─────────────────────────────────────────
  // 2. Academic Year
  // ─────────────────────────────────────────
  Future<void> _seedTahunAjaran() async {
    await _db.into(_db.tahunAjaran).insertOnConflictUpdate(
          TahunAjaranCompanion.insert(
            namaTa: '2026/2027',
            isAktif: const Value(1),
          ),
        );
  }

  // ─────────────────────────────────────────
  // 3. Classes / Grades
  // ─────────────────────────────────────────
  Future<void> _seedKelas() async {
    // SD IT Baitul Akbar (sekolah_id = 1, grades 1-6)
    final sdKelas = List.generate(6, (i) {
      final tingkat = i + 1;
      return KelasCompanion.insert(
        sekolahId: 1,
        tingkat: tingkat,
        namaKelas: 'Kelas $tingkat',
      );
    });

    // SMP IT Darul Ilmi (sekolah_id = 2, grades 7-9)
    final smpKelas = List.generate(3, (i) {
      final tingkat = i + 7;
      return KelasCompanion.insert(
        sekolahId: 2,
        tingkat: tingkat,
        namaKelas: 'Kelas $tingkat',
      );
    });

    await _db.batch((batch) {
      batch.insertAll(
        _db.kelas,
        [...sdKelas, ...smpKelas],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  // ─────────────────────────────────────────
  // 4. Fee Categories
  // ─────────────────────────────────────────
  Future<void> _seedKategoriBiaya() async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.kategoriBiaya,
        [
          KategoriBiayaCompanion.insert(
            namaBiaya: 'SPP',
            tipe: 'Rutin',
          ),
          KategoriBiayaCompanion.insert(
            namaBiaya: 'Infaq Gedung',
            tipe: 'Sekali',
          ),
          KategoriBiayaCompanion.insert(
            namaBiaya: 'Pendaftaran',
            tipe: 'Sekali',
          ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  // ─────────────────────────────────────────
  // 5. Master Tariffs
  //
  // SD Grades 1-6:
  //   SPP           = Rp 150,000 / month
  //   Infaq Gedung  = Rp 400,000 (one-time)
  //   Pendaftaran   = Rp 100,000 (one-time)
  //
  // SMP Grades 7-9:
  //   SPP           = Rp 150,000 / month
  //   Infaq Gedung  = Rp 400,000 (one-time)
  //   Pendaftaran   = Rp 100,000 (one-time)
  //
  // kategori_biaya IDs expected after seed: SPP=1, Infaq Gedung=2, Pendaftaran=3
  // ─────────────────────────────────────────
  Future<void> _seedTarifMaster() async {
    const sppId = 1;
    const infaqId = 2;
    const pendaftaranId = 3;

    const sppNominal = 150000;
    const infaqNominal = 400000;
    const pendaftaranNominal = 100000;

    final entries = <TarifMasterCompanion>[];

    for (int tingkat = 1; tingkat <= 9; tingkat++) {
      entries.addAll([
        TarifMasterCompanion.insert(
          kategoriBiayaId: sppId,
          tingkat: tingkat,
          nominal: sppNominal,
        ),
        TarifMasterCompanion.insert(
          kategoriBiayaId: infaqId,
          tingkat: tingkat,
          nominal: infaqNominal,
        ),
        TarifMasterCompanion.insert(
          kategoriBiayaId: pendaftaranId,
          tingkat: tingkat,
          nominal: pendaftaranNominal,
        ),
      ]);
    }

    await _db.batch((batch) {
      batch.insertAll(
        _db.tarifMaster,
        entries,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}
