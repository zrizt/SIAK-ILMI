import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../data/backup_service.dart';

/// Backup & Restore management screen.
/// Allows administrators to trigger manual database exports to zip
/// and monitor Google Drive sync status.
class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isBackingUp = false;
  BackupResult? _lastResult;
  String? _existingBackupPath;
  DateTime? _existingBackupTimestamp;

  @override
  void initState() {
    super.initState();
    _loadExistingBackup();
  }

  Future<void> _loadExistingBackup() async {
    final service = ref.read(backupServiceProvider);
    final path = await service.getLocalBackupPath();
    if (path != null && mounted) {
      final file = File(path);
      DateTime? timestamp;
      if (await file.exists()) {
        try {
          timestamp = await file.lastModified();
        } catch (_) {}
      }
      setState(() {
        _existingBackupPath = path;
        _existingBackupTimestamp = timestamp;
      });
    }
  }

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.performBackup();

      DateTime? timestamp;
      if (result.hasLocalBackup) {
        final file = File(result.localZipPath);
        if (await file.exists()) {
          try {
            timestamp = await file.lastModified();
          } catch (_) {}
        }
      }
      timestamp ??= DateTime.now();

      if (!mounted) return;

      setState(() {
        _lastResult = result;
        _existingBackupPath = result.localZipPath;
        _existingBackupTimestamp = timestamp;
        _isBackingUp = false;
      });

      _showResultDialog(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBackingUp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat backup: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showResultDialog(BackupResult result) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.hasLocalBackup
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              color: result.hasLocalBackup ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Detail Hasil Backup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.hasLocalBackup
                  ? 'Backup data berhasil dibuat dan diamankan.'
                  : 'Gagal membuat backup data lokal.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (result.hasLocalBackup) ...[
              const Text(
                'Lokasi Arsip:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.localZipPath,
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'Status Cloud (Google Drive):',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              result.cloudUploaded
                  ? 'Berhasil diunggah ke Google Drive'
                  : (result.cloudError ?? 'Google Drive belum tersambung'),
              style: TextStyle(
                color: result.cloudUploaded ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBackup =
        _existingBackupPath != null && _existingBackupPath!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Info Card (Last Backup) ──────────────────────────────
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        hasBackup
                            ? Icons.inventory_2_outlined
                            : Icons.info_outline,
                        color: hasBackup
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Informasi Backup Terakhir',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (hasBackup) ...[
                    Text(
                      'Nama File: ${p.basename(_existingBackupPath!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Lokasi File:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _existingBackupPath!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_existingBackupTimestamp != null)
                      Text(
                        'Waktu: ${_formatDateTime(_existingBackupTimestamp!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ] else ...[
                    const Text('Belum ada backup'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Action Button ────────────────────────────────────────
          FilledButton.icon(
            onPressed: _isBackingUp ? null : _performBackup,
            icon: _isBackingUp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.backup),
            label: Text(
              _isBackingUp ? 'Memproses Backup...' : 'Buat Backup Sekarang',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
          const SizedBox(height: 16),

          // ── Info Banner ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.secondary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.secondary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Google Drive sync belum dikonfigurasi. Backup tersimpan di folder Download perangkat.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Cloud Status Tile ────────────────────────────────────
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                _lastResult == null
                    ? Icons.cloud_queue
                    : (_lastResult!.cloudUploaded
                        ? Icons.cloud_done
                        : Icons.cloud_off),
                color: _lastResult == null
                    ? theme.colorScheme.outline
                    : (_lastResult!.cloudUploaded
                        ? Colors.green
                        : Colors.orange),
              ),
              title: const Text('Status Sinkronisasi Cloud'),
              subtitle: Text(
                _lastResult == null
                    ? 'Belum ada proses backup pada sesi ini'
                    : (_lastResult!.cloudUploaded
                        ? 'Tersinkronisasi ke Google Drive'
                        : (_lastResult!.cloudError ??
                            'Sinkronisasi cloud belum aktif')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
