import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/database/daos/tarif_dao.dart';
import '../../../core/database/tables/siswa_table.dart';
import '../../../core/database/tables/skema_pembayaran_siswa_table.dart';
import '../../../core/database/tables/kategori_biaya_table.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/services/audit_logger_service.dart';
import '../../payments/presentation/pos_checklist_screen.dart';
import '../../settings/presentation/pin_auth_screen.dart';

/// Student Detail Screen — shows profile info and launches POS cashier
class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({super.key, required this.siswaId});
  final int siswaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final siswaFuture = SiswaDao(db).getById(siswaId);

    return FutureBuilder<SiswaData?>(
      future: siswaFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final siswa = snap.data;
        if (siswa == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Siswa')),
            body: const Center(child: Text('Data siswa tidak ditemukan')),
          );
        }
        return _StudentDetailBody(siswa: siswa);
      },
    );
  }
}

class _StudentDetailBody extends ConsumerWidget {
  const _StudentDetailBody({required this.siswa});
  final SiswaData siswa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSD = siswa.sekolahId == 1;
    final role = ref.watch(authRoleProvider);
    final isAdmin = role?.name == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(siswa.namaLengkap),
        actions: [
          if (isAdmin)
            PopupMenuButton<String>(
              onSelected: (val) => _handleMenuAction(context, ref, val),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'custom_rate',
                  child: ListTile(
                    leading: Icon(Icons.tune),
                    title: Text('Atur Tarif Kustom'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'change_status',
                  child: ListTile(
                    leading: Icon(Icons.edit_note),
                    title: Text('Ubah Status'),
                    dense: true,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Profile card
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: isSD
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.secondaryContainer,
                        child: Text(
                          siswa.namaLengkap[0].toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: isSD
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              siswa.namaLengkap,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            _InfoChip(
                                label: 'NIS: ${siswa.nis}',
                                color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.school,
                    label: 'Sekolah',
                    value: isSD ? 'SD IT Baitul Akbar Parabek' : 'SMP IT Darul Ilmi',
                  ),
                  _DetailRow(
                    icon: Icons.class_,
                    label: 'Kelas',
                    value: 'Kelas ${siswa.kelasId}',
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Tahun Masuk',
                    value: siswa.tahunMasuk.toString(),
                  ),
                  _DetailRow(
                    icon: Icons.wc,
                    label: 'Jenis Kelamin',
                    value: siswa.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
                  ),
                  if (siswa.nisn != null)
                    _DetailRow(
                      icon: Icons.badge,
                      label: 'NISN',
                      value: siswa.nisn!,
                    ),
                  if (siswa.kontakWali != null)
                    _DetailRow(
                      icon: Icons.phone,
                      label: 'No. HP Wali',
                      value: siswa.kontakWali!,
                    ),
                  _DetailRow(
                    icon: Icons.circle,
                    label: 'Status',
                    value: siswa.status,
                    valueColor: _statusColor(siswa.status),
                  ),
                ],
              ),
            ),
          ),

          // Custom rates section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _CustomRatesSection(siswaId: siswa.id),
          ),

          // Spacer
          const Spacer(),

          // CTA: Open POS Cashier
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: siswa.status == 'AKTIF'
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PosChecklistScreen(siswaId: siswa.id),
                        ),
                      )
                  : null,
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Buka Kasir / Bayar Tagihan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'AKTIF' => Colors.green,
        'LULUS' => Colors.blue,
        'PINDAH' => Colors.orange,
        'DROP_OUT' => Colors.red,
        _ => Colors.grey,
      };

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'custom_rate':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _CustomRateBottomSheet(siswa: siswa, ref: ref),
        );
      case 'change_status':
        _showChangeStatusDialog(context, ref);
    }
  }

  void _showChangeStatusDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _ChangeStatusDialog(siswa: siswa, ref: ref),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Rates Section (read-only inline) ────────────────────────────────

class _CustomRatesSection extends ConsumerWidget {
  const _CustomRatesSection({required this.siswaId});
  final int siswaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final stream =
        TarifDao(db).watchCustomRatesBySiswa(siswaId);

