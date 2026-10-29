import 'package:drift/drift.dart';
import 'pembayaran_transaksi_table.dart';
import 'tagihan_item_table.dart';

@DataClassName('AlokasiPembayaranData')
class AlokasiPembayaran extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transaksiId =>
      integer().references(PembayaranTransaksi, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagihanItemId =>
      integer().references(TagihanItem, #id, onDelete: KeyAction.restrict)();
  IntColumn get nominalDialokasikan => integer()(); // Amount routed to this bill item
}
