import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/tagihan_dao.dart';
import '../../../core/database/daos/pembayaran_dao.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/database/tables/tagihan_item_table.dart';
import '../../../core/database/tables/pembayaran_transaksi_table.dart';
import '../../../core/database/tables/siswa_table.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/services/audit_logger_service.dart';
import '../../receipts/data/receipt_model_factory.dart';
import '../../receipts/presentation/receipt_actions_sheet.dart';
import '../../settings/presentation/pin_auth_screen.dart';
import '../domain/process_payment_use_case.dart';

part 'pos_checklist_screen.g.dart';

// ─────────────── Providers ───────────────

@riverpod
Stream<List<TagihanItemData>> unpaidItems(
  UnpaidItemsRef ref,
  int siswaId,
) {
  final dao = TagihanDao(ref.watch(appDatabaseProvider));
  return dao.watchUnpaidItemsByStudent(siswaId);
}

@riverpod
Stream<List<PembayaranTransaksiData>> paymentHistory(
  PaymentHistoryRef ref,
  int siswaId,
) {
  final dao = PembayaranDao(ref.watch(appDatabaseProvider));
  return dao.watchTransaksiByStudent(siswaId);
}

@riverpod
Future<SiswaData?> posStudentData(
  PosStudentDataRef ref,
  int siswaId,
) {
  final dao = SiswaDao(ref.watch(appDatabaseProvider));
  return dao.getById(siswaId);
}

// ─────────────── Checklist State ───────────────

class ChecklistItem {
  ChecklistItem({
    required this.item,
    this.isChecked = false,
    int? partialAmount,
  }) : partialAmountCtrl = TextEditingController(
          text: partialAmount?.toString() ?? '',
        );

  final TagihanItemData item;
  bool isChecked;
  bool isPartial = false;
  final TextEditingController partialAmountCtrl;

  int get remainingArrears => item.nominalAkhir - item.terbayar;

  int get allocatedAmount {
    if (!isChecked) return 0;
    if (isPartial) {
      final partial = int.tryParse(partialAmountCtrl.text) ?? 0;
      return partial.clamp(0, remainingArrears);
    }
    return remainingArrears;
  }

  void dispose() => partialAmountCtrl.dispose();
}

// ─────────────── POS Checklist Screen ───────────────

class PosChecklistScreen extends ConsumerStatefulWidget {
  const PosChecklistScreen({super.key, required this.siswaId});
  final int siswaId;

  @override
  ConsumerState<PosChecklistScreen> createState() =>
      _PosChecklistScreenState();
}

