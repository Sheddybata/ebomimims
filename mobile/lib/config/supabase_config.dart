/// Supply credentials at build/run time (never commit production values here).
///
/// ```sh
/// flutter run \
///   --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY='<anon-public-key-from-Supabase-settings>'
/// ```
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      url.startsWith('https://') && anonKey.isNotEmpty;
}
