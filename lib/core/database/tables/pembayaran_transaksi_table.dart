import 'package:drift/drift.dart';
import 'siswa_table.dart';

@DataClassName('PembayaranTransaksiData')
class PembayaranTransaksi extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nomorKuitansi => text().unique()(); // Format: 'KW-YYYYMMDD-XXXX'
  IntColumn get siswaId =>
      integer().references(Siswa, #id, onDelete: KeyAction.restrict)();
  TextColumn get tanggalBayar => text()(); // ISO8601 string e.g. '2026-10-29T10:15:00'
  IntColumn get totalBayar => integer()(); // Total cash inflow
  TextColumn get metodeBayar => text()(); // 'Tunai' or 'Transfer'
  TextColumn get status =>
      text().withDefault(const Constant('VALID'))(); // 'VALID' or 'VOID'
  TextColumn get createdBy => text()(); // 'Admin' or 'Kepala Sekolah'
}
