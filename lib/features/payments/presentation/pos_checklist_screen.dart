import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/tagihan_dao.dart';
import '../../../core/database/daos/pembayaran_dao.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/security/operator_service.dart';
import '../../../core/utils/bill_semester_helper.dart';
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

  TagihanItemData item;
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

  int? _selectedSemester;
  String? _selectedAcademicYear;

  List<ChecklistItem> get _filteredChecklistItems {
    return _checklistItems.where((c) {
      if (_selectedSemester != null) {
        final sem = BillSemesterHelper.getSemester(c.item.namaItem);
        if (_selectedSemester == -1) {
          if (sem != null) return false;
        } else {
          if (sem != _selectedSemester) return false;
        }
      }
      if (_selectedAcademicYear != null) {
        final ta = BillSemesterHelper.getAcademicYear(c.item.namaItem);
        if (ta != _selectedAcademicYear) return false;
      }
      return true;
    }).toList();
  }

  Set<String> get _availableAcademicYears {
    final tas = <String>{};
    for (final c in _checklistItems) {
      final ta = BillSemesterHelper.getAcademicYear(c.item.namaItem);
      if (ta != null) tas.add(ta);
    }
    return tas;
  }

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
    final incomingIds = items.map((i) => i.id).toSet();
    final itemsMap = {for (final i in items) i.id: i};

    // Dispose and remove items that are no longer unpaid
    _checklistItems.removeWhere((c) {
      if (!incomingIds.contains(c.item.id)) {
        c.dispose();
        return true;
      }
      return false;
    });

    // Update existing items with fresh data
    for (final c in _checklistItems) {
      final fresh = itemsMap[c.item.id];
      if (fresh != null) {
        c.item = fresh;
      }
    }

    // Add brand-new items
    final existingIds = _checklistItems.map((c) => c.item.id).toSet();
    for (final item in items) {
      if (!existingIds.contains(item.id)) {
        _checklistItems.add(ChecklistItem(item: item));
      }
    }
  }

  Future<void> _confirmPayment() async {
    final role = ref.read(authRoleProvider);
    if (role != PinRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akses ditolak: Hanya Admin yang dapat memproses pembayaran.',
          ),
        ),
      );
      return;
    }

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
          createdBy: ref.read(activeOperatorProvider)?.fullName ??
              role?.displayName ??
              'Admin',
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
              final filteredItems = _filteredChecklistItems;
              return _ChecklistTab(
                checklistItems: filteredItems,
                allChecklistItems: _checklistItems,
                selectedSemester: _selectedSemester,
                onSemesterChanged: (s) => setState(() => _selectedSemester = s),
                selectedAcademicYear: _selectedAcademicYear,
                onAcademicYearChanged: (ta) =>
                    setState(() => _selectedAcademicYear = ta),
                availableAcademicYears: _availableAcademicYears,
                totalBayar: _totalBayar,
                metodeBayar: _metodeBayar,
                isProcessing: _isProcessing,
                onMetodeChanged: (m) => setState(() => _metodeBayar = m),
                onToggleItem: (item) =>
                    setState(() => item.isChecked = !item.isChecked),
                onTogglePartial: (item) =>
                    setState(() => item.isPartial = !item.isPartial),
                onConfirm: _confirmPayment,
                onRebuild: () => setState(() {}),
                onSelectAll: () => setState(() {
                  for (final c in filteredItems) {
                    c.isChecked = true;
                    c.isPartial = false;
                    c.partialAmountCtrl.clear();
                  }
                }),
                onSelectNone: () => setState(() {
                  for (final c in filteredItems) {
                    c.isChecked = false;
                    c.isPartial = false;
                    c.partialAmountCtrl.clear();
                  }
                }),
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
    required this.allChecklistItems,
    required this.selectedSemester,
    required this.onSemesterChanged,
    required this.selectedAcademicYear,
    required this.onAcademicYearChanged,
    required this.availableAcademicYears,
    required this.totalBayar,
    required this.metodeBayar,
    required this.isProcessing,
    required this.onMetodeChanged,
    required this.onToggleItem,
    required this.onTogglePartial,
    required this.onConfirm,
    required this.onRebuild,
    required this.onSelectAll,
    required this.onSelectNone,
  });
  final List<ChecklistItem> checklistItems;
  final List<ChecklistItem> allChecklistItems;
  final int? selectedSemester;
  final void Function(int?) onSemesterChanged;
  final String? selectedAcademicYear;
  final void Function(String?) onAcademicYearChanged;
  final Set<String> availableAcademicYears;
  final int totalBayar;
  final String metodeBayar;
  final bool isProcessing;
  final void Function(String) onMetodeChanged;
  final void Function(ChecklistItem) onToggleItem;
  final void Function(ChecklistItem) onTogglePartial;
  final VoidCallback onConfirm;
  final VoidCallback onRebuild;
  final VoidCallback onSelectAll;
  final VoidCallback onSelectNone;

  bool get _allChecked =>
      checklistItems.isNotEmpty && checklistItems.every((i) => i.isChecked);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final checkedCount = checklistItems.where((i) => i.isChecked).length;

    return Column(
      children: [
        // ── Semester & Academic Year Filter Bar ────────────────────────────
        Container(
          color: cs.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text('Semua (${allChecklistItems.length})'),
                      selected: selectedSemester == null,
                      onSelected: (_) => onSemesterChanged(null),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: const Text('Semester 1 (Ganjil)'),
                      selected: selectedSemester == 1,
                      onSelected: (_) =>
                          onSemesterChanged(selectedSemester == 1 ? null : 1),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: const Text('Semester 2 (Genap)'),
                      selected: selectedSemester == 2,
                      onSelected: (_) =>
                          onSemesterChanged(selectedSemester == 2 ? null : 2),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: const Text('Non-SPP / Lainnya'),
                      selected: selectedSemester == 0,
                      onSelected: (_) =>
                          onSemesterChanged(selectedSemester == 0 ? null : 0),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              if (availableAcademicYears.length > 1) ...[
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'TA: ',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Semua TA'),
                        selected: selectedAcademicYear == null,
                        onSelected: (_) => onAcademicYearChanged(null),
                        visualDensity: VisualDensity.compact,
                      ),
                      for (final ta in availableAcademicYears) ...[
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: Text(ta),
                          selected: selectedAcademicYear == ta,
                          onSelected: (_) => onAcademicYearChanged(
                            selectedAcademicYear == ta ? null : ta,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Batch select toolbar ───────────────────────────────────────────
        Container(
          color: cs.surfaceContainerLowest,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(Icons.checklist_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                '$checkedCount/${checklistItems.length} dipilih',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: (isProcessing || checklistItems.isEmpty)
                    ? null
                    : _allChecked
                        ? onSelectNone
                        : onSelectAll,
                icon: Icon(
                  _allChecked ? Icons.deselect : Icons.select_all,
                  size: 16,
                ),
                label: Text(_allChecked ? 'Batal Semua' : 'Pilih Semua'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: checklistItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list_off,
                            size: 48, color: cs.outline),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada tagihan yang cocok dengan filter',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            onSemesterChanged(null);
                            onAcademicYearChanged(null);
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset Filter'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final item = checklistItem.item;
    final remaining = checklistItem.remainingArrears;
    final semLabel = BillSemesterHelper.getSemesterLabel(item.namaItem);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          CheckboxListTile(
            value: checklistItem.isChecked,
            onChanged: (_) => onToggle(),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.namaItem,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (semLabel != 'Lainnya')
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      semLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
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
                color: theme.colorScheme.primary,
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
            color: Colors.black.withValues(alpha: 0.08),
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
