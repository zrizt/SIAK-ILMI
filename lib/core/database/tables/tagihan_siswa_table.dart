import 'package:drift/drift.dart';
import 'siswa_table.dart';

@DataClassName('TagihanSiswaData')
class TagihanSiswa extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get siswaId =>
      integer().references(Siswa, #id, onDelete: KeyAction.restrict)();
  TextColumn get periode => text()(); // e.g. 'Juli 2026' or 'PPDB 2026/2027'
  IntColumn get isLunas =>
      integer().withDefault(const Constant(0))(); // 1=true, 0=false
}
