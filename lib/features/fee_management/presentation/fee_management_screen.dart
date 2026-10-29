import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/tarif_dao.dart';
import '../../../core/database/tables/tarif_master_table.dart';
import '../../../core/database/tables/skema_pembayaran_siswa_table.dart';
import '../../../core/database/tables/kategori_biaya_table.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/services/audit_logger_service.dart';
import '../../settings/presentation/pin_auth_screen.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final tarifDaoProvider = Provider<TarifDao>(
  (ref) => TarifDao(ref.watch(appDatabaseProvider)),
);

final allKategoriProvider = StreamProvider<List<KategoriBiayaData>>(
  (ref) => ref.watch(tarifDaoProvider).watchAllKategori(),
);

final allTarifMasterProvider = StreamProvider<List<TarifMasterData>>(
  (ref) => ref.watch(tarifDaoProvider).watchAllTarifMaster(),
);

// ── Fee Management Screen ──────────────────────────────────────────────────

class FeeManagementScreen extends ConsumerWidget {
  const FeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Biaya'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'TARIF STANDAR'),
              Tab(text: 'KATEGORI'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MasterTarifTab(),
            _KategoriBiayaTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTarifDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Tarif Baru'),
        ),
      ),
    );
  }

  static void _showAddTarifDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _EditTarifDialog(tarifData: null, ref: ref),
    );
  }
}

// ── Master Tariff Tab ──────────────────────────────────────────────────────

class _MasterTarifTab extends ConsumerWidget {
  const _MasterTarifTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarifAsync = ref.watch(allTarifMasterProvider);
    final kategoriAsync = ref.watch(allKategoriProvider);

    return tarifAsync.when(
      data: (tarifs) => kategoriAsync.when(
        data: (kategoris) {
          // Group tariffs by kategori
          final grouped = <int, List<TarifMasterData>>{};
          for (final t in tarifs) {
            grouped.putIfAbsent(t.kategoriBiayaId, () => []).add(t);
          }
          if (grouped.isEmpty) {
            return const Center(child: Text('Belum ada tarif master'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: grouped.length,
            itemBuilder: (ctx, i) {
              final kategoriId = grouped.keys.elementAt(i);
              final items = grouped[kategoriId]!
                ..sort((a, b) => a.tingkat.compareTo(b.tingkat));
              final kategori = kategoris.firstWhere(
                (k) => k.id == kategoriId,
                orElse: () => KategoriBiayaData(
                  id: kategoriId,
                  namaBiaya: 'Kategori $kategoriId',
                  tipe: '',
                ),
              );
              return _TarifKategoriCard(
                kategori: kategori,
                tarifs: items,
                ref: ref,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _TarifKategoriCard extends StatelessWidget {
  const _TarifKategoriCard({
    required this.kategori,
    required this.tarifs,
    required this.ref,
  });
  final KategoriBiayaData kategori;
  final List<TarifMasterData> tarifs;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              kategori.namaBiaya,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(kategori.tipe),
            trailing: Chip(
              label: Text(kategori.tipe),
              backgroundColor: kategori.tipe == 'Rutin'
                  ? Colors.blue.shade50
                  : Colors.orange.shade50,
            ),
          ),
          const Divider(height: 1),
          ...tarifs.map(
            (t) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                child: Text(
                  t.tingkat.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              title: Text('Kelas ${t.tingkat}'),
              trailing: Text(
                CurrencyFormatter.format(t.nominal),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => showDialog(
                context: context,
                builder: (_) => _EditTarifDialog(tarifData: t, ref: ref),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Kategori Tab ───────────────────────────────────────────────────────────

class _KategoriBiayaTab extends ConsumerWidget {
  const _KategoriBiayaTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kategoriAsync = ref.watch(allKategoriProvider);
    return kategoriAsync.when(
      data: (items) => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final k = items[i];
          return ListTile(
            title: Text(k.namaBiaya),
            subtitle: Text('Tipe: ${k.tipe}'),
            trailing: Chip(label: Text(k.tipe)),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// ── Edit Tarif Dialog ──────────────────────────────────────────────────────

class _EditTarifDialog extends StatefulWidget {
  const _EditTarifDialog({required this.tarifData, required this.ref});
  final TarifMasterData? tarifData;
  final WidgetRef ref;

  @override
  State<_EditTarifDialog> createState() => _EditTarifDialogState();
}

class _EditTarifDialogState extends State<_EditTarifDialog> {
  final _nominalCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.tarifData != null) {
      _nominalCtrl.text = widget.tarifData!.nominal.toString();
    }
  }

  @override
  void dispose() {
    _nominalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nominal = int.tryParse(_nominalCtrl.text.replaceAll('.', ''));
    if (nominal == null || nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak valid')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final dao = widget.ref.read(tarifDaoProvider);
      final auditLogger = widget.ref.read(auditLoggerProvider);
      final role = widget.ref.read(authRoleProvider);

      if (widget.tarifData != null) {
        await dao.upsertTarifMaster(
          TarifMasterCompanion(
            id: Value(widget.tarifData!.id),
            kategoriBiayaId: Value(widget.tarifData!.kategoriBiayaId),
            tingkat: Value(widget.tarifData!.tingkat),
            nominal: Value(nominal),
          ),
        );
        await auditLogger.log(
          userRole: role?.displayName ?? 'Admin',
          actionType: AuditAction.updateTarifMaster,
          entityAffected: 'tarif_master',
          entityId: widget.tarifData!.id,
          details: 'Nominal diubah menjadi $nominal',
        );
      }
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
    return AlertDialog(
      title: Text(
        widget.tarifData != null
            ? 'Edit Tarif Kelas ${widget.tarifData!.tingkat}'
            : 'Tambah Tarif Baru',
      ),
      content: TextField(
        controller: _nominalCtrl,
        decoration: const InputDecoration(
          labelText: 'Nominal (IDR)',
          prefixText: 'Rp ',
        ),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}
