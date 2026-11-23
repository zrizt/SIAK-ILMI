import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/operator_dao.dart';
import '../../../core/database/daos/pembayaran_dao.dart';
import '../../../core/database/daos/siswa_dao.dart';
import '../../../core/database/daos/tagihan_dao.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/security/operator_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../backup_restore/presentation/backup_restore_screen.dart';
import '../../fee_management/presentation/fee_management_screen.dart';
import '../../reports/presentation/export_excel_dialog.dart';
import '../../settings/presentation/pin_auth_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../students/presentation/student_form_screen.dart';
import '../../students/presentation/student_list_screen.dart';

part 'dashboard_screen.g.dart';

// ── Dashboard filter: null=All, 1=SD, 2=SMP ───────────────────────────────
final dashboardSekolahFilterProvider = StateProvider<int?>((ref) => null);

// ── Data model ────────────────────────────────────────────────────────────
class DashboardMetrics {
  const DashboardMetrics({
    required this.todayTotal,
    required this.monthTotal,
    required this.activeStudentCount,
    required this.outstandingArrears,
  });
  final int todayTotal;
  final int monthTotal;
  final int activeStudentCount;
  final int outstandingArrears;
}

// ── Riverpod async provider ────────────────────────────────────────────────
@riverpod
Future<DashboardMetrics> dashboardMetrics(DashboardMetricsRef ref) async {
  final db = ref.watch(appDatabaseProvider);
  final sekolahId = ref.watch(dashboardSekolahFilterProvider);

  final pembayaranDao = PembayaranDao(db);
  final siswaDao = SiswaDao(db);
  final tagihanDao = TagihanDao(db);

  final now = DateTime.now();
  final todayPrefix = DateFormatter.todayPrefix();
  final monthStart =
      '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-01T00:00:00';

  final List<SiswaData> activeStudents = sekolahId != null
      ? await siswaDao.watchActiveSiswaBySekolah(sekolahId).first
      : await siswaDao.getActiveSiswa();

  final todayTotal = await pembayaranDao.sumTotalBayarByDateRange(
    startIso: '${todayPrefix}T00:00:00',
    endIso: '${todayPrefix}T23:59:59',
    sekolahId: sekolahId,
  );
  final monthTotal = await pembayaranDao.sumTotalBayarByDateRange(
    startIso: monthStart,
    endIso: '${todayPrefix}T23:59:59',
    sekolahId: sekolahId,
  );

  int arrears = 0;
  for (final siswa in activeStudents) {
    final unpaid = await tagihanDao.watchUnpaidItemsByStudent(siswa.id).first;
    for (final item in unpaid) {
      arrears += (item.nominalAkhir - item.terbayar);
    }
  }

  return DashboardMetrics(
    todayTotal: todayTotal,
    monthTotal: monthTotal,
    activeStudentCount: activeStudents.length,
    outstandingArrears: arrears,
  );
}

// ── Shell with bottom nav ─────────────────────────────────────────────────

