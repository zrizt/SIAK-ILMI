import 'package:drift/drift.dart';
import 'tagihan_siswa_table.dart';
import 'kategori_biaya_table.dart';

@DataClassName('TagihanItemData')
class TagihanItem extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tagihanId =>
      integer().references(TagihanSiswa, #id, onDelete: KeyAction.cascade)();
  IntColumn get kategoriBiayaId =>
      integer().references(KategoriBiaya, #id, onDelete: KeyAction.restrict)();
  TextColumn get namaItem => text()(); // Snapshotted title e.g. 'SPP Juli 2026'
  IntColumn get nominalAwal => integer()(); // Snapshotted base price
  IntColumn get nominalDiskon =>
      integer().withDefault(const Constant(0))(); // Snapshotted discount
  IntColumn get nominalAkhir => integer()(); // Snapshotted final net (awal - diskon)
  IntColumn get terbayar =>
      integer().withDefault(const Constant(0))(); // Accumulated paid amount
  IntColumn get isLunas =>
      integer().withDefault(const Constant(0))(); // 1=true when terbayar==nominalAkhir
}
