import 'package:drift/drift.dart';
import 'kategori_biaya_table.dart';

@DataClassName('TarifMasterData')
class TarifMaster extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get kategoriBiayaId =>
      integer().references(KategoriBiaya, #id, onDelete: KeyAction.restrict)();
  IntColumn get tingkat => integer()(); // Target grade level 1..9
  IntColumn get nominal => integer()(); // Baseline price in IDR
}
