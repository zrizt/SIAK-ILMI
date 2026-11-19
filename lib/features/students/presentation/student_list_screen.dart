import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../settings/presentation/pin_auth_screen.dart';
import '../data/dapodik_parser.dart';
import '../domain/student_providers.dart';
import 'grade_promotion_screen.dart';
import 'import_preview_screen.dart';
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
              icon: const Icon(Icons.upgrade_rounded),
              tooltip: 'Kenaikan Kelas',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GradePromotionScreen(),
                ),
              ),
            ),
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
    final yearController = TextEditingController(
      text: DateTime.now().year.toString(),
    );

    File? selectedFile;
    String? selectedFileName;
    bool isImporting = false;
    String? errorMessage;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            title: const Text('Import Data Dapodik / PPDB'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih file .xlsx atau .csv dari penyimpanan perangkat.\n'
                    'Kolom wajib: Nama, Tingkat (1-9), Jenis Kelamin (L/P).\n'
                    'Kolom opsional: NISN, Kontak Wali, Status PPDB.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.blue),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Kolom "status_ppdb": Lulus = diimpor, Tidak Lulus = dilewati otomatis.',
                            style: TextStyle(fontSize: 11, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── File Picker Button ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isImporting
                          ? null
                          : () async {
                              final result =
                                  await FilePicker.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['xlsx', 'xls', 'csv'],
                                allowMultiple: false,
                              );
                              if (result != null &&
                                  result.files.isNotEmpty) {
                                final path = result.files.single.path;
                                if (path != null) {
                                  setDialogState(() {
                                    selectedFile = File(path);
                                    selectedFileName =
                                        result.files.single.name;
                                    errorMessage = null;
                                  });
                                }
                              }
                            },
                      icon: const Icon(Icons.folder_open_outlined),
                      label: Text(
                        selectedFileName ?? 'Pilih File (.xlsx / .csv)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  if (selectedFile != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            selectedFileName!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

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
                        if (selectedFile == null) {
                          setDialogState(() {
                            errorMessage = 'Silakan pilih file terlebih dahulu.';
                          });
                          return;
                        }

                        final rawYear =
                            int.tryParse(yearController.text.trim()) ??
                                DateTime.now().year;

                        setDialogState(() {
                          isImporting = true;
                          errorMessage = null;
                        });

                        try {
                          final parser = ref.read(dapodikParserProvider);
                          final result =
                              await parser.parseFile(selectedFile!, rawYear);

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            final imported = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImportPreviewScreen(
                                  parseResult: result,
                                  tahunMasuk: rawYear,
                                ),
                              ),
                            );

                            if (imported == true) {
                              ref.invalidate(filteredStudentListProvider);
                            }
                          }
                        } catch (e) {
                          setDialogState(() {
                            isImporting = false;
                            errorMessage = 'Gagal memproses file: $e';
                          });
                        }
                      },
                child: const Text('Pratinjau & Konfirmasi'),
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
