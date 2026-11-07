import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/tarif_dao.dart';
import '../../fee_management/domain/bill_generator_engine.dart';

// ─── Semester model ───────────────────────────────────────────────────────────

/// Represents a full semester option (6 months) for SPP billing.
class _SemesterOption {
  const _SemesterOption({
    required this.label,
    required this.months, // list of (month, year) pairs
    required this.tahunAjaran,
  });

  final String label;
  final List<(int month, int year)> months;
  final String tahunAjaran;
}

/// Indonesian academic calendar semesters.
/// Semester 1 TA YYYY/YYYY+1 = Juli–Desember
/// Semester 2 TA YYYY/YYYY+1 = Januari–Juni (of YYYY+1)
List<_SemesterOption> _buildSemesterOptions() {
  final now = DateTime.now();
  final currentYear = now.year;
  final options = <_SemesterOption>[];

  // Generate options for the past year, current, and next year
  for (var baseYear = currentYear - 1; baseYear <= currentYear + 1; baseYear++) {
    final taLabel = '$baseYear/${baseYear + 1}';
    // Semester 1: Juli–Desember of baseYear
    options.add(_SemesterOption(
      label: 'Semester 1 TA $taLabel',
      months: List.generate(6, (i) => (7 + i, baseYear)),
      tahunAjaran: taLabel,
    ));
    // Semester 2: Januari–Juni of baseYear+1
    options.add(_SemesterOption(
      label: 'Semester 2 TA $taLabel',
      months: List.generate(6, (i) => (1 + i, baseYear + 1)),
      tahunAjaran: taLabel,
    ));
  }
  return options;
}

