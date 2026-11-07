import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/operator_dao.dart';
import '../../../core/database/daos/pembayaran_dao.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../domain/receipt_model.dart';

final receiptModelFactoryProvider = Provider<ReceiptModelFactory>(
  (ref) => ReceiptModelFactory(ref.watch(appDatabaseProvider)),
);

/// Helper service to assemble [ReceiptModel] instances from SQLite tables.
class ReceiptModelFactory {
  ReceiptModelFactory(this._db);

  final AppDatabase _db;
  late final PembayaranDao _pembayaranDao = PembayaranDao(_db);
  late final SiswaDao _siswaDao = SiswaDao(_db);
  late final OperatorDao _operatorDao = OperatorDao(_db);

  /// Assembles a [ReceiptModel] from transaction ID.
  Future<ReceiptModel?> buildFromTransactionId(int transaksiId) async {
    final txnQuery = _db.select(_db.pembayaranTransaksi)
      ..where((t) => t.id.equals(transaksiId));
    final txn = await txnQuery.getSingleOrNull();
    if (txn == null) return null;

    return buildFromTransaction(txn);
  }

  /// Assembles a [ReceiptModel] from an existing [PembayaranTransaksiData].
  Future<ReceiptModel> buildFromTransaction(
    PembayaranTransaksiData txn,
  ) async {
    // 1. Fetch Student
    final siswa = await _siswaDao.getById(txn.siswaId);

    // 2. Fetch School and Class
    String namaSekolah = 'Sekolah Darul Ilmi';
    String namaKelas = 'Kelas';

    if (siswa != null) {
      final sekolah = await (_db.select(_db.sekolah)
            ..where((s) => s.id.equals(siswa.sekolahId)))
          .getSingleOrNull();
      if (sekolah != null) {
        namaSekolah = sekolah.namaSekolah;
      }

      final kelas = await (_db.select(_db.kelas)
            ..where((k) => k.id.equals(siswa.kelasId)))
          .getSingleOrNull();
      if (kelas != null) {
        namaKelas = kelas.namaKelas;
      }
    }

    // 3. Fetch allocations and corresponding tagihan items
    final allocations =
        await _pembayaranDao.getAlokasiByTransaksi(txn.id);

    final lineItems = <ReceiptLineItem>[];
    for (final alokasi in allocations) {
      final item = await (_db.select(_db.tagihanItem)
            ..where((i) => i.id.equals(alokasi.tagihanItemId)))
          .getSingleOrNull();

      if (item != null) {
        final remaining = (item.nominalAkhir - item.terbayar).clamp(0, item.nominalAkhir);
        lineItems.add(
          ReceiptLineItem(
            namaItem: item.namaItem,
            nominalDibayar: alokasi.nominalDialokasikan,
            sisaTagihan: remaining,
          ),
        );
      }
    }

    // 4. Fetch Operator NIP if available
    String? operatorNip;
    final op = await _operatorDao.getByUsername(txn.createdBy);
    if (op != null) {
      operatorNip = op.nip;
    } else {
      final allOps = await _operatorDao.getAllOperators();
      final match = allOps.where((o) => o.fullName == txn.createdBy).firstOrNull;
      operatorNip = match?.nip;
    }

    return ReceiptModel(
      nomorKuitansi: txn.nomorKuitansi,
      tanggalBayar: DateTime.tryParse(txn.tanggalBayar) ?? DateTime.now(),
      namaLengkap: siswa?.namaLengkap ?? 'Siswa',
      nis: siswa?.nis ?? '-',
      namaSekolah: namaSekolah,
      kelas: namaKelas,
      metodeBayar: txn.metodeBayar,
      items: lineItems,
      totalBayar: txn.totalBayar,
      createdBy: txn.createdBy,
      operatorNip: operatorNip,
    );
  }
}
