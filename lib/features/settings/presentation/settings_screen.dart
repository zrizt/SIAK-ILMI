import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/presentation/pin_auth_screen.dart';
import '../../backup_restore/presentation/backup_restore_screen.dart';
import '../../../core/security/pin_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authRoleProvider);
    final isAdmin = role?.name == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          // ── User Profile ──────────────────────────────────────
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(role?.displayName ?? 'Tidak Login'),
            subtitle: Text(role?.name == 'admin'
                ? 'Administrator — Akses Penuh'
                : 'Kepala Sekolah — Akses Baca'),
            trailing: TextButton(
              onPressed: () =>
                  ref.read(authRoleProvider.notifier).state = null,
              child: const Text('Keluar'),
            ),
          ),
          const Divider(),

          // ── Security ──────────────────────────────────────────
          const _SectionHeader(title: 'Keamanan'),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Ubah PIN Admin'),
              subtitle: const Text('Ganti PIN 6 digit untuk akun Admin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showChangePinDialog(context, PinRole.admin),
            ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.lock_open),
              title: const Text('Ubah PIN Kepala Sekolah'),
              subtitle: const Text('Ganti PIN untuk akun Viewer'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showChangePinDialog(context, PinRole.viewer),
            ),
          if (!isAdmin)
            const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Pengaturan PIN hanya untuk Admin'),
              subtitle: Text('Login sebagai Admin untuk mengubah PIN'),
            ),
          const Divider(),

          // ── Backup ────────────────────────────────────────────
          const _SectionHeader(title: 'Backup & Sinkronisasi'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Buat backup lokal atau upload ke Google Drive'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
            ),
          ),
          const Divider(),

          // ── About ─────────────────────────────────────────────
          const _SectionHeader(title: 'Tentang'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('SIAK-ILMI'),
            subtitle: Text(
              'Sistem Informasi Administrasi dan Keuangan Darul Ilmi\n'
              'Versi 1.0.0 — Build 1',
            ),
            isThreeLine: true,
          ),
          const ListTile(
            leading: Icon(Icons.school),
            title: Text('Institusi'),
            subtitle: Text(
              'SMP IT Darul Ilmi & SD IT Baitul Akbar Parabek',
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, PinRole targetRole) {
    showDialog(
      context: context,
      builder: (_) => _ChangePinDialog(targetRole: targetRole),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ChangePinDialog extends StatefulWidget {
  const _ChangePinDialog({required this.targetRole});
  final PinRole targetRole;

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'PIN baru tidak cocok');
      return;
    }
    if (_newCtrl.text.length != 6) {
      setState(() => _error = 'PIN harus 6 digit');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final success = await PinService.changePin(
      currentAdminPin: _currentCtrl.text,
      targetRole: widget.targetRole,
      newPin: _newCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN berhasil diubah')),
      );
    } else {
      setState(() {
        _isSaving = false;
        _error = 'PIN Admin saat ini salah';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ubah PIN ${widget.targetRole.displayName}',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentCtrl,
            decoration: const InputDecoration(labelText: 'PIN Admin Saat Ini'),
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
          ),
          TextField(
            controller: _newCtrl,
            decoration: const InputDecoration(labelText: 'PIN Baru'),
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
          ),
          TextField(
            controller: _confirmCtrl,
            decoration: const InputDecoration(labelText: 'Konfirmasi PIN Baru'),
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
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
