import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// SupabaseService
/// ---
/// Service for interacting with Supabase
class SupabaseService {
  /// Get the Supabase client
  SupabaseClient get _client => Supabase.instance.client;

  /// Test connection to Supabase
  /// Returns a message indicating success or failure
  Future<String> testConnection() async {
    try {
      // Attempt a simple query to verify connection
      await _client.from('user_profiles').select().limit(1);
      return 'Supabase connection successful!';
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        printError('Postgres error: ${e.message}');
      }
      return 'Error connecting to Supabase: ${e.message}';
    } catch (e) {
      if (kDebugMode) {
        printError('Error connecting to Supabase: $e');
      }
      return 'Error connecting to Supabase: $e';
    }
  }

  /// Fetch sample data from a Supabase table
  /// Returns a list of user profiles
  Future<List<Map<String, dynamic>>> fetchUserProfiles() async {
    try {
      final response = await _client.from('user_profiles').select().limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        printError('Error fetching user profiles: $e');
      }
      return [];
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }
}
