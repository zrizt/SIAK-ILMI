import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_seeder.dart';
import '../../core/security/pin_service.dart';

// Re-export for bootstrap.dart access
export '../../core/database/app_database.dart' show appDatabaseProvider;

/// Performs all async initializations before [runApp]:
/// 1. Opens the Drift SQLite database
/// 2. Seeds initial data (schools, academic year, tariffs) on first run
/// 3. Initializes default PIN hashes (Admin: 123456, Viewer: 654321)
/// 4. Initializes Supabase client (fail-silent — offline-first app continues
///    to work without internet connectivity)
///
/// Called from [main.dart].
Future<AppDatabase> initializeApp() async {
  final db = AppDatabase();

  // Seed lookup data idempotently
  final seeder = DatabaseSeeder(db);
  await seeder.seedIfEmpty();

  // Initialize PIN hashes if first install
  await PinService.initializeDefaultPins();

  // Initialize Supabase client — fail-silent.
  // If credentials are placeholders or network is unavailable, the app
  // continues working offline. Cloud backup features will be disabled.
  try {
    if (supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
    }
  } catch (_) {
    // Supabase init failure must never prevent app startup
  }

  return db;
}
