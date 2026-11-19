import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/config/supabase_config.dart';
import '../data/backup_service.dart';
import '../data/supabase_backup_adapter.dart';

/// Backup & Restore management screen.
/// Supports:
/// - Local ZIP backup (always offline-ready)
/// - Supabase direct cloud backup/restore (no user login required)
/// - Safe restore with rollback guard and restart prompt
class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isLoadingCloud = false;

  BackupResult? _lastResult;
  List<File> _localBackups = [];
  List<CloudBackupEntry> _cloudBackups = [];

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    await _loadLocalBackups();
    final supabase = ref.read(supabaseBackupServiceProvider);
    if (supabase.isConfigured) {
      await _loadCloudBackups();
    }
  }

  Future<void> _loadLocalBackups() async {
    final service = ref.read(supabaseBackupServiceProvider);
    final backups = await service.getLocalBackups();
    if (mounted) setState(() => _localBackups = backups);
  }

  Future<void> _loadCloudBackups() async {
    setState(() => _isLoadingCloud = true);
    try {
      final service = ref.read(supabaseBackupServiceProvider);
      final backups = await service.listCloudBackups();
      if (mounted) setState(() => _cloudBackups = backups);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingCloud = false);
    }
  }

  // ── Backup & Restore actions ──────────────────────────────────────────────

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.performBackup();

      await _loadLocalBackups();
      if (result.cloudUploaded) await _loadCloudBackups();

      if (!mounted) return;
      setState(() {
        _lastResult = result;
        _isBackingUp = false;
      });
      _showResultDialog(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBackingUp = false);
      _showSnackBar('Terjadi kesalahan saat backup: $e', isError: true);
    }
  }

  Future<void> _pickAndRestoreZip() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) await _confirmAndRestore(path);
    }
  }

  Future<void> _restoreFromCloud(CloudBackupEntry entry) async {
    setState(() => _isRestoring = true);
    try {
      final service = ref.read(supabaseBackupServiceProvider);
      final localPath = await service.downloadCloudBackup(entry.storagePath);
      if (!mounted) return;
      setState(() => _isRestoring = false);
      if (localPath == null) {
        _showSnackBar(
            'Gagal mengunduh backup dari cloud. Periksa koneksi internet.',
            isError: true);
        return;
      }
      await _confirmAndRestore(localPath);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRestoring = false);
      _showSnackBar('Gagal mengunduh backup: $e', isError: true);
    }
  }

  Future<void> _confirmAndRestore(String zipPath) async {
    final fileName = p.basename(zipPath);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Konfirmasi Pemulihan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PERINGATAN: Memulihkan database akan menimpa seluruh data '
              'siswa, tagihan, dan riwayat transaksi saat ini!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 12),
            Text('File arsip: $fileName'),
            const SizedBox(height: 8),
            const Text(
                'Safety backup otomatis dibuat sebelum penimpaan. '
                'Restart aplikasi diperlukan setelah restore berhasil.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Pulihkan Database'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);
    try {
      final service = ref.read(backupServiceProvider);
      await service.restoreFromZip(zipPath);

      if (!mounted) return;
      setState(() => _isRestoring = false);

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Pemulihan Berhasil'),
            ],
          ),
          content: const Text(
            'Database berhasil dipulihkan dari arsip backup.\n\n'
            'Silakan restart aplikasi agar seluruh data termuat sepenuhnya.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRestoring = false);
      _showSnackBar('Gagal memulihkan database: $e',
          isError: true, duration: const Duration(seconds: 8));
    }
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

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
              const Text('Lokasi Arsip:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(result.localZipPath,
                    style: Theme.of(ctx).textTheme.bodySmall),
              ),
              const SizedBox(height: 12),
            ],
            const Text('Status Cloud (Supabase):',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              result.cloudUploaded
                  ? 'Berhasil diunggah ke Supabase Storage'
                  : (result.cloudError ?? 'Supabase belum tersambung'),
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

  void _showSnackBar(String message,
      {bool isError = false,
      Duration duration = const Duration(seconds: 4)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        duration: duration,
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabaseService = ref.watch(supabaseBackupServiceProvider);
    final isConfigured = supabaseService.isConfigured;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Supabase Cloud Card (Direct Connection) ─────────────────────
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isConfigured
                    ? Colors.green.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Supabase Cloud Backup',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Chip(
                        label: Text(
                          isConfigured ? 'Terkoneksi' : 'Belum Dikonfigurasi',
                          style: TextStyle(
                            fontSize: 11,
                            color: isConfigured
                                ? Colors.green.shade900
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        backgroundColor: isConfigured
                            ? Colors.green.shade100
                            : theme.colorScheme.surfaceContainerHighest,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isConfigured
                        ? 'Cloud backup terhubung langsung ke bucket "$supabaseBucketId". Setiap kali menekan tombol "Buat Backup", database lokal diamankan dan otomatis diunggah ke cloud tanpa perlu login.'
                        : 'Masukkan URL dan Public Key di supabase_config.dart untuk mengaktifkan sinkronisasi cloud otomatis.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Action Buttons ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      (_isBackingUp || _isRestoring) ? null : _performBackup,
                  icon: _isBackingUp
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.backup),
                  label: Text(
                    _isBackingUp ? 'Memproses...' : 'Buat Backup',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_isBackingUp || _isRestoring)
                      ? null
                      : _pickAndRestoreZip,
                  icon: _isRestoring
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.settings_backup_restore),
                  label: Text(
                    _isRestoring ? 'Memulihkan...' : 'Pulihkan Zip',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Cloud Sync Status ───────────────────────────────────────────
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
                    ? (isConfigured
                        ? 'Siap sinkron otomatis ke Supabase Storage'
                        : 'Belum ada proses backup pada sesi ini')
                    : (_lastResult!.cloudUploaded
                        ? 'Tersinkronisasi ke Supabase Storage ($supabaseBucketId)'
                        : (_lastResult!.cloudError ??
                            'Sinkronisasi cloud belum aktif')),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Cloud Backup List ───────────────────────────────────────────
          if (isConfigured) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Backup di Cloud (${_cloudBackups.length})',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (_isLoadingCloud)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: _loadCloudBackups,
                    tooltip: 'Muat ulang daftar cloud',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_cloudBackups.isEmpty && !_isLoadingCloud)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Belum ada file di cloud. Tekan "Buat Backup" untuk mengunggah.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              )
            else
              ..._cloudBackups.take(5).map((entry) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.cloud_outlined),
                    title: Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text(
                      '${_formatFileSize(entry.sizeBytes)} • '
                      '${_formatDateTime(entry.createdAt)}',
                      style: TextStyle(
                          fontSize: 11, color: theme.colorScheme.outline),
                    ),
                    trailing: TextButton.icon(
                      onPressed: _isRestoring
                          ? null
                          : () => _restoreFromCloud(entry),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Pulihkan',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 8),
          ],

          // ── Local Backup History ────────────────────────────────────────
          if (_localBackups.isNotEmpty) ...[
            Text(
              'Riwayat Backup Lokal (${_localBackups.length})',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._localBackups.take(5).map((file) {
              final fileName = p.basename(file.path);
              int sizeBytes = 0;
              DateTime? modified;
              try {
                sizeBytes = file.lengthSync();
                modified = file.lastModifiedSync();
              } catch (_) {}

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  subtitle: Text(
                    '${_formatFileSize(sizeBytes)}'
                    '${modified != null ? ' • ${_formatDateTime(modified)}' : ''}',
                    style: TextStyle(
                        fontSize: 11, color: theme.colorScheme.outline),
                  ),
                  trailing: TextButton.icon(
                    onPressed: _isRestoring
                        ? null
                        : () => _confirmAndRestore(file.path),
                    icon: const Icon(Icons.restore, size: 16),
                    label: const Text('Pulihkan',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
