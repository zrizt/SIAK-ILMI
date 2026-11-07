import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/database/daos/tagihan_dao.dart';
import '../../../core/database/daos/tarif_dao.dart';
import '../../../core/security/operator_service.dart';
import '../../fee_management/domain/bill_generator_engine.dart';
import '../../settings/presentation/pin_auth_screen.dart';
import '../data/dapodik_parser.dart';
import '../data/student_repository.dart';

class _SemesterChoice {
  const _SemesterChoice({
    required this.label,
    required this.months,
  });

  final String label;
  final List<(int month, int year)> months;
}

List<_SemesterChoice> _getSemesterChoices() {
  final now = DateTime.now();
  final currentYear = now.year;
  final choices = <_SemesterChoice>[];

  for (var baseYear = currentYear - 1; baseYear <= currentYear + 1; baseYear++) {
    final ta = '$baseYear/${baseYear + 1}';
    choices.add(_SemesterChoice(
      label: 'Semester 1 TA $ta',
      months: List.generate(6, (i) => (7 + i, baseYear)),
    ));
    choices.add(_SemesterChoice(
      label: 'Semester 2 TA $ta',
      months: List.generate(6, (i) => (1 + i, baseYear + 1)),
    ));
  }
  return choices;
}

const List<String> _monthNames = [
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

/// Screen showing preview, validation status, duplicate detection,
/// and auto-billing options before confirming student import from Excel/CSV.
class ImportPreviewScreen extends ConsumerStatefulWidget {
  const ImportPreviewScreen({
    super.key,
    required this.parseResult,
    required this.tahunMasuk,
  });

  final ParseResult parseResult;
  final int tahunMasuk;

  @override
  ConsumerState<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends ConsumerState<ImportPreviewScreen> {
  bool _isLoading = false;
  bool _autoGenerateBilling = true;
  late final List<_SemesterChoice> _semesterChoices;
  late _SemesterChoice _selectedSemester;

  final Set<String> _existingNisns = {};
  bool _isCheckingDuplicates = true;

  @override
  void initState() {
    super.initState();
    _semesterChoices = _getSemesterChoices();
    _selectedSemester = _pickDefaultSemester();
    _checkDuplicatesInDb();
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

  Future<void> _checkDuplicatesInDb() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final siswaDao = SiswaDao(db);
      for (final row in widget.parseResult.rows) {
        if (row.nisn != null && row.nisn!.isNotEmpty) {
          final existing = await siswaDao.getByNisn(row.nisn!);
          if (existing != null) {
            _existingNisns.add(row.nisn!);
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingDuplicates = false);
      }
    }
  }

  Future<void> _handleConfirmImport() async {
    final role = ref.read(authRoleProvider);
    if (role != PinRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya Administrator yang berwenang melakukan import'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final operator = ref.read(activeOperatorProvider);
      final operatorName = operator?.fullName ?? role?.displayName ?? 'Admin';
      final repository = ref.read(studentRepositoryProvider);
      final db = ref.read(appDatabaseProvider);
      final billEngine = ref.read(billGeneratorEngineProvider);
      final tagihanDao = TagihanDao(db);

      // 1. Transactionally import valid non-duplicate students
      final insertedStudents = await repository.bulkImportStudents(
        widget.parseResult.rows,
        operatorName,
      );

      int billsCreated = 0;

      // 2. Auto-generate billing if toggled
      if (_autoGenerateBilling && insertedStudents.isNotEmpty) {
        final categories = await TarifDao(db).getAllKategori();
        final sppCategories = categories.where((c) => c.namaBiaya.contains('SPP')).toList();

        if (sppCategories.isNotEmpty) {
          final sppKategori = sppCategories.first;

          for (final student in insertedStudents) {
            for (final (month, year) in _selectedSemester.months) {
              final monthName = _monthNames[month - 1];
              final periode = 'SPP $monthName $year';

              // Prevent duplicate billing
              final alreadyBilled = await tagihanDao.itemExistsForPeriodeAndKategori(
                student.id,
                periode,
                sppKategori.id,
              );

              if (alreadyBilled) continue;

              await billEngine.generateBill(
                siswaId: student.id,
                tingkat: student.kelasId,
                periode: periode,
                items: [
                  BillLineItemParam(
                    kategoriBiayaId: sppKategori.id,
                    namaItem: 'SPP $monthName $year',
                    nominalDiskon: 0,
                  ),
                ],
              );
              billsCreated++;
            }
          }
        }
      }

      if (!mounted) return;

      // Show summary dialog
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text('Import Berhasil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                dense: true,
                leading: const Icon(Icons.person_add_alt_1, color: Colors.green),
                title: Text('${insertedStudents.length} siswa berhasil didaftarkan'),
              ),
              if (_existingNisns.isNotEmpty)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.skip_next, color: Colors.orange),
                  title: Text('${_existingNisns.length} siswa dilewati (NISN sudah ada)'),
                ),
              if (_autoGenerateBilling)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.receipt_long, color: Colors.blue),
                  title: Text('$billsCreated tagihan SPP semester dibuat otomatis'),
                ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal melakukan import: $e'),
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
    final totalRows = widget.parseResult.rows.length;
    final errorRows = widget.parseResult.errorRows;
    final duplicateCount = _existingNisns.length;
    final validToImport = totalRows - duplicateCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratinjau Data Siswa'),
      ),
      body: _isCheckingDuplicates
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Memvalidasi dan memeriksa data duplikat...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Cards Row
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: cs.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$validToImport',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                'Siap Diimport',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: cs.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$duplicateCount',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              Text(
                                'Duplikat (Lewati)',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: cs.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${errorRows.length}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: errorRows.isNotEmpty ? Colors.red : cs.outline,
                                ),
                              ),
                              Text(
                                'Baris Error',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Auto-Billing Configuration Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Otomatisasi Tagihan PPDB',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Buat Tagihan SPP Semester Otomatis'),
                          subtitle: const Text(
                            'Siswa baru yang valid akan langsung dibuatkan 6 bulan tagihan SPP '
                            'sesuai tingkat kelasnya.',
                          ),
                          value: _autoGenerateBilling,
                          onChanged: _isLoading
                              ? null
                              : (val) => setState(() => _autoGenerateBilling = val),
                        ),
                        if (_autoGenerateBilling) ...[
                          const SizedBox(height: 8),
                          DropdownButtonFormField<_SemesterChoice>(
                            // ignore: deprecated_member_use
                            value: _selectedSemester,
                            decoration: const InputDecoration(
                              labelText: 'Pilih Semester SPP',
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
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Error rows expansion if any
                if (errorRows.isNotEmpty) ...[
                  ExpansionTile(
                    initiallyExpanded: false,
                    leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    title: Text(
                      '${errorRows.length} Baris Data Tidak Lengkap / Ditolak',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    children: errorRows
                        .map(
                          (err) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.close, size: 16, color: Colors.red),
                            title: Text(err, style: theme.textTheme.bodySmall),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Student Preview List
                Text(
                  'Daftar Siswa ($totalRows baris terbaca)',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.parseResult.rows.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (ctx, i) {
                      final item = widget.parseResult.rows[i];
                      final isDuplicate =
                          item.nisn != null && _existingNisns.contains(item.nisn);

                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              isDuplicate ? Colors.orange.shade100 : cs.primaryContainer,
                          child: Text(
                            item.jenisKelamin,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDuplicate ? Colors.orange.shade900 : cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                        title: Text(
                          item.namaLengkap,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: isDuplicate ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          'Kelas ${item.kelasId} • NISN: ${item.nisn ?? "-"}',
                        ),
                        trailing: isDuplicate
                            ? const Chip(
                                label: Text(
                                  'Duplikat',
                                  style: TextStyle(fontSize: 10, color: Colors.orange),
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              )
                            : const Chip(
                                label: Text(
                                  'Siap',
                                  style: TextStyle(fontSize: 10, color: Colors.green),
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Confirm Import CTA
                FilledButton.icon(
                  onPressed: (_isLoading || validToImport <= 0)
                      ? null
                      : _handleConfirmImport,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _isLoading
                        ? 'Sedang Mengimport Data...'
                        : 'Konfirmasi & Import $validToImport Siswa',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
    );
  }
}
