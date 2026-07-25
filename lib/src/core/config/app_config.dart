class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const googleAndroidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
  );
  static const atlasOwnerEmail = String.fromEnvironment('ATLAS_OWNER_EMAIL');

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasGoogleConfig => googleWebClientId.isNotEmpty;

  static bool get hasRequiredAuthConfig => hasSupabaseConfig && hasGoogleConfig;

  static bool get restrictToOwnerEmail => atlasOwnerEmail.isNotEmpty;
}
