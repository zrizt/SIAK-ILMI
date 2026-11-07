import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/database/daos/tarif_dao.dart';
import '../../../core/security/operator_service.dart';
import '../../settings/presentation/pin_auth_screen.dart';
import '../domain/bulk_billing_use_case.dart';

class _SemesterChoice {
  const _SemesterChoice({
    required this.label,
    required this.months,
    required this.tahunAjaran,
  });

  final String label;
  final List<(int month, int year)> months;
  final String tahunAjaran;
}

List<_SemesterChoice> _createSemesterChoices() {
  final now = DateTime.now();
  final currentYear = now.year;
  final choices = <_SemesterChoice>[];

  for (var baseYear = currentYear - 1; baseYear <= currentYear + 1; baseYear++) {
    final ta = '$baseYear/${baseYear + 1}';
    choices.add(_SemesterChoice(
      label: 'Semester 1 TA $ta',
      months: List.generate(6, (i) => (7 + i, baseYear)),
      tahunAjaran: ta,
    ));
    choices.add(_SemesterChoice(
      label: 'Semester 2 TA $ta',
      months: List.generate(6, (i) => (1 + i, baseYear + 1)),
      tahunAjaran: ta,
    ));
  }
  return choices;
}

const List<String> _monthsNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Screen for generating SPP semester charges in bulk for all active students.
class BulkBillingScreen extends ConsumerStatefulWidget {
  const BulkBillingScreen({super.key});

  @override
  ConsumerState<BulkBillingScreen> createState() => _BulkBillingScreenState();
}

class _BulkBillingScreenState extends ConsumerState<BulkBillingScreen> {
  late final List<_SemesterChoice> _semesterChoices;
  late _SemesterChoice _selectedSemester;
  bool _isLoading = false;
  int _activeStudentCount = 0;
  bool _isLoadingCount = true;

  @override
  void initState() {
    super.initState();
    _semesterChoices = _createSemesterChoices();
    _selectedSemester = _pickDefaultSemester();
    _fetchActiveStudentCount();
  }

  _SemesterChoice _pickDefaultSemester() {
    final now = DateTime.now();
    final isSem1 = now.month >= 7;
    final baseYear = isSem1 ? now.year : now.year - 1;
    final targetLabel = isSem1
        ? 'Semester 1 TA $baseYear/${baseYear + 1}'
        : 'Semester 2 TA $baseYear/${baseYear + 1}';
    return _semesterChoices.firstWhere(
      (s) => s.label == targetLabel,
      orElse: () => _semesterChoices.first,
    );
  }

  Future<void> _fetchActiveStudentCount() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final activeList = await SiswaDao(db).getActiveSiswa();
      if (mounted) {
        setState(() {
          _activeStudentCount = activeList.length;
          _isLoadingCount = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCount = false);
      }
    }
  }

  Future<void> _handleExecuteBulkBilling() async {
    final role = ref.read(authRoleProvider);
    if (role != PinRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya Administrator yang dapat generate tagihan massal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Generate Massal'),
        content: Text(
          'Akan membuat tagihan SPP untuk $_activeStudentCount siswa aktif '
          'pada ${_selectedSemester.label} (6 bulan).\n\n'
          'Sistem akan otomatis melewati tagihan yang sudah pernah dibuat.\n\n'
          'Lanjutkan proses?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Generate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(appDatabaseProvider);
      final categories = await TarifDao(db).getAllKategori();
      final sppCategories = categories.where((c) => c.namaBiaya.contains('SPP')).toList();

      if (sppCategories.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori biaya SPP tidak ditemukan di database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final sppKategori = sppCategories.first;
      final operator = ref.read(activeOperatorProvider);
      final operatorName = operator?.fullName ?? role?.displayName ?? 'Admin';

      final result = await ref.read(bulkBillingUseCaseProvider).execute(
            BulkBillingParams(
              semesterLabel: _selectedSemester.label,
              months: _selectedSemester.months,
              sppKategoriBiayaId: sppKategori.id,
              createdBy: operatorName,
            ),
          );

      if (!mounted) return;

      // Show result dialog
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text('Hasil Generate SPP'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Periode: ${_selectedSemester.label}'),
                const Divider(),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.add_task, color: Colors.green),
                  title: Text('${result.successCount} tagihan baru dibuat'),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.skip_next, color: Colors.orange),
                  title: Text('${result.skippedCount} tagihan dilewati (sudah ada)'),
                ),
                if (result.failedCount > 0) ...[
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.error_outline, color: Colors.red),
                    title: Text('${result.failedCount} tagihan gagal'),
                    subtitle: Text(result.failedNames.take(3).join('\n')),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Selesai'),
            ),
          ],
        ),
      );

      // Re-fetch count if needed
      await _fetchActiveStudentCount();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menjalankan generate massal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final role = ref.watch(authRoleProvider);
    final isAdmin = role == PinRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate SPP Massal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info banner
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.auto_mode, color: cs.onPrimaryContainer, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate SPP Per Semester',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Membuat 6 bulan tagihan SPP untuk seluruh siswa aktif sekaligus '
                          'sesuai kalender akademik Indonesia.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onPrimaryContainer.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistics card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Siswa',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.people_alt_outlined, color: cs.primary),
                      const SizedBox(width: 10),
                      Text(
                        _isLoadingCount
                            ? 'Menghitung siswa aktif...'
                            : '$_activeStudentCount siswa aktif terdaftar',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: cs.secondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pencegahan duplikasi aktif: tagihan yang sudah ada tidak akan dibuat ulang.',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Semester Selector
          Text(
            'Pilih Semester Tagihan',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<_SemesterChoice>(
            // ignore: deprecated_member_use
            value: _selectedSemester,
            decoration: const InputDecoration(
              labelText: 'Tahun Ajaran & Semester',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_month_outlined),
            ),
            items: _semesterChoices
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: _isLoading
                ? null
                : (val) {
                    if (val != null) {
                      setState(() => _selectedSemester = val);
                    }
                  },
          ),
          const SizedBox(height: 16),

          // Included months preview
          Text(
            'Bulan yang dicakup (6 bulan)',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedSemester.months.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
              itemBuilder: (ctx, i) {
                final (month, year) = _selectedSemester.months[i];
                final monthName = _monthsNames[month - 1];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 13,
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
                  subtitle: Text('Bulan ke-${i + 1} semester'),
                  trailing: Icon(Icons.receipt_long_outlined, size: 18, color: cs.outline),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Execute CTA
          FilledButton.icon(
            onPressed: (_isLoading || !isAdmin || _activeStudentCount == 0)
                ? null
                : _handleExecuteBulkBilling,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.bolt),
            label: Text(
              _isLoading
                  ? 'Sedang Memproses Tagihan Massal...'
                  : 'Generate SPP untuk $_activeStudentCount Siswa',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          if (!isAdmin) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Akses terbatas: Hanya Administrator yang berwenang membuat tagihan.',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
