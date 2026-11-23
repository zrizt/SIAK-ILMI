import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/security/operator_service.dart';
import '../../settings/presentation/pin_auth_screen.dart';
import '../data/excel_export_service.dart';
import '../domain/excel_export_options.dart';

/// Modal dialog for configuring and generating an Excel (.xlsx) financial report.
class ExportExcelDialog extends ConsumerStatefulWidget {
  const ExportExcelDialog({super.key});

  /// Helper to display this dialog cleanly.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const ExportExcelDialog(),
    );
  }

  @override
  ConsumerState<ExportExcelDialog> createState() => _ExportExcelDialogState();
}

class _ExportExcelDialogState extends ConsumerState<ExportExcelDialog> {
  int? _selectedSekolahId; // null = Semua
  String? _selectedTahunAjaran; // null = Semua
  bool _isExporting = false;

  List<TahunAjaranData> _tahunAjaranList = [];
  bool _isLoadingTa = true;

  @override
  void initState() {
    super.initState();
    _loadTahunAjaran();
  }

  Future<void> _loadTahunAjaran() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final list = await (db.select(db.tahunAjaran)
            ..orderBy([(t) => OrderingTerm.desc(t.id)]))
          .get();
      if (mounted) {
        setState(() {
          _tahunAjaranList = list;
          _isLoadingTa = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTa = false);
    }
  }

  Future<void> _executeExport() async {
    setState(() => _isExporting = true);
    try {
      final op = ref.read(activeOperatorProvider);
      final role = ref.read(authRoleProvider);
      final operatorName = op?.fullName ?? (role?.displayName ?? 'Admin');

      final options = ExcelExportOptions(
        sekolahId: _selectedSekolahId,
        tahunAjaran: _selectedTahunAjaran,
        operatorName: operatorName,
      );

      final service = ref.read(excelExportServiceProvider);
      final filePath = await service.exportFinancialReport(options);

      if (!mounted) return;
      setState(() => _isExporting = false);
      Navigator.of(context).pop();

      // Trigger native share sheet so user can send via WhatsApp or save file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Laporan Keuangan SIAK-ILMI',
        text: 'Laporan Keuangan SIAK-ILMI: ${options.sekolahLabel} (${options.tahunAjaranLabel})',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat laporan Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.table_view_rounded, color: Color(0xFF1B5E20), size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Laporan Excel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Format Microsoft Excel (.xlsx)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filter Sekolah ───────────────────────────────────────────────
            const Text(
              '1. Pilih Lembaga / Sekolah:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('Semua Sekolah'),
                  selected: _selectedSekolahId == null,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSekolahId = null);
                  },
                ),
                ChoiceChip(
                  label: const Text('SD IT'),
                  selected: _selectedSekolahId == 1,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSekolahId = 1);
                  },
                ),
                ChoiceChip(
                  label: const Text('SMP IT'),
                  selected: _selectedSekolahId == 2,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSekolahId = 2);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Filter Tahun Ajaran ──────────────────────────────────────────
            const Text(
              '2. Pilih Tahun Ajaran:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            if (_isLoadingTa)
              const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ))
            else
              DropdownButtonFormField<String?>(
                initialValue: _selectedTahunAjaran,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Semua Tahun Ajaran'),
                  ),
                  ..._tahunAjaranList.map((ta) => DropdownMenuItem<String?>(
                        value: ta.namaTa,
                        child: Text(
                          'Tahun Ajaran ${ta.namaTa}${ta.isAktif == 1 ? ' (Aktif)' : ''}',
                        ),
                      )),
                ],
                onChanged: (val) => setState(() => _selectedTahunAjaran = val),
              ),
            const SizedBox(height: 16),

            // ── Preview Lembar Kerja (Sheets) ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Isi Lembar Kerja (3 Sheets):',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  _sheetItem(Icons.analytics_outlined, 'Sheet 1: Ringkasan Eksekutif (KPI & Kategori)'),
                  const SizedBox(height: 4),
                  _sheetItem(Icons.list_alt_rounded, 'Sheet 2: Rekap Tagihan & Piutang Siswa'),
                  const SizedBox(height: 4),
                  _sheetItem(Icons.receipt_long_rounded, 'Sheet 3: Riwayat Transaksi Kasir & Kuitansi'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
          ),
          onPressed: _isExporting ? null : _executeExport,
          icon: _isExporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.download_rounded),
          label: Text(_isExporting ? 'Memproses...' : 'Export & Bagikan Excel'),
        ),
      ],
    );
  }

  Widget _sheetItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}
