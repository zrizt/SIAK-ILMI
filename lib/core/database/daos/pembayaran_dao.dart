import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pembayaran_transaksi_table.dart';
import '../tables/alokasi_pembayaran_table.dart';

part 'pembayaran_dao.g.dart';

/// Combined result of a transaction and its allocation records.
class TransaksiWithAlokasi {
  const TransaksiWithAlokasi({
    required this.transaksi,
    required this.alokasi,
  });

  final PembayaranTransaksiData transaksi;
  final List<AlokasiPembayaranData> alokasi;
}

@DriftAccessor(tables: [PembayaranTransaksi, AlokasiPembayaran])
class PembayaranDao extends DatabaseAccessor<AppDatabase>
    with _$PembayaranDaoMixin {
  PembayaranDao(super.db);

  // ────────── Read ──────────

  /// Watches all VALID transactions for a student (Payment History – Tab 2).
  Stream<List<PembayaranTransaksiData>> watchTransaksiByStudent(int siswaId) =>
      (select(pembayaranTransaksi)
            ..where(
              (t) => t.siswaId.equals(siswaId),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.tanggalBayar)]))
          .watch();

  /// Returns all allocation records for a single transaction.
  Future<List<AlokasiPembayaranData>> getAlokasiByTransaksi(
          int transaksiId) =>
      (select(alokasiPembayaran)
            ..where((a) => a.transaksiId.equals(transaksiId)))
          .get();

  /// Fetches a transaction by nomor_kuitansi (for receipt lookup).
  Future<PembayaranTransaksiData?> getByNomorKuitansi(String nomor) =>
      (select(pembayaranTransaksi)
            ..where((t) => t.nomorKuitansi.equals(nomor)))
          .getSingleOrNull();

  /// Returns the count of today's transactions for nomor_kuitansi generation.
  /// Counts all transactions (both VALID and VOID) to prevent receipt number collision.
  Future<int> countTransaksiToday(String datePrefix) async {
    final countExpr = pembayaranTransaksi.id.count();
    final query = selectOnly(pembayaranTransaksi)
      ..addColumns([countExpr])
      ..where(
        pembayaranTransaksi.tanggalBayar.like('$datePrefix%'),
      );
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  /// Dashboard: sums total_bayar for VALID transactions in a date range.
  /// [sekolahId] = null means all schools.
  Future<int> sumTotalBayarByDateRange({
    required String startIso,
    required String endIso,
    int? sekolahId,
  }) async {
    final sumExpr = pembayaranTransaksi.totalBayar.sum();

    Expression<bool> whereClause = pembayaranTransaksi.tanggalBayar
            .isBetweenValues(startIso, endIso) &
        pembayaranTransaksi.status.equals('VALID');

    if (sekolahId != null) {
      final siswaSubquery = db.selectOnly(db.siswa)
        ..addColumns([db.siswa.id])
        ..where(db.siswa.sekolahId.equals(sekolahId));
      whereClause = whereClause &
          pembayaranTransaksi.siswaId.isInQuery(siswaSubquery);
    }

    final query = selectOnly(pembayaranTransaksi)
      ..addColumns([sumExpr])
      ..where(whereClause);

    final result = await query.getSingle();
    return result.read(sumExpr) ?? 0;
  }

  // ────────── Write ──────────

  /// Inserts a payment transaction header. Returns generated id.
  Future<int> insertTransaksi(PembayaranTransaksiCompanion entry) =>
      into(pembayaranTransaksi).insert(entry);

  /// Inserts a single allocation row.
  Future<int> insertAlokasi(AlokasiPembayaranCompanion entry) =>
      into(alokasiPembayaran).insert(entry);

  /// Marks a transaction as VOID (soft-delete; never hard-delete).
  Future<void> voidTransaksi(int transaksiId) async {
    await (update(pembayaranTransaksi)
          ..where((t) => t.id.equals(transaksiId)))
        .write(const PembayaranTransaksiCompanion(status: Value('VOID')));
  }
}
