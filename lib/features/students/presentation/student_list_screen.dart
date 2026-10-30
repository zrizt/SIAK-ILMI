import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../settings/presentation/pin_auth_screen.dart';
import '../data/dapodik_parser.dart';
import '../data/student_repository.dart';
import '../domain/student_providers.dart';
import 'student_detail_screen.dart';
import 'student_form_screen.dart';

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(studentFilterProvider);
    final studentsAsync = ref.watch(filteredStudentListProvider);
    final role = ref.watch(authRoleProvider);
    final isAdmin = role == PinRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa'),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: 'Import Dapodik',
              onPressed: () => _showImportDialog(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Tambah Siswa',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentFormScreen(siswaId: null),
                ),
              ),
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Column(
              children: [
                _SchoolFilterChips(filter: filter, ref: ref),
                const SizedBox(height: 6),
                _SearchBar(ref: ref),
              ],
            ),
          ),
        ),
      ),
      body: studentsAsync.when(
        data: (students) => students.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                itemCount: students.length,
                itemBuilder: (ctx, i) => _StudentTile(student: students[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final pathController = TextEditingController();
    final yearController = TextEditingController(
      text: DateTime.now().year.toString(),
    );

    bool isImporting = false;
    String? errorMessage;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            title: const Text('Import Data Dapodik'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih file .xlsx atau .csv dari penyimpanan internal/Downloads.\n'
                    'Kolom wajib: Nama, Tingkat (1-9), Jenis Kelamin (L/P).\n'
                    'Kolom opsional: NISN, Kontak Wali.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pathController,
                    decoration: const InputDecoration(
                      labelText: 'Path File (.xlsx / .csv)',
                      hintText: '/sdcard/Download/dapodik.xlsx',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tahun Masuk (YY / YYYY)',
                      hintText: '2026',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (isImporting) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isImporting ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: isImporting
                    ? null
                    : () async {
                        final rawPath = pathController.text.trim();
                        final rawYear = int.tryParse(yearController.text.trim()) ??
                            DateTime.now().year;

                        if (rawPath.isEmpty) {
                          setDialogState(() {
                            errorMessage = 'Silakan masukkan path file.';
                          });
                          return;
                        }

                        final file = File(rawPath);
                        if (!file.existsSync()) {
                          setDialogState(() {
                            errorMessage = 'File tidak ditemukan pada path yang diberikan.';
                          });
                          return;
                        }

                        setDialogState(() {
                          isImporting = true;
                          errorMessage = null;
                        });

                        try {
                          final parser = ref.read(dapodikParserProvider);
                          final repository = ref.read(studentRepositoryProvider);

                          final result = await parser.parseFile(file, rawYear);
                          final insertedCount = await repository.bulkImport(
                            result.rows,
                            'ADMIN',
                          );

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Berhasil mengimpor $insertedCount siswa. '
                                  '(${result.errorRows.length} baris tidak valid dilewati)',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() {
                            isImporting = false;
                            errorMessage = 'Gagal import: $e';
                          });
                        }
                      },
                child: const Text('Mulai Import'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SchoolFilterChips extends StatelessWidget {
  const _SchoolFilterChips({required this.filter, required this.ref});
  final StudentFilter filter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('Semua', null),
        const SizedBox(width: 8),
        _chip('SD', 1),
        const SizedBox(width: 8),
        _chip('SMP', 2),
      ],
    );
  }

  Widget _chip(String label, int? sekolahId) {
    final selected = filter.sekolahId == sekolahId;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) =>
          ref.read(studentFilterProvider.notifier).state =
              filter.copyWith(
        sekolahId: sekolahId,
        clearSekolah: sekolahId == null,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Cari nama / NIS / NISN...',
        prefixIcon: Icon(Icons.search),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10),
      ),
      onChanged: (q) {
        final current = ref.read(studentFilterProvider);
        ref.read(studentFilterProvider.notifier).state =
            current.copyWith(searchQuery: q);
      },
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student});
  final SiswaData student;

  @override
  Widget build(BuildContext context) {
    final isSD = student.sekolahId == 1;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSD
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        child: Text(
          student.namaLengkap[0].toUpperCase(),
          style: TextStyle(
            color: isSD
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(student.namaLengkap,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        'NIS: ${student.nis} \u00b7 ${isSD ? "SD" : "SMP"} \u00b7 '
        '${student.jenisKelamin == "L" ? "Laki-laki" : "Perempuan"}',
      ),
      trailing: _StatusBadge(status: student.status),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDetailScreen(siswaId: student.id),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'AKTIF' => (Colors.green, 'Aktif'),
      'LULUS' => (Colors.blue, 'Lulus'),
      'PINDAH' => (Colors.orange, 'Pindah'),
      'DROP_OUT' => (Colors.red, 'DO'),
      _ => (Colors.grey, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 72,
              color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('Belum ada siswa terdaftar',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Tambah siswa manual atau import dari Dapodik'),
        ],
      ),
    );
  }
}
