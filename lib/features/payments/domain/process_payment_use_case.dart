import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pembayaran_dao.dart';
import '../../../core/database/daos/tagihan_dao.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/audit_logger_service.dart';
import '../../../core/utils/date_formatter.dart';

final processPaymentUseCaseProvider = Provider<ProcessPaymentUseCase>(
  (ref) => ProcessPaymentUseCase(
    db: ref.watch(appDatabaseProvider),
    pembayaranDao: PembayaranDao(ref.watch(appDatabaseProvider)),
    tagihanDao: TagihanDao(ref.watch(appDatabaseProvider)),
    auditLogger: ref.watch(auditLoggerProvider),
  ),
);

class PaymentAllocation {
  const PaymentAllocation({
    required this.tagihanItemId,
    required this.nominalDialokasikan,
  });
  final int tagihanItemId;
  final int nominalDialokasikan;
}

class ProcessPaymentParams {
  const ProcessPaymentParams({
    required this.siswaId,
    required this.metodeBayar,
    required this.createdBy,
    required this.allocations,
  });
  final int siswaId;
  final String metodeBayar;
  final String createdBy;
  final List<PaymentAllocation> allocations;
  int get totalBayar =>
      allocations.fold(0, (sum, a) => sum + a.nominalDialokasikan);
}

class PaymentResult {
  const PaymentResult({
    required this.transaksiId,
    required this.nomorKuitansi,
    required this.totalBayar,
  });
  final int transaksiId;
  final String nomorKuitansi;
  final int totalBayar;
}

class ProcessPaymentUseCase {
  const ProcessPaymentUseCase({
    required this.db,
    required this.pembayaranDao,
    required this.tagihanDao,
    required this.auditLogger,
  });

  final AppDatabase db;
  final PembayaranDao pembayaranDao;
  final TagihanDao tagihanDao;
  final AuditLoggerService auditLogger;

  /// Executes a complete atomic payment transaction.
  /// PRD Non-Negotiable Rule #5: all writes in one db.transaction().
  Future<PaymentResult> execute(ProcessPaymentParams params) async {
    if (params.allocations.isEmpty) {
      throw const ValidationException('Tidak ada item yang dipilih untuk pembayaran.');
    }

    return db.transaction(() async {
      // 0. Validation: allocations must be positive, no duplicate items, belong to student, no overpayment
      final seenItemIds = <int>{};
      for (final allocation in params.allocations) {
        if (allocation.nominalDialokasikan <= 0) {
          throw const ValidationException('Nominal pembayaran harus lebih besar dari 0.');
        }
        if (!seenItemIds.add(allocation.tagihanItemId)) {
          throw const ValidationException('Terdapat duplikasi alokasi item tagihan.');
        }

        final item = await tagihanDao.getItemById(allocation.tagihanItemId);
        if (item == null) {
          throw NotFoundException(
            'Item tagihan #${allocation.tagihanItemId} tidak ditemukan.',
          );
        }

        // Verify item belongs to student
        final header = await (db.select(db.tagihanSiswa)
              ..where((h) => h.id.equals(item.tagihanId)))
            .getSingleOrNull();
        if (header == null || header.siswaId != params.siswaId) {
          throw const ValidationException(
            'Item tagihan tidak sesuai dengan siswa yang dipilih.',
          );
        }

        final sisa = item.nominalAkhir - item.terbayar;
        if (allocation.nominalDialokasikan > sisa) {
          throw ValidationException(
            'Nominal pembayaran (${allocation.nominalDialokasikan}) melebihi sisa tagihan ($sisa) untuk "${item.namaItem}".',
          );
        }
      }

      final now = DateTime.now();
      final nomorKuitansi = await _generateNomorKuitansi(now);

      // 1. Insert pembayaran_transaksi header
      final transaksiId = await pembayaranDao.insertTransaksi(
        PembayaranTransaksiCompanion.insert(
          nomorKuitansi: nomorKuitansi,
          siswaId: params.siswaId,
          tanggalBayar: DateFormatter.toIso(now),
          totalBayar: params.totalBayar,
          metodeBayar: params.metodeBayar,
          createdBy: params.createdBy,
        ),
      );

      // 2. Insert alokasi_pembayaran + update tagihan_item
      for (final allocation in params.allocations) {
        await pembayaranDao.insertAlokasi(
          AlokasiPembayaranCompanion.insert(
            transaksiId: transaksiId,
            tagihanItemId: allocation.tagihanItemId,
            nominalDialokasikan: allocation.nominalDialokasikan,
          ),
        );
        await tagihanDao.applyPaymentToItem(
          itemId: allocation.tagihanItemId,
          amountPaid: allocation.nominalDialokasikan,
        );
      }

      // 3. Audit log
      await auditLogger.log(
        userRole: params.createdBy,
        actionType: AuditAction.insertPayment,
        entityAffected: 'pembayaran_transaksi',
        entityId: transaksiId,
        details:
            'Kuitansi: $nomorKuitansi | Siswa: ${params.siswaId} | '
            'Total: ${params.totalBayar} | Metode: ${params.metodeBayar}',
      );

      return PaymentResult(
        transaksiId: transaksiId,
        nomorKuitansi: nomorKuitansi,
        totalBayar: params.totalBayar,
      );
    });
  }

  /// Voids a transaction and reverses all allocation effects.
  Future<void> voidTransaction({
    required int transaksiId,
    required String voidedBy,
  }) async {
    await db.transaction(() async {
      final txn = await (db.select(db.pembayaranTransaksi)
            ..where((t) => t.id.equals(transaksiId)))
          .getSingleOrNull();

      if (txn == null) {
        throw const NotFoundException('Transaksi pembayaran tidak ditemukan.');
      }
      if (txn.status == 'VOID') {
        throw const ValidationException('Transaksi ini sudah berstatus VOID sebelumnya.');
      }

      final allocations =
          await pembayaranDao.getAlokasiByTransaksi(transaksiId);
      for (final alokasi in allocations) {
        await tagihanDao.reversePaymentOnItem(
          itemId: alokasi.tagihanItemId,
          amountToReverse: alokasi.nominalDialokasikan,
        );
      }
      await pembayaranDao.voidTransaksi(transaksiId);
      await auditLogger.log(
        userRole: voidedBy,
        actionType: AuditAction.voidTransaction,
        entityAffected: 'pembayaran_transaksi',
        entityId: transaksiId,
        details: 'Transaction voided by $voidedBy',
      );
    });
  }

  Future<String> _generateNomorKuitansi(DateTime date) async {
    final dateCode = DateFormatter.toDateCode(date);
    final todayCount =
        await pembayaranDao.countTransaksiToday(DateFormatter.todayPrefix());
    final seq = (todayCount + 1).toString().padLeft(4, '0');
    return 'KW-$dateCode-$seq';
  }
}
