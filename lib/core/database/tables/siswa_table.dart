import 'package:drift/drift.dart';
import 'sekolah_table.dart';
import 'kelas_table.dart';

@DataClassName('SiswaData')
class Siswa extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sekolahId =>
      integer().references(Sekolah, #id, onDelete: KeyAction.restrict)();
  TextColumn get nis => text().unique()(); // Auto-generated: e.g. '262015'
  TextColumn get nisn => text().nullable().unique()(); // Optional Dapodik NISN
  TextColumn get namaLengkap => text()();
  TextColumn get jenisKelamin => text()(); // 'L' or 'P'
  IntColumn get kelasId =>
      integer().references(Kelas, #id, onDelete: KeyAction.restrict)();
  IntColumn get tahunMasuk => integer()(); // e.g. 2026
  TextColumn get kontakWali => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('AKTIF'))(); // 'AKTIF','LULUS','PINDAH','DROP_OUT'
}
