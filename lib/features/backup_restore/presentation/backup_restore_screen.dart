import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backup_service.dart';
import '../../settings/presentation/pin_auth_screen.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isBackingUp = false;
  BackupResult? _lastResult;
  String? _lastLocalPath;

  @override
  void initState() {
    super.initState();
    _loadLastBackupPath();
  }

  Future<void> _loadLastBackupPath() async {
    final service = ref.read(backupServiceProvider);
    final path = await service.getLocalBackupPath();
    if (mounted) setState(() => _lastLocalPath = path);
  }

  Future<void> _startBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.performBackup();
      if (mounted) {
        setState(() {
          _lastResult = result;
          _lastLocalPath = result.localZipPath;
          _isBackingUp = false;
        });
        _showResultSnackbar(result);
      }
    } catch (e) {
      // Should never reach here (fail-silent), but guard defensively
      if (mounted) {
        setState(() => _isBackingUp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup error: $e')),
        );
      }
    }
  }

  void _showResultSnackbar(BackupResult result) {
    final msg = result.cloudUploaded
        ? 'Backup selesai & berhasil diupload ke Google Drive'
        : 'Backup lokal berhasil disimpan. ${result.cloudError ?? ''}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            result.cloudUploaded ? Colors.green : Colors.orange.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authRoleProvider);
    final isAdmin = role?.name == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.backup,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status Backup',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_lastLocalPath != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.folder_zip, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _lastLocalPath!.split('/').last,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const Text('Belum ada backup lokal'),
                  if (_lastResult != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          _lastResult!.cloudUploaded
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          size: 16,
                          color: _lastResult!.cloudUploaded
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _lastResult!.cloudUploaded
                              ? 'Tersinkron ke Google Drive'
                              : 'Google Drive: ${_lastResult!.cloudError ?? "Tidak aktif"}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Backup action
          if (isAdmin) ...[
            FilledButton.icon(
              onPressed: _isBackingUp ? null : _startBackup,
              icon: _isBackingUp
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.backup),
              label: Text(_isBackingUp
                  ? 'Membuat backup...'
                  : 'Buat Backup Sekarang'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isBackingUp ? null : _loadLastBackupPath,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
            ),
          ] else
            const Card(
              child: ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Hanya Admin yang dapat memulai backup'),
              ),
            ),

          const SizedBox(height: 24),

          // Info section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Backup',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const _InfoRow(
                    icon: Icons.storage,
                    text: 'Database SQLite dikompres menjadi file .zip',
                  ),
                  const _InfoRow(
                    icon: Icons.folder,
                    text: 'Disimpan di folder Download/SIAK-ILMI-Backup',
                  ),
                  const _InfoRow(
                    icon: Icons.cloud_outlined,
                    text:
                        'Upload Google Drive opsional (akan aktif di Fase 6)',
                  ),
                  const _InfoRow(
                    icon: Icons.offline_bolt,
                    text: 'Backup lokal selalu berhasil tanpa internet',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
