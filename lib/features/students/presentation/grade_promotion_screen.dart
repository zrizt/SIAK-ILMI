import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/operator_service.dart';
import '../../settings/presentation/pin_auth_screen.dart';
import '../domain/promote_students_use_case.dart';

class GradePromotionScreen extends ConsumerStatefulWidget {
  const GradePromotionScreen({super.key});

  @override
  ConsumerState<GradePromotionScreen> createState() =>
      _GradePromotionScreenState();
}

class _GradePromotionScreenState extends ConsumerState<GradePromotionScreen> {
  bool _isLoading = true;
  bool _isExecuting = false;
  String _currentAcademicYear = '2026/2027';
  late final TextEditingController _newTaController;

  List<StudentPromotionCandidate> _candidates = [];
  int? _selectedSekolahId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _newTaController = TextEditingController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _newTaController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final useCase = ref.read(promoteStudentsUseCaseProvider);
      final currentTa = await useCase.getActiveAcademicYear();
      final nextTa = useCase.computeNextAcademicYear(currentTa);
      final candidates = await useCase.getPromotionCandidates();

      if (mounted) {
        setState(() {
          _currentAcademicYear = currentTa;
          _newTaController.text = nextTa;
          _candidates = candidates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data kenaikan kelas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<StudentPromotionCandidate> get _filteredCandidates {
    return _candidates.where((c) {
      if (_selectedSekolahId != null &&
          c.student.sekolahId != _selectedSekolahId) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = c.student.namaLengkap.toLowerCase().contains(q);
        final matchesNis = c.student.nis.contains(q);
        if (!matchesName && !matchesNis) return false;
      }
      return true;
    }).toList();
  }

  int get _promotedCount =>
      _candidates.where((c) => !c.isRetained && !c.willGraduate).length;

  int get _graduatedCount =>
      _candidates.where((c) => !c.isRetained && c.willGraduate).length;

  int get _retainedCount => _candidates.where((c) => c.isRetained).length;

  Future<void> _handleConfirmPromotion() async {
    final role = ref.read(authRoleProvider);
    if (role != PinRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya Administrator yang dapat memproses kenaikan kelas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newTa = _newTaController.text.trim();
    if (newTa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tahun Ajaran baru tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Konfirmasi Kenaikan Kelas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tindakan ini akan memproses kenaikan kelas ke Tahun Ajaran $newTa:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              icon: Icons.trending_up,
              color: Colors.green,
              label: 'Naik Kelas',
              count: _promotedCount,
            ),
            const SizedBox(height: 6),
            _SummaryRow(
              icon: Icons.school,
              color: Colors.blue,
              label: 'Lulus',
              count: _graduatedCount,
            ),
            const SizedBox(height: 6),
            _SummaryRow(
              icon: Icons.pause_circle_outline,
              color: Colors.orange,
              label: 'Tinggal Kelas',
              count: _retainedCount,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tahun Ajaran aktif akan dialihkan ke tahun ajaran baru secara otomatis. Lanjutkan?',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Proses Kenaikan Kelas'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isExecuting = true);

    try {
      final activeOp = ref.read(activeOperatorProvider);
      final operatorName = activeOp?.fullName ?? 'Administrator';
      final useCase = ref.read(promoteStudentsUseCaseProvider);

      final result = await useCase.executePromotion(
        candidates: _candidates,
        newAcademicYear: newTa,
        operatorName: operatorName,
      );

      if (mounted) {
        setState(() => _isExecuting = false);

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Kenaikan Kelas Berhasil!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tahun Ajaran aktif sekarang: ${result.newAcademicYear}'),
                const SizedBox(height: 12),
                Text('• Total Siswa Diproses: ${result.totalProcessed}'),
                Text('• Berhasil Naik Kelas: ${result.promotedCount}'),
                Text('• Lulus: ${result.graduatedCount}'),
                Text('• Tinggal Kelas: ${result.retainedCount}'),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExecuting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat memproses kenaikan kelas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final filtered = _filteredCandidates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kenaikan Kelas Otomatis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── TA Transition Banner ──
                Container(
                  color: cs.surfaceContainerLow,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TA Saat Ini',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentAcademicYear,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded,
                          color: cs.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target TA Baru',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            TextField(
                              controller: _newTaController,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Metric Counters ──
                Container(
                  color: cs.surfaceContainerLowest,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      _MetricChip(
                        label: 'Total',
                        count: _candidates.length,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 8),
                      _MetricChip(
                        label: 'Naik',
                        count: _promotedCount,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _MetricChip(
                        label: 'Lulus',
                        count: _graduatedCount,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _MetricChip(
                        label: 'Tinggal',
                        count: _retainedCount,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

                // ── Filter Chips & Search ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Semua'),
                        selected: _selectedSekolahId == null,
                        onSelected: (_) =>
                            setState(() => _selectedSekolahId = null),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('SD IT'),
                        selected: _selectedSekolahId == 1,
                        onSelected: (_) => setState(() => _selectedSekolahId = 1),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('SMP IT'),
                        selected: _selectedSekolahId == 2,
                        onSelected: (_) => setState(() => _selectedSekolahId = 2),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Cari siswa...',
                            prefixIcon: Icon(Icons.search, size: 18),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (q) => setState(() => _searchQuery = q),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // ── Candidate List ──
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('Tidak ada siswa yang cocok.'),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final candidate = filtered[i];
                            final student = candidate.student;
                            final currentKelas =
                                candidate.currentKelas?.namaKelas ??
                                    'Kelas ${candidate.currentTingkat}';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: student.jenisKelamin == 'L'
                                    ? Colors.blue.withValues(alpha: 0.2)
                                    : Colors.pink.withValues(alpha: 0.2),
                                child: Text(
                                  student.namaLengkap.isNotEmpty
                                      ? student.namaLengkap[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: student.jenisKelamin == 'L'
                                        ? Colors.blue
                                        : Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      student.namaLengkap,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  _ActionBadge(candidate: candidate),
                                ],
                              ),
                              subtitle: Text(
                                'NIS: ${student.nis} · Asal: $currentKelas (${student.sekolahId == 1 ? "SD IT" : "SMP IT"})',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Tooltip(
                                message: 'Tandai Tinggal Kelas (tidak naik)',
                                child: FilterChip(
                                  label: const Text('Tinggal Kelas'),
                                  selected: candidate.isRetained,
                                  selectedColor: Colors.orange.withValues(alpha: 0.2),
                                  checkmarkColor: Colors.orange,
                                  onSelected: (val) {
                                    setState(() {
                                      candidate.isRetained = val;
                                    });
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // ── Bottom Confirmation Bar ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: (_isExecuting || _candidates.isEmpty)
                            ? null
                            : _handleConfirmPromotion,
                        icon: _isExecuting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.upgrade_rounded),
                        label: Text(
                          _isExecuting
                              ? 'Memproses...'
                              : 'Proses Kenaikan Kelas (T.A. ${_newTaController.text.trim()})',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.candidate});

  final StudentPromotionCandidate candidate;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;

    if (candidate.isRetained) {
      bg = Colors.orange.withValues(alpha: 0.2);
      fg = Colors.orange.shade800;
      text = 'Tinggal Kelas';
    } else if (candidate.willGraduate) {
      bg = Colors.blue.withValues(alpha: 0.2);
      fg = Colors.blue.shade800;
      text = 'Lulus';
    } else {
      bg = Colors.green.withValues(alpha: 0.2);
      fg = Colors.green.shade800;
      text = candidate.targetKelas?.namaKelas != null
          ? 'Naik ke ${candidate.targetKelas!.namaKelas}'
          : 'Naik Tingkat';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          '$count Siswa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
