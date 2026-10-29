import 'package:drift/drift.dart';
import 'siswa_table.dart';
import 'kategori_biaya_table.dart';

@DataClassName('SkemaPembayaranSiswaData')
class SkemaPembayaranSiswa extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get siswaId =>
      integer().references(Siswa, #id, onDelete: KeyAction.cascade)();
  IntColumn get kategoriBiayaId =>
      integer().references(KategoriBiaya, #id, onDelete: KeyAction.restrict)();
  IntColumn get nominalKustom => integer()(); // Overrides tarif_master
  TextColumn get catatan => text().nullable()();
}
