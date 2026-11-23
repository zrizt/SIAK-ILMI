import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/services/app_initializer.dart';
import 'app.dart';

/// Application bootstrap: replaces the placeholder [bootstrap()] stub.
/// Initializes the database and injects it into the [ProviderScope].
Future<void> bootstrap() async {
  final db = await initializeApp();

  runApp(
    ProviderScope(
      overrides: [
        databaseNotifierProvider.overrideWith((ref) => DatabaseNotifier(db)),
      ],
      child: const SiakIlmiApp(),
    ),
  );
}
