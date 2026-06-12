class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qikapsvunnhnyvqvckxl.supabase.co',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_D9OyJSVxKzLeHhdGVDoJoQ_6h7-C8hI',
  );

  static bool get isConfigured =>
      url.startsWith('https://') && anonKey.length > 40;
}
