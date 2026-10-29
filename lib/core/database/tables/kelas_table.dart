import 'package:drift/drift.dart';
import 'sekolah_table.dart';

@DataClassName('KelasData')
class Kelas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sekolahId =>
      integer().references(Sekolah, #id, onDelete: KeyAction.cascade)();
  IntColumn get tingkat => integer()(); // 1-6 for SD, 7-9 for SMP
  TextColumn get namaKelas => text()();
}
