import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tagihan_siswa_table.dart';
import '../tables/tagihan_item_table.dart';
import '../tables/kategori_biaya_table.dart';

part 'tagihan_dao.g.dart';

@DriftAccessor(tables: [TagihanSiswa, TagihanItem, KategoriBiaya])
class TagihanDao extends DatabaseAccessor<AppDatabase>
    with _$TagihanDaoMixin {
  TagihanDao(super.db);

  // ────────── TagihanSiswa (Header) ──────────

  /// Inserts a bill header and returns generated id.
  Future<int> insertTagihanSiswa(TagihanSiswaCompanion entry) =>
      into(tagihanSiswa).insert(entry);

  /// Fetches all bill headers for a student.
  Future<List<TagihanSiswaData>> getTagihanByStudent(int siswaId) =>
      (select(tagihanSiswa)..where((t) => t.siswaId.equals(siswaId))).get();

  // ────────── TagihanItem (Detail / Checklist rows) ──────────

  /// Inserts a snapshotted bill item and returns generated id.
  Future<int> insertTagihanItem(TagihanItemCompanion entry) =>
      into(tagihanItem).insert(entry);

  /// Fetches ALL items for a given tagihan header.
  Future<List<TagihanItemData>> getItemsByTagihan(int tagihanId) =>
      (select(tagihanItem)..where((i) => i.tagihanId.equals(tagihanId))).get();

  /// Fetches a single item by primary key.
  Future<TagihanItemData?> getItemById(int id) =>
      (select(tagihanItem)..where((i) => i.id.equals(id))).getSingleOrNull();

  /// Watches UNPAID items for a student across all their tagihan headers.
  /// This drives the POS Checklist UI (Tab 1).
  Stream<List<TagihanItemData>> watchUnpaidItemsByStudent(int siswaId) {
    final tagihanIdSubquery = selectOnly(tagihanSiswa)
      ..addColumns([tagihanSiswa.id])
      ..where(tagihanSiswa.siswaId.equals(siswaId));

    return (select(tagihanItem)
          ..where(
            (i) =>
                i.tagihanId.isInQuery(tagihanIdSubquery) &
                i.isLunas.equals(0),
          )
          ..orderBy([(i) => OrderingTerm.asc(i.id)]))
        .watch();
  }

  /// Watches ALL items for a student (paid + unpaid) for history view.
  Stream<List<TagihanItemData>> watchAllItemsByStudent(int siswaId) {
    final tagihanIdSubquery = selectOnly(tagihanSiswa)
      ..addColumns([tagihanSiswa.id])
      ..where(tagihanSiswa.siswaId.equals(siswaId));

    return (select(tagihanItem)
          ..where((i) => i.tagihanId.isInQuery(tagihanIdSubquery))
          ..orderBy([(i) => OrderingTerm.desc(i.id)]))
        .watch();
  }

  /// Atomically increments [terbayar] and marks [isLunas] if fully paid.
  /// Called INSIDE an outer transaction — do NOT nest transactions here.
  Future<void> applyPaymentToItem({
    required int itemId,
    required int amountPaid,
  }) async {
    final item =
        await (select(tagihanItem)..where((i) => i.id.equals(itemId)))
            .getSingle();
    final newTerbayar = item.terbayar + amountPaid;
    final isNowLunas = newTerbayar >= item.nominalAkhir ? 1 : 0;

    await (update(tagihanItem)..where((i) => i.id.equals(itemId))).write(
      TagihanItemCompanion(
        terbayar: Value(newTerbayar),
        isLunas: Value(isNowLunas),
      ),
    );

    // If all items in the parent tagihan are lunas, mark header as lunas too.
    if (isNowLunas == 1) {
      await _checkAndMarkTagihanLunas(item.tagihanId);
    }
  }

  /// Reverses a payment from an item (used in void/reversal logic).
  Future<void> reversePaymentOnItem({
    required int itemId,
    required int amountToReverse,
  }) async {
    final item =
        await (select(tagihanItem)..where((i) => i.id.equals(itemId)))
            .getSingle();
    final newTerbayar =
        (item.terbayar - amountToReverse).clamp(0, item.nominalAkhir);

    await (update(tagihanItem)..where((i) => i.id.equals(itemId))).write(
      TagihanItemCompanion(
        terbayar: Value(newTerbayar),
        isLunas: const Value(0), // Always reset lunas on reversal
      ),
    );

    // Unmark the parent header too.
    await (update(tagihanSiswa)
          ..where((t) => t.id.equals(item.tagihanId)))
        .write(const TagihanSiswaCompanion(isLunas: Value(0)));
  }

  Future<void> _checkAndMarkTagihanLunas(int tagihanId) async {
    final allItems = await getItemsByTagihan(tagihanId);
    final allPaid = allItems.every((i) => i.isLunas == 1);
    if (allPaid) {
      await (update(tagihanSiswa)..where((t) => t.id.equals(tagihanId)))
          .write(const TagihanSiswaCompanion(isLunas: Value(1)));
    }
  }
}