class _PosChecklistScreenState extends ConsumerState<PosChecklistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ChecklistItem> _checklistItems = [];
  String _metodeBayar = 'Tunai';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final item in _checklistItems) {
      item.dispose();
    }
    super.dispose();
  }

  int get _totalBayar =>
      _checklistItems.fold(0, (sum, i) => sum + i.allocatedAmount);

  void _syncChecklistItems(List<TagihanItemData> items) {
    // Add new items not yet in the checklist
    for (final item in items) {
      if (!_checklistItems.any((c) => c.item.id == item.id)) {
        _checklistItems.add(ChecklistItem(item: item));
      }
    }
    // Remove items that are now paid
    _checklistItems.removeWhere(
        (c) => !items.any((i) => i.id == c.item.id));
  }

  Future<void> _confirmPayment() async {
    final checkedItems =
        _checklistItems.where((i) => i.isChecked).toList();
    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu tagihan')),
      );
      return;
    }

    // Validate partial amounts
    for (final item in checkedItems) {
      if (item.isPartial) {
        final amount = int.tryParse(item.partialAmountCtrl.text) ?? 0;
        if (amount <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Jumlah cicilan untuk "${item.item.namaItem}" tidak valid')),
          );
          return;
        }
        if (amount > item.remainingArrears) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Cicilan melebihi sisa tagihan untuk "${item.item.namaItem}"')),
          );
          return; // EC-01: Overpayment prevention
        }
      }
    }

    setState(() => _isProcessing = true);

    try {
      final role = ref.read(authRoleProvider);
      final useCase = ref.read(processPaymentUseCaseProvider);
      final result = await useCase.execute(
        ProcessPaymentParams(
          siswaId: widget.siswaId,
          metodeBayar: _metodeBayar,
          createdBy: role?.displayName ?? 'Admin',
          allocations: checkedItems.map((i) {
            return PaymentAllocation(
              tagihanItemId: i.item.id,
              nominalDialokasikan: i.allocatedAmount,
            );
          }).toList(),
        ),
      );

      if (mounted) {
        _showPaymentSuccess(result);
        setState(() {
          for (final item in _checklistItems) {
            if (item.isChecked) {
              item.isChecked = false;
              item.isPartial = false;
              item.partialAmountCtrl.clear();
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPaymentSuccess(PaymentResult result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Pembayaran Berhasil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.format(result.totalBayar),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Kuitansi: ${result.nomorKuitansi}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final factory = ref.read(receiptModelFactoryProvider);
              final receipt =
                  await factory.buildFromTransactionId(result.transaksiId);
              if (receipt != null && mounted) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ReceiptActionsSheet(receipt: receipt),
                );
              }
            },
            icon: const Icon(Icons.print),
            label: const Text('Cetak Kuitansi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentAsync =
        ref.watch(posStudentDataProvider(widget.siswaId));
    final unpaidAsync =
        ref.watch(unpaidItemsProvider(widget.siswaId));

    return Scaffold(
      appBar: AppBar(
        title: studentAsync.when(
          data: (s) => s != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.namaLengkap,
                        style: const TextStyle(fontSize: 16)),
                    Text(
                      'NIS: ${s.nis}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                )
              : const Text('Detail Siswa'),
          loading: () => const Text('Memuat...'),
          error: (_, __) => const Text('Siswa'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'TAGIHAN BELUM LUNAS'),
            Tab(text: 'RIWAYAT BAYAR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── TAB 1: POS Checklist ──
          unpaidAsync.when(
            data: (items) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _syncChecklistItems(items));
              });
              if (items.isEmpty) {
                return const _NoUnpaidBillsState();
              }
              return _ChecklistTab(
                checklistItems: _checklistItems,
                totalBayar: _totalBayar,
                metodeBayar: _metodeBayar,
                isProcessing: _isProcessing,
                onMetodeChanged: (m) =>
                    setState(() => _metodeBayar = m),
                onToggleItem: (item) =>
                    setState(() => item.isChecked = !item.isChecked),
                onTogglePartial: (item) =>
                    setState(() => item.isPartial = !item.isPartial),
                onConfirm: _confirmPayment,
                onRebuild: () => setState(() {}),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),

          // ── TAB 2: Payment History ──
          ref.watch(paymentHistoryProvider(widget.siswaId)).when(
            data: (txns) => txns.isEmpty
                ? const _NoHistoryState()
                : ListView.builder(
                    itemCount: txns.length,
                    itemBuilder: (ctx, i) =>
                        _TransactionHistoryTile(txn: txns[i]),
                  ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}

// ── Tab 1 Contents ──

class _ChecklistTab extends StatelessWidget {
  const _ChecklistTab({
    required this.checklistItems,
    required this.totalBayar,
    required this.metodeBayar,
    required this.isProcessing,
    required this.onMetodeChanged,
    required this.onToggleItem,
    required this.onTogglePartial,
    required this.onConfirm,
    required this.onRebuild,
  });
  final List<ChecklistItem> checklistItems;
  final int totalBayar;
  final String metodeBayar;
  final bool isProcessing;
  final void Function(String) onMetodeChanged;
  final void Function(ChecklistItem) onToggleItem;
  final void Function(ChecklistItem) onTogglePartial;
  final VoidCallback onConfirm;
  final VoidCallback onRebuild;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: checklistItems
                .map((item) => _ChecklistItemTile(
                      checklistItem: item,
                      onToggle: () => onToggleItem(item),
                      onTogglePartial: () => onTogglePartial(item),
                      onRebuild: onRebuild,
                    ))
                .toList(),
          ),
        ),
        _PaymentSummaryBar(
          totalBayar: totalBayar,
          metodeBayar: metodeBayar,
          isProcessing: isProcessing,
          onMetodeChanged: onMetodeChanged,
          onConfirm: onConfirm,
        ),
      ],
    );
  }
}

class _ChecklistItemTile extends StatelessWidget {
  const _ChecklistItemTile({
    required this.checklistItem,
    required this.onToggle,
    required this.onTogglePartial,
    required this.onRebuild,
  });
  final ChecklistItem checklistItem;
  final VoidCallback onToggle;
  final VoidCallback onTogglePartial;
  final VoidCallback onRebuild;

  @override
  Widget build(BuildContext context) {
    final item = checklistItem.item;
    final remaining = checklistItem.remainingArrears;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          CheckboxListTile(
            value: checklistItem.isChecked,
            onChanged: (_) => onToggle(),
            title: Text(
              item.namaItem,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: item.terbayar > 0
                ? Text(
                    'Terbayar: ${CurrencyFormatter.format(item.terbayar)} '
                    '· Sisa: ${CurrencyFormatter.format(remaining)}',
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
            secondary: Text(
              CurrencyFormatter.format(remaining),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (checklistItem.isChecked) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Checkbox(
                    value: checklistItem.isPartial,
                    onChanged: (_) => onTogglePartial(),
                  ),
                  const Text('Bayar sebagian (cicilan)'),
                ],
              ),
            ),
            if (checklistItem.isPartial)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextFormField(
                  controller: checklistItem.partialAmountCtrl,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Cicilan',
                    prefixText: 'Rp ',
                    hintText: 'Maks: ${CurrencyFormatter.format(remaining)}',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onRebuild(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PaymentSummaryBar extends StatelessWidget {
  const _PaymentSummaryBar({
    required this.totalBayar,
    required this.metodeBayar,
    required this.isProcessing,
    required this.onMetodeChanged,
    required this.onConfirm,
  });
  final int totalBayar;
  final String metodeBayar;
  final bool isProcessing;
  final void Function(String) onMetodeChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL PEMBAYARAN',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                CurrencyFormatter.format(totalBayar),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Payment method
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'Tunai',
                icon: Icon(Icons.money),
                label: Text('Tunai'),
              ),
              ButtonSegment(
                value: 'Transfer',
                icon: Icon(Icons.account_balance),
                label: Text('Transfer'),
              ),
            ],
            selected: {metodeBayar},
            onSelectionChanged: (sel) => onMetodeChanged(sel.first),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: totalBayar > 0 && !isProcessing ? onConfirm : null,
            icon: isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle),
            label: Text(
              isProcessing ? 'Memproses...' : 'KONFIRMASI & CETAK KUITANSI',
            ),
          ),
        ],
      ),
    );
  }
}

