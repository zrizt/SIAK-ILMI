import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/operator_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../backup_restore/data/backup_service.dart';
import '../../backup_restore/presentation/backup_restore_screen.dart';
import '../../receipts/data/thermal_printer_adapter.dart';
import 'operator_management_screen.dart';
import 'pin_auth_screen.dart';

/// Settings screen for SIAK-ILMI application configuration,
/// PIN management, Bluetooth printer setup, and backups.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBackingUp = false;

  Future<void> _handleBackupNow() async {
    setState(() => _isBackingUp = true);

    // Show loading dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sedang membuat backup...'),
            ],
          ),
        ),
      ),
    );

    late final BackupResult backupResult;
    try {
      backupResult = await ref.read(backupServiceProvider).performBackup();
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _isBackingUp = false);
      }
    }

    if (!mounted) return;

    // Show result dialog
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              backupResult.hasLocalBackup
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              color: backupResult.hasLocalBackup ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Hasil Backup Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              backupResult.hasLocalBackup
                  ? 'Backup lokal berhasil dibuat:'
                  : 'Gagal membuat backup lokal.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (backupResult.hasLocalBackup) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  backupResult.localZipPath,
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Status Google Drive:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(ctx).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              backupResult.cloudUploaded
                  ? 'Tersinkronisasi ke Google Drive'
                  : (backupResult.cloudError ?? 'Google Drive belum tersambung'),
              style: TextStyle(
                color: backupResult.cloudUploaded ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(PinRole targetRole) {
    showDialog<void>(
      context: context,
      builder: (_) => _ChangePinDialog(targetRole: targetRole),
    );
  }

  void _showOperatorLoginDialog(BuildContext context) {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? errorMsg;
    bool isLoggingIn = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dCtx, setDState) {
          return AlertDialog(
            title: const Text('Login Operator'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Masuk dengan akun operator kasir untuk mencantumkan nama Anda di kuitansi.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMsg!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoggingIn ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: isLoggingIn
                    ? null
                    : () async {
                        final username = userCtrl.text.trim();
                        final password = passCtrl.text;

                        if (username.isEmpty || password.isEmpty) {
                          setDState(() => errorMsg = 'Username dan password wajib diisi');
                          return;
                        }

                        setDState(() {
                          isLoggingIn = true;
                          errorMsg = null;
                        });

                        final op = await ref
                            .read(operatorServiceProvider)
                            .login(username, password);

                        if (ctx.mounted) {
                          if (op != null) {
                            ref.read(activeOperatorProvider.notifier).state = op;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Login berhasil sebagai ${op.fullName}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setDState(() {
                              isLoggingIn = false;
                              errorMsg = 'Username atau password salah, atau akun nonaktif';
                            });
                          }
                        }
                      },
                child: isLoggingIn
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Masuk'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPrinterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PrinterBottomSheet(
        printerAdapter: ref.read(thermalPrinterAdapterProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = ref.watch(authRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // ── 1. Info App ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary,
                          child: const Icon(
                            Icons.account_balance,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SIAK-ILMI v1.0.0',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                'Darul Ilmi — Offline First',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sistem Informasi Administrasi dan Keuangan SMP IT Darul Ilmi & SD IT Baitul Akbar Parabek',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.9),
                      ),
                    ),
                    if (role != null) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sesi Login: ${role.displayName}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  theme.colorScheme.onPrimaryContainer,
                            ),
                            onPressed: () => ref
                                .read(authRoleProvider.notifier)
                                .state = null,
                            child: const Text('Keluar'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── 2. Keamanan PIN ──────────────────────────────────────
          const _SectionHeader(title: 'Keamanan PIN'),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Ganti PIN Admin'),
            subtitle: const Text('Ubah 6 digit PIN akun Administrator'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePinDialog(PinRole.admin),
          ),
          ListTile(
            leading: const Icon(Icons.visibility_outlined),
            title: const Text('Ganti PIN Viewer'),
            subtitle: const Text('Ubah 6 digit PIN akun Kepala Sekolah'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePinDialog(PinRole.viewer),
          ),
          const Divider(),

          // ── Operator ──
          const _SectionHeader(title: 'Akun Operator'),
          Consumer(
            builder: (ctx, ref, _) {
              final op = ref.watch(activeOperatorProvider);
              return ListTile(
                leading: const Icon(Icons.person_pin_outlined),
                title: Text(op != null ? op.fullName : 'Belum Login Operator'),
                subtitle: Text(
                  op != null
                      ? '@${op.username}${op.nip != null && op.nip!.isNotEmpty ? ' (NIP: ${op.nip})' : ''} • Nama tercatat pada kuitansi'
                      : 'Login untuk mencatat nama petugas pada kuitansi',
                ),
                trailing: op != null
                    ? TextButton(
                        onPressed: () {
                          ref.read(activeOperatorProvider.notifier).state = null;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Operator telah logout')),
                          );
                        },
                        child: const Text('Keluar'),
                      )
                    : TextButton(
                        onPressed: () => _showOperatorLoginDialog(context),
                        child: const Text('Login'),
                      ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Kelola Akun Operator'),
            subtitle: const Text('Daftar operator kasir dan hak akses kuitansi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OperatorManagementScreen(),
              ),
            ),
          ),
          const Divider(),

          // ── 3. Tampilan ──────────────────────────────────────────────────
          const _SectionHeader(title: 'Tampilan'),
          _ThemeModeTile(),
          const Divider(),

          // ── 4. Printer ───────────────────────────────────────────
          const _SectionHeader(title: 'Printer'),
          ListTile(
            leading: const Icon(Icons.print_outlined),
            title: const Text('Printer Bluetooth'),
            subtitle: const Text('Pindai dan pilih printer termal kasir'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showPrinterBottomSheet,
          ),
          const Divider(),

          // ── 4. Backup ────────────────────────────────────
          const _SectionHeader(title: 'Backup'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup Data Sekarang'),
            subtitle: const Text('Simpan arsip SQLite lokal & sinkron ke cloud'),
            trailing: _isBackingUp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isBackingUp ? null : _handleBackupNow,
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Backup'),
            subtitle: const Text('Lihat status file backup & restore data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BackupRestoreScreen(),
              ),
            ),
          ),
          const Divider(),

          // ── 5. Tentang ───────────────────────────────────────────
          const _SectionHeader(title: 'Tentang'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versi'),
            trailing: Text(
              '1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Database'),
            trailing: Text(
              'SQLite via Drift',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.1,
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
  final _oldPinCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPinCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final oldPin = _oldPinCtrl.text.trim();
    final newPin = _newPinCtrl.text.trim();
    final confirmPin = _confirmPinCtrl.text.trim();

    if (oldPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      setState(() => _errorMessage = 'Semua bidang PIN wajib diisi');
      return;
    }

    if (newPin.length != 6) {
      setState(() => _errorMessage = 'PIN baru harus tepat 6 digit angka');
      return;
    }

    if (newPin != confirmPin) {
      setState(() => _errorMessage = 'Konfirmasi PIN baru tidak sesuai');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Validate via PinService
      final verifiedRole = await PinService.verifyPin(oldPin);
      if (verifiedRole != widget.targetRole) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'PIN lama salah';
        });
        return;
      }

      await PinService.setPin(widget.targetRole, newPin);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PIN ${widget.targetRole.displayName} berhasil diubah'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Gagal menyimpan PIN: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Ganti PIN ${widget.targetRole.displayName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPinCtrl,
              decoration: const InputDecoration(
                labelText: 'PIN Lama',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPinCtrl,
              decoration: const InputDecoration(
                labelText: 'PIN Baru',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_reset),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPinCtrl,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi PIN Baru',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.check),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan PIN'),
        ),
      ],
    );
  }
}

class _PrinterBottomSheet extends StatefulWidget {
  const _PrinterBottomSheet({required this.printerAdapter});
  final ThermalPrinterAdapter printerAdapter;

  @override
  State<_PrinterBottomSheet> createState() => _PrinterBottomSheetState();
}

class _PrinterBottomSheetState extends State<_PrinterBottomSheet> {
  bool _isScanning = true;
  List<dynamic> _devices = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      final devices = await widget.printerAdapter.listDevices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Printer Bluetooth',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isScanning ? null : _scanDevices,
                ),
              ],
            ),
            const Divider(),
            if (_isScanning)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Memindai perangkat Bluetooth...'),
                    ],
                  ),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Error: $_error',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              )
            else if (_devices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.bluetooth_searching,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tidak ada printer Bluetooth yang terpasang.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pastikan Bluetooth aktif dan perangkat telah dipasangkan (paired) di Pengaturan Android.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return ListTile(
                    leading: const Icon(Icons.print),
                    title: Text(device.name ?? 'Printer Bluetooth'),
                    subtitle: Text(device.address ?? '-'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      Navigator.pop(context);
                      final connected =
                          await widget.printerAdapter.connect(device);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            connected
                                ? 'Terhubung ke ${device.name ?? 'Printer'}'
                                : 'Gagal menghubungkan ke printer',
                          ),
                          backgroundColor:
                              connected ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Theme Mode Tile ──────────────────────────────────────────────────────────

class _ThemeModeTile extends ConsumerWidget {
  // ignore: prefer_const_constructors_in_immutables
  _ThemeModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    IconData icon;
    String label;
    switch (themeMode) {
      case ThemeMode.light:
        icon = Icons.light_mode_outlined;
        label = 'Terang';
      case ThemeMode.dark:
        icon = Icons.dark_mode_outlined;
        label = 'Gelap';
      case ThemeMode.system:
        icon = Icons.brightness_auto_outlined;
        label = 'Ikut Sistem';
    }

    return ListTile(
      leading: Icon(icon),
      title: const Text('Mode Tampilan'),
      subtitle: Text(label),
      trailing: PopupMenuButton<ThemeMode>(
        icon: const Icon(Icons.tune_outlined),
        tooltip: 'Pilih mode tampilan',
        onSelected: notifier.setMode,
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: ThemeMode.light,
            child: Row(
              children: [
                Icon(Icons.light_mode_outlined),
                SizedBox(width: 10),
                Text('Terang'),
              ],
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.dark,
            child: Row(
              children: [
                Icon(Icons.dark_mode_outlined),
                SizedBox(width: 10),
                Text('Gelap'),
              ],
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.system,
            child: Row(
              children: [
                Icon(Icons.brightness_auto_outlined),
                SizedBox(width: 10),
                Text('Ikut Sistem'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
