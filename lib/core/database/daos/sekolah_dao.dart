import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sekolah_table.dart';

part 'sekolah_dao.g.dart';

@DriftAccessor(tables: [Sekolah])
class SekolahDao extends DatabaseAccessor<AppDatabase> with _$SekolahDaoMixin {
  SekolahDao(super.db);

  /// Returns all school entities.
  Future<List<SekolahData>> getAllSekolah() => select(sekolah).get();

  /// Watches all schools as a reactive stream.
  Stream<List<SekolahData>> watchAllSekolah() => select(sekolah).watch();

  /// Finds a school by its unique [kodeSekolah] (1=SD, 2=SMP).
  Future<SekolahData?> getByKode(int kode) =>
      (select(sekolah)..where((s) => s.kodeSekolah.equals(kode)))
          .getSingleOrNull();
}