class _NoUnpaidBillsState extends StatelessWidget {
  const _NoUnpaidBillsState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 72, color: Colors.green.shade300),
          const SizedBox(height: 16),
          Text(
            'Semua tagihan lunas!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Tidak ada tagihan yang perlu dibayar saat ini.'),
        ],
      ),
    );
  }
}

class _NoHistoryState extends StatelessWidget {
  const _NoHistoryState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _TransactionHistoryTile extends ConsumerWidget {
  const _TransactionHistoryTile({required this.txn});
  final PembayaranTransaksiData txn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVoid = txn.status == 'VOID';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isVoid
            ? Colors.red.shade100
            : Colors.green.shade100,
        child: Icon(
          isVoid ? Icons.cancel_outlined : Icons.receipt,
          color: isVoid ? Colors.red : Colors.green,
        ),
      ),
      title: Text(txn.nomorKuitansi),
      subtitle: Text(
        '${txn.tanggalBayar.substring(0, 10)} · ${txn.metodeBayar}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            CurrencyFormatter.format(txn.totalBayar),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isVoid ? Colors.red : Colors.green,
              decoration:
                  isVoid ? TextDecoration.lineThrough : null,
            ),
          ),
          if (isVoid)
            const Text(
              'VOID',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
      onTap: () => _showTxnOptions(context, ref),
    );
  }

  void _showTxnOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Cetak / Bagikan Kuitansi'),
              subtitle: const Text('Thermal 58mm, WhatsApp PDF, atau Preview'),
              onTap: () async {
                Navigator.pop(context);
                final factory = ref.read(receiptModelFactoryProvider);
                final receipt = await factory.buildFromTransaction(txn);
                if (context.mounted) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ReceiptActionsSheet(receipt: receipt),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