/// Current bottom nav index
final _navIndexProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _screens = [
    _DashboardTab(),
    StudentListScreen(),
    FeeManagementScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(_navIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: navIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: (i) =>
            ref.read(_navIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Siswa',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Biaya',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// ── Dashboard tab (metrics + quick actions) ───────────────────────────────

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sekolahFilter = ref.watch(dashboardSekolahFilterProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final role = ref.watch(authRoleProvider);
    final op = ref.watch(activeOperatorProvider);
    final loginLabel = op != null
        ? op.fullName.split(' ').first
        : (role?.displayName ?? 'Admin');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 110,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: const Icon(Icons.person_outline, size: 14),
              label: Text(
                loginLabel,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
        ),
        title: Image.asset(
          'assets/images/logo_header.png',
          height: 36,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/logo.png',
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Text(
              'SIAK-ILMI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Database',
            onPressed: () async {
              final sm = ScaffoldMessenger.of(context);
              sm.showSnackBar(
                const SnackBar(
                  content: Text('Memuat ulang database...'),
                  duration: Duration(milliseconds: 800),
                ),
              );
              try {
                await ref
                    .read(databaseNotifierProvider.notifier)
                    .reloadDatabase();
                ref.invalidate(dashboardMetricsProvider);
                // Refresh operator session if logged in
                final currentOp = ref.read(activeOperatorProvider);
                if (currentOp != null) {
                  final opDao = OperatorDao(ref.read(appDatabaseProvider));
                  final refreshedOp = await opDao.getById(currentOp.id);
                  if (refreshedOp != null && refreshedOp.isActive == 1) {
                    ref.read(activeOperatorProvider.notifier).state =
                        refreshedOp;
                  }
                }
                sm.showSnackBar(
                  const SnackBar(
                    content: Text('Database berhasil dimuat ulang.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                sm.showSnackBar(
                  SnackBar(
                    content: Text('Gagal memuat ulang database: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: 'Export Laporan Excel',
            onPressed: () => ExportExcelDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Kunci Aplikasi',
            onPressed: () =>
                ref.read(authRoleProvider.notifier).state = null,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                _filterChip(ref, 'Semua', null, sekolahFilter),
                const SizedBox(width: 8),
                _filterChip(ref, 'SD', 1, sekolahFilter),
                const SizedBox(width: 8),
                _filterChip(ref, 'SMP', 2, sekolahFilter),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(databaseNotifierProvider.notifier).reloadDatabase();
          ref.invalidate(dashboardMetricsProvider);
          final currentOp = ref.read(activeOperatorProvider);
          if (currentOp != null) {
            final opDao = OperatorDao(ref.read(appDatabaseProvider));
            final refreshedOp = await opDao.getById(currentOp.id);
            if (refreshedOp != null && refreshedOp.isActive == 1) {
              ref.read(activeOperatorProvider.notifier).state = refreshedOp;
            }
          }
        },
        child: metricsAsync.when(
          data: (m) => _DashboardBody(metrics: m, ref: ref),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _filterChip(WidgetRef ref, String label, int? value, int? current) =>
      FilterChip(
        label: Text(label),
        selected: current == value,
        onSelected: (_) =>
            ref.read(dashboardSekolahFilterProvider.notifier).state = value,
      );
}

// ── Dashboard body ─────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.metrics, required this.ref});
  final DashboardMetrics metrics;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 11
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 18
                ? 'Selamat Sore'
                : 'Selamat Malam';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Greeting card with App Logo
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hour < 18
                                ? Icons.wb_sunny_outlined
                                : Icons.nightlight_outlined,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            greeting,
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
                      const SizedBox(height: 2),
                      Text(
                        DateFormatter.toDisplay(now),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2×2 Metric cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _MetricCard(
              icon: Icons.today,
              label: 'Penerimaan Hari Ini',
              value: CurrencyFormatter.format(metrics.todayTotal),
              color: Colors.green,
            ),
            _MetricCard(
              icon: Icons.calendar_month,
              label: 'Bulan Ini',
              value: CurrencyFormatter.format(metrics.monthTotal),
              color: Colors.blue,
            ),
            _MetricCard(
              icon: Icons.people,
              label: 'Siswa Aktif',
              value: metrics.activeStudentCount.toString(),
              color: Colors.purple,
            ),
            _MetricCard(
              icon: Icons.warning_amber_rounded,
              label: 'Total Tunggakan',
              value: CurrencyFormatter.format(metrics.outstandingArrears),
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quick actions
        Text(
          'Aksi Cepat',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.person_add,
                label: 'Tambah Siswa',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const StudentFormScreen(siswaId: null),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionCard(
                icon: Icons.backup,
                label: 'Backup Data',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BackupRestoreScreen()),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionCard(
                icon: Icons.table_view_rounded,
                label: 'Export Excel',
                onTap: () => ExportExcelDialog.show(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
