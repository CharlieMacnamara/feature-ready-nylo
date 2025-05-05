import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// SupabaseProvider
/// ---
/// Provides Supabase client initialization for the app.
/// This provider is registered in config/providers.dart
class SupabaseProvider implements NyProvider {
  @override
  Future<Nylo?> boot(Nylo nylo) async {
    await Supabase.initialize(
      url: getEnv('SUPABASE_URL'),
      anonKey: getEnv('SUPABASE_ANON_KEY'),
      debug: kDebugMode,
    );

    // Log initialization status in debug mode
    if (kDebugMode) {
      printInfo('✅ Supabase initialized with URL: ${getEnv('SUPABASE_URL')}');
    }

    return nylo;
  }

  @override
  afterBoot(Nylo nylo) async {}

  /// Access the Supabase client instance
  SupabaseClient get client => Supabase.instance.client;
}
