import 'package:drift/drift.dart';

@DataClassName('KategoriBiayaData')
class KategoriBiaya extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get namaBiaya => text()(); // 'SPP', 'Infaq Gedung', 'Pendaftaran'
  TextColumn get tipe => text()(); // 'Rutin' or 'Sekali'
}
