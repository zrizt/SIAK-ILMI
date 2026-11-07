import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/database/database_seeder.dart';
import 'package:siak_ilmi/core/theme/app_theme.dart';
import 'package:siak_ilmi/core/theme/theme_provider.dart';
import 'package:siak_ilmi/features/dashboard/presentation/dashboard_screen.dart';
import 'package:siak_ilmi/features/settings/presentation/pin_auth_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Theme switching and tab navigation in light mode works without errors',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final seeder = DatabaseSeeder(db);
    await seeder.seedIfEmpty();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authRoleProvider.overrideWith((ref) => PinRole.admin),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final themeMode = ref.watch(themeModeProvider);
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const DashboardScreen(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Check Dashboard
    expect(find.byType(Image), findsWidgets);
    expect(find.text('Semua'), findsOneWidget);

    // 2. Navigate to Siswa tab
    await tester.tap(find.text('Siswa'));
    await tester.pumpAndSettle();
    expect(find.text('Data Siswa'), findsOneWidget);

    // 3. Navigate to Biaya tab
    await tester.tap(find.text('Biaya'));
    await tester.pumpAndSettle();
    expect(find.text('Manajemen Biaya'), findsOneWidget);

    // 4. Navigate to Pengaturan tab
    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();

    expect(find.text('Pengaturan'), findsWidgets);
    expect(find.text('SIAK-ILMI v1.0.0'), findsOneWidget);
    expect(find.text('AKUN OPERATOR'), findsOneWidget);

    // Scroll to see remaining tiles
    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Mode Tampilan'), findsOneWidget);

    // 5. Navigate back to Dashboard
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsWidgets);
    expect(find.text('Semua'), findsOneWidget);

    await db.close();
  });
}
