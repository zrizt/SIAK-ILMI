import 'package:drift/drift.dart';

@DataClassName('TahunAjaranData')
class TahunAjaran extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get namaTa => text()(); // e.g. '2026/2027'
  IntColumn get isAktif =>
      integer().withDefault(const Constant(1))(); // 1=true, 0=false
}
