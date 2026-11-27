import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../features/backup_restore/data/weekly_auto_backup_service.dart';
import 'router.dart';

class SiakIlmiApp extends ConsumerStatefulWidget {
  const SiakIlmiApp({super.key});

  @override
  ConsumerState<SiakIlmiApp> createState() => _SiakIlmiAppState();
}

class _SiakIlmiAppState extends ConsumerState<SiakIlmiApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Run weekly auto-backup check silently after first frame
    Future.microtask(
      () => unawaited(ref.read(weeklyAutoBackupServiceProvider).runIfDue()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(weeklyAutoBackupServiceProvider).runIfDue());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'SIAK-ILMI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      locale: const Locale('id', 'ID'),
      debugShowCheckedModeBanner: false,
    );
  }
}