    return StreamBuilder<List<SkemaPembayaranSiswaData>>(
      stream: stream,
      builder: (ctx, snap) {
        final rates = snap.data ?? [];
        if (rates.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Tarif Kustom Siswa Ini',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...rates.map(
                (r) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.tune, size: 18),
                  title: Text('Kategori ID ${r.kategoriBiayaId}'),
                  trailing: Text(
                    CurrencyFormatter.format(r.nominalKustom),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: r.catatan != null ? Text(r.catatan!) : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Custom Rate Bottom Sheet ───────────────────────────────────────────────

class _CustomRateBottomSheet extends StatefulWidget {
  const _CustomRateBottomSheet({required this.siswa, required this.ref});
  final SiswaData siswa;
  final WidgetRef ref;

  @override
  State<_CustomRateBottomSheet> createState() => _CustomRateBottomSheetState();
}

class _CustomRateBottomSheetState extends State<_CustomRateBottomSheet> {
  int? _selectedKategoriId;
  final _nominalCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  bool _isSaving = false;
  List<KategoriBiayaData> _kategoris = [];

  @override
  void initState() {
    super.initState();
    _loadKategoris();
  }

  Future<void> _loadKategoris() async {
    final db = widget.ref.read(appDatabaseProvider);
    final list = await TarifDao(db).getAllKategori();
    if (mounted) setState(() => _kategoris = list);
  }

  @override
  void dispose() {
    _nominalCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedKategoriId == null) return;
    final nominal = int.tryParse(_nominalCtrl.text.replaceAll('.', ''));
    if (nominal == null || nominal <= 0) return;

    setState(() => _isSaving = true);
    try {
      final db = widget.ref.read(appDatabaseProvider);
      final dao = TarifDao(db);
      final auditLogger = widget.ref.read(auditLoggerProvider);
      final role = widget.ref.read(authRoleProvider);

      await dao.upsertCustomRate(
        SkemaPembayaranSiswaCompanion.insert(
          siswaId: widget.siswa.id,
          kategoriBiayaId: _selectedKategoriId!,
          nominalKustom: nominal,
          catatan: Value(_catatanCtrl.text.trim().isEmpty
              ? null
              : _catatanCtrl.text.trim()),
        ),
      );
      await auditLogger.log(
        userRole: role?.displayName ?? 'Admin',
        actionType: AuditAction.upsertCustomRate,
        entityAffected: 'skema_pembayaran_siswa',
        entityId: widget.siswa.id,
        details:
            'Siswa: ${widget.siswa.namaLengkap} | Kategori: $_selectedKategoriId | Nominal: $nominal',
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarif Kustom untuk ${widget.siswa.namaLengkap}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Kategori Biaya'),
            value: _selectedKategoriId,
            items: _kategoris
                .map((k) => DropdownMenuItem(
                      value: k.id,
                      child: Text(k.namaBiaya),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedKategoriId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nominalCtrl,
            decoration: const InputDecoration(
              labelText: 'Nominal Kustom (IDR)',
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _catatanCtrl,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              child:
                  Text(_isSaving ? 'Menyimpan...' : 'Simpan Tarif Kustom'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Change Status Dialog ───────────────────────────────────────────────────

class _ChangeStatusDialog extends StatefulWidget {
  const _ChangeStatusDialog({required this.siswa, required this.ref});
  final SiswaData siswa;
  final WidgetRef ref;

  @override
  State<_ChangeStatusDialog> createState() => _ChangeStatusDialogState();
}

class _ChangeStatusDialogState extends State<_ChangeStatusDialog> {
  late String _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.siswa.status;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final db = widget.ref.read(appDatabaseProvider);
      final auditLogger = widget.ref.read(auditLoggerProvider);
      final role = widget.ref.read(authRoleProvider);
      await SiswaDao(db).updateStatus(widget.siswa.id, _selected);
      await auditLogger.log(
        userRole: role?.displayName ?? 'Admin',
        actionType: AuditAction.updateSiswaStatus,
        entityAffected: 'siswa',
        entityId: widget.siswa.id,
        details:
            '${widget.siswa.namaLengkap}: ${widget.siswa.status} -> $_selected',
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const statuses = ['AKTIF', 'LULUS', 'PINDAH', 'DROP_OUT'];
    return AlertDialog(
      title: const Text('Ubah Status Siswa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: statuses
            .map(
              (s) => RadioListTile<String>(
                title: Text(s),
                value: s,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v!),
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal')),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}
