import 'package:drift/drift.dart';

@DataClassName('SekolahData')
class Sekolah extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get namaSekolah => text()();
  IntColumn get kodeSekolah => integer().unique()(); // 1=SD IT Baitul Akbar, 2=SMP IT Darul Ilmi
  TextColumn get jenjang => text()(); // 'SD' or 'SMP'
}
