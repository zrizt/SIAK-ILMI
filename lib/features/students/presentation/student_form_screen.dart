import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/student_repository.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({super.key, this.siswaId});
  final int? siswaId; // null = new student

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nisnCtrl = TextEditingController();
  final _kontakCtrl = TextEditingController();

  String _jenisKelamin = 'L';
  int _sekolahId = 1;
  int _kodeSekolah = 1;
  int _kelasId = 1;
  int _tingkat = 1;
  int _tahunMasuk = DateTime.now().year;
  bool _isLoading = false;

  // Grade options based on selected school
  List<int> get _tingkatOptions =>
      _sekolahId == 1 ? [1, 2, 3, 4, 5, 6] : [7, 8, 9];

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nisnCtrl.dispose();
    _kontakCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(studentRepositoryProvider);
      await repo.registerStudent(
        sekolahId: _sekolahId,
        kodeSekolah: _kodeSekolah,
        tahunMasuk: _tahunMasuk,
        namaLengkap: _namaCtrl.text.trim(),
        jenisKelamin: _jenisKelamin,
        kelasId: _kelasId,
        nisn: _nisnCtrl.text.trim().isEmpty ? null : _nisnCtrl.text.trim(),
        kontakWali:
            _kontakCtrl.text.trim().isEmpty ? null : _kontakCtrl.text.trim(),
        createdBy: 'Admin',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Siswa berhasil didaftarkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.siswaId == null ? 'Tambah Siswa Baru' : 'Edit Siswa',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // School selection
            Text('Unit Sekolah',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('SD IT Baitul Akbar')),
                ButtonSegment(value: 2, label: Text('SMP IT Darul Ilmi')),
              ],
              selected: {_sekolahId},
              onSelectionChanged: (sel) => setState(() {
                _sekolahId = sel.first;
                _kodeSekolah = sel.first;
                _tingkat = _sekolahId == 1 ? 1 : 7;
                _kelasId = _tingkat;
              }),
            ),
            const SizedBox(height: 16),

            // Grade selection
            Text('Kelas / Tingkat',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tingkatOptions.map((t) {
                return ChoiceChip(
                  label: Text('Kelas $t'),
                  selected: _tingkat == t,
                  onSelected: (_) => setState(() {
                    _tingkat = t;
                    _kelasId = t;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap *',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            // NISN
            TextFormField(
              controller: _nisnCtrl,
              decoration: const InputDecoration(
                labelText: 'NISN (Opsional)',
                prefixIcon: Icon(Icons.badge_outlined),
                hintText: '10 digit NISN dari Dapodik',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Gender
            Text('Jenis Kelamin',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'L',
                  icon: Icon(Icons.male),
                  label: Text('Laki-laki'),
                ),
                ButtonSegment(
                  value: 'P',
                  icon: Icon(Icons.female),
                  label: Text('Perempuan'),
                ),
              ],
              selected: {_jenisKelamin},
              onSelectionChanged: (sel) =>
                  setState(() => _jenisKelamin = sel.first),
            ),
            const SizedBox(height: 12),

            // Tahun Masuk
            TextFormField(
              initialValue: _tahunMasuk.toString(),
              decoration: const InputDecoration(
                labelText: 'Tahun Masuk *',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => _tahunMasuk = int.tryParse(v) ?? _tahunMasuk,
              validator: (v) {
                final y = int.tryParse(v ?? '');
                if (y == null || y < 2020 || y > 2035) {
                  return 'Tahun tidak valid (2020-2035)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Wali Contact
            TextFormField(
              controller: _kontakCtrl,
              decoration: const InputDecoration(
                labelText: 'No. HP Wali (Opsional)',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Submit
            FilledButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(
                  _isLoading ? 'Menyimpan...' : 'Simpan & Generate NIS'),
            ),
          ],
        ),
      ),
    );
  }
}