const List<String> _indonesianMonths = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class GenerateBillScreen extends ConsumerStatefulWidget {
  const GenerateBillScreen({
    super.key,
    required this.siswaId,
    required this.tingkat,
  });

  final int siswaId;
  final int tingkat;

  @override
  ConsumerState<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends ConsumerState<GenerateBillScreen> {
  /// Billing mode: 'semester' (auto 6-month SPP) or 'manual' (single period + all categories)
  String _mode = 'semester';

  // ── Semester mode state ───────────────────────────────────────────────────
  late final List<_SemesterOption> _semesterOptions;
  late _SemesterOption _selectedSemester;

  // ── Manual mode state (one-off fees) ─────────────────────────────────────
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  late final TextEditingController _yearController;
  final List<int> _selectedKategoriIds = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _semesterOptions = _buildSemesterOptions();
    // Default: pick the semester closest to today
    _selectedSemester = _pickCurrentSemester();
    _yearController = TextEditingController(text: _selectedYear.toString());
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  _SemesterOption _pickCurrentSemester() {
    final now = DateTime.now();
    // Semester 1 = months 7-12, Semester 2 = months 1-6
    final isSem1 = now.month >= 7;
    final baseYear = isSem1 ? now.year : now.year - 1;
    final targetLabel = isSem1
        ? 'Semester 1 TA $baseYear/${baseYear + 1}'
        : 'Semester 2 TA $baseYear/${baseYear + 1}';
    return _semesterOptions.firstWhere(
      (s) => s.label == targetLabel,
      orElse: () => _semesterOptions.first,
    );
  }

  // ── Semester billing ──────────────────────────────────────────────────────

  Future<void> _handleGenerateSemester(List<KategoriBiayaData> categories) async {
    // Find SPP category
    final sppKategori = categories.where((c) => c.namaBiaya.contains('SPP')).toList();
    if (sppKategori.isEmpty) {
      _showSnack('Kategori SPP tidak ditemukan. Periksa master data biaya.');
      return;
    }
    final kategori = sppKategori.first;

    setState(() => _isLoading = true);
    try {
      final semester = _selectedSemester;
      int generatedCount = 0;

      // Generate one tagihan_siswa per month with one SPP tagihan_item each.
      // This keeps PRD AC-05 partial installment intact (each month is independently payable).
      for (final (month, year) in semester.months) {
        final monthName = _indonesianMonths[month - 1];
        final periode = 'SPP $monthName $year';

        await ref.read(billGeneratorEngineProvider).generateBill(
          siswaId: widget.siswaId,
          tingkat: widget.tingkat,
          periode: periode,
          items: [
            BillLineItemParam(
              kategoriBiayaId: kategori.id,
              namaItem: 'SPP $monthName $year',
              nominalDiskon: 0,
            ),
          ],
        );
        generatedCount++;
      }

      if (!mounted) return;
      _showSnack(
        '✓ $generatedCount tagihan SPP ${semester.label} berhasil dibuat',
        isSuccess: true,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal membuat tagihan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Manual (one-off) billing ──────────────────────────────────────────────

  Future<void> _handleGenerateManual(List<KategoriBiayaData> categories) async {
    if (_selectedKategoriIds.isEmpty) {
      _showSnack('Pilih minimal satu kategori biaya untuk ditagihkan.');
      return;
    }

    final yearParsed = int.tryParse(_yearController.text.trim());
    if (yearParsed == null || yearParsed < 2000 || yearParsed > 2100) {
      _showSnack('Masukkan tahun yang valid (2000-2100).');
      return;
    }

    _selectedYear = yearParsed;
    final monthName = _indonesianMonths[_selectedMonth - 1];
    final periode = '$monthName $_selectedYear';

    setState(() => _isLoading = true);
    try {
      final categoryMap = {for (final k in categories) k.id: k.namaBiaya};
      final billItems = _selectedKategoriIds.map((kategoriId) {
        final namaBiaya = categoryMap[kategoriId] ?? 'Tagihan';
        return BillLineItemParam(
          kategoriBiayaId: kategoriId,
          namaItem: '$namaBiaya $monthName $_selectedYear',
          nominalDiskon: 0,
        );
      }).toList();

      await ref.read(billGeneratorEngineProvider).generateBill(
        siswaId: widget.siswaId,
        tingkat: widget.tingkat,
        periode: periode,
        items: billItems,
      );

      if (!mounted) return;
      _showSnack('✓ Tagihan periode $periode berhasil dibuat', isSuccess: true);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal membuat tagihan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isSuccess = false, bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess
          ? Colors.green
          : isError
              ? Theme.of(context).colorScheme.error
              : null,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(appDatabaseProvider);
    final tarifDao = TarifDao(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tagihan Baru'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'semester',
                  icon: Icon(Icons.calendar_month),
                  label: Text('Tagihan SPP\nSemester'),
                ),
                ButtonSegment(
                  value: 'manual',
                  icon: Icon(Icons.edit_calendar),
                  label: Text('Tagihan\nManual'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: _isLoading
                  ? null
                  : (sel) => setState(() {
                        _mode = sel.first;
                        _selectedKategoriIds.clear();
                      }),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<KategoriBiayaData>>(
        future: tarifDao.getAllKategori(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gagal memuat kategori biaya: ${snapshot.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            );
          }

          final categories = snapshot.data ?? [];
          return _mode == 'semester'
              ? _SemesterBillingForm(
                  semesterOptions: _semesterOptions,
                  selectedSemester: _selectedSemester,
                  tingkat: widget.tingkat,
                  isLoading: _isLoading,
                  categories: categories,
                  onSemesterChanged: (s) =>
                      setState(() => _selectedSemester = s),
                  onGenerate: () => _handleGenerateSemester(categories),
                )
              : _ManualBillingForm(
                  tingkat: widget.tingkat,
                  selectedMonth: _selectedMonth,
                  yearController: _yearController,
                  selectedKategoriIds: _selectedKategoriIds,
                  isLoading: _isLoading,
                  categories: categories,
                  onMonthChanged: (m) => setState(() => _selectedMonth = m),
                  onKategoriToggle: (id, selected) => setState(() {
                    if (selected) {
                      _selectedKategoriIds.add(id);
                    } else {
                      _selectedKategoriIds.remove(id);
                    }
                  }),
                  onSelectAll: (cats) => setState(() {
                    if (_selectedKategoriIds.length == cats.length) {
                      _selectedKategoriIds.clear();
                    } else {
                      _selectedKategoriIds
                        ..clear()
                        ..addAll(cats.map((c) => c.id));
                    }
                  }),
                  onGenerate: () => _handleGenerateManual(categories),
                );
        },
      ),
    );
  }
}

// ─── Semester billing form ─────────────────────────────────────────────────────

class _SemesterBillingForm extends StatelessWidget {
  const _SemesterBillingForm({
    required this.semesterOptions,
    required this.selectedSemester,
    required this.tingkat,
    required this.isLoading,
    required this.categories,
    required this.onSemesterChanged,
    required this.onGenerate,
  });

  final List<_SemesterOption> semesterOptions;
  final _SemesterOption selectedSemester;
  final int tingkat;
  final bool isLoading;
  final List<KategoriBiayaData> categories;
  final void Function(_SemesterOption) onSemesterChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        _InfoCard(tingkat: tingkat),
        const SizedBox(height: 16),

        // Semester selector
        Text(
          'Pilih Semester',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<_SemesterOption>(
          // ignore: deprecated_member_use
          value: selectedSemester,
          decoration: const InputDecoration(
            labelText: 'Semester Tagihan SPP',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_month_outlined),
          ),
          items: semesterOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
              .toList(),
          onChanged: isLoading
              ? null
              : (val) {
                  if (val != null) onSemesterChanged(val);
                },
        ),
        const SizedBox(height: 16),

        // Preview: 6 months to be generated
        Text(
          'Tagihan yang akan dibuat (6 bulan)',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedSemester.months.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
            itemBuilder: (ctx, i) {
              final (month, year) = selectedSemester.months[i];
              final monthName = _indonesianMonths[month - 1];
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text('SPP $monthName $year'),
                trailing: Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: cs.outline,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: cs.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Setiap bulan dibuat sebagai tagihan terpisah sehingga '
                  'cicilan per-bulan dapat dibayarkan secara independen.',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onTertiaryContainer),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: isLoading ? null : onGenerate,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.receipt_long),
          label: Text(
            isLoading ? 'Memproses...' : 'Buat 6 Tagihan SPP Semester',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ─── Manual billing form ───────────────────────────────────────────────────────

class _ManualBillingForm extends StatelessWidget {
  const _ManualBillingForm({
    required this.tingkat,
    required this.selectedMonth,
    required this.yearController,
    required this.selectedKategoriIds,
    required this.isLoading,
    required this.categories,
    required this.onMonthChanged,
    required this.onKategoriToggle,
    required this.onSelectAll,
    required this.onGenerate,
  });

  final int tingkat;
  final int selectedMonth;
  final TextEditingController yearController;
  final List<int> selectedKategoriIds;
  final bool isLoading;
  final List<KategoriBiayaData> categories;
  final void Function(int) onMonthChanged;
  final void Function(int id, bool selected) onKategoriToggle;
  final void Function(List<KategoriBiayaData>) onSelectAll;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(tingkat: tingkat),
        const SizedBox(height: 16),

        Text(
          'Periode Tagihan',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<int>(
                initialValue: selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Bulan',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: List.generate(12, (i) {
                  final num = i + 1;
                  return DropdownMenuItem<int>(
                    value: num,
                    child: Text(_indonesianMonths[i]),
                  );
                }),
                onChanged: isLoading
                    ? null
                    : (val) {
                        if (val != null) onMonthChanged(val);
                      },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: 'Tahun',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                enabled: !isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pilih Kategori Biaya',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: isLoading ? null : () => onSelectAll(categories),
              child: Text(
                selectedKategoriIds.length == categories.length
                    ? 'Batal Semua'
                    : 'Pilih Semua',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (categories.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada kategori biaya yang terdaftar.'),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
              itemBuilder: (ctx, i) {
                final item = categories[i];
                final isSelected = selectedKategoriIds.contains(item.id);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(item.namaBiaya),
                  subtitle: Text(
                    'Tipe: ${item.tipe}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.outline,
                    ),
                  ),
                  onChanged: isLoading
                      ? null
                      : (val) => onKategoriToggle(item.id, val ?? false),
                );
              },
            ),
          ),
        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: isLoading ? null : onGenerate,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.receipt_long),
          label: Text(
            isLoading ? 'Memproses Tagihan...' : 'Buat Tagihan',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ─── Shared info card ─────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.tingkat});
  final int tingkat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.school_outlined, color: cs.primary, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Siswa',
                  style: theme.textTheme.labelMedium?.copyWith(color: cs.outline),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tingkat: $tingkat',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
