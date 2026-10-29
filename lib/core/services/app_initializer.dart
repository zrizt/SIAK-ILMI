import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_seeder.dart';
import '../../core/security/pin_service.dart';

// Re-export for bootstrap.dart access
export '../../core/database/app_database.dart' show appDatabaseProvider;

/// Performs all async initializations before [runApp]:
/// 1. Opens the Drift SQLite database
/// 2. Seeds initial data (schools, academic year, tariffs) on first run
/// 3. Initializes default PIN hashes (Admin: 123456, Viewer: 654321)
///
/// Called from [main.dart].
Future<AppDatabase> initializeApp() async {
  final db = AppDatabase();

  // Seed lookup data idempotently
  final seeder = DatabaseSeeder(db);
  await seeder.seedIfEmpty();

  // Initialize PIN hashes if first install
  await PinService.initializeDefaultPins();

  return db;
}
