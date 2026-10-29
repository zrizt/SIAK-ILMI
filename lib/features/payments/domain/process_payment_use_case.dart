import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pembayaran_dao.dart';
import '../../../core/database/daos/tagihan_dao.dart';
import '../../../core/database/tables/pembayaran_transaksi_table.dart';
import '../../../core/database/tables/alokasi_pembayaran_table.dart';
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
      throw const AppException('Tidak ada item yang dipilih untuk pembayaran.');
    }
    return db.transaction(() async {
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
