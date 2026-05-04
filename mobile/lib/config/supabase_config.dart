abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jcfhdiamblvceysogmxh.supabase.co',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpjZmhkaWFtYmx2Y2V5c29nbXhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0ODMxMjUsImV4cCI6MjA5MzA1OTEyNX0.r9jtGoZGfp4EEEtPjkPPWz4RsU7TrQ3f1dOtShBZAwI',
  );

  static bool get isConfigured =>
      url.startsWith('https://') && anonKey.isNotEmpty;
}
