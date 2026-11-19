// Supabase project configuration for SIAK-ILMI cloud backup.
//
// IMPORTANT: Replace placeholder values with your actual Supabase project
// credentials before building for production. These values are safe to embed
// in the Flutter client — they use the anon (public) key, not the service_role.
//
// Setup checklist:
// 1. Create a Supabase project at https://supabase.com
// 2. Create a private bucket named 'siak-ilmi-backups'
// 3. Apply RLS policies (see docs/SUPABASE_BACKUP_IMPLEMENTATION.md)
// 4. Create an institutional auth account (e.g., backup@darulilmi.sch.id)
// 5. Replace the placeholders below with your project URL and anon key

/// Your Supabase project URL (format: https://xxxx.supabase.co)
const String supabaseUrl = 'https://dobbpqpbyhljrnypyvmx.supabase.co';

/// Your Supabase anon (public) key — safe to embed in Flutter client code.
/// Never use the service_role key in Flutter code.
const String supabaseAnonKey = 'sb_publishable_Su1VLEY9n62HS9eozrWvEQ_Tb740NE_';

/// Name of the private Supabase Storage bucket for backups.
const String supabaseBucketId = 'siak-ilmi-backups';

/// Storage path prefix for backup files.
/// Full path: backups/{year}/{month}/{filename}
const String supabaseBackupPathPrefix = 'backups';
