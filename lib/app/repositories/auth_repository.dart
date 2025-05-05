import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  /// If a [SupabaseClient] is passed, use it. Otherwise, use the globally
  /// initialised instance from `Supabase.instance.client` provided by the
  /// SupabaseProvider boot method.
  AuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<Map<String, dynamic>?> signInWithEmail(
      String email, String password) async {
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);

      if (response.session != null) {
        return {
          "user": response.user?.toJson(),
          "token": response.session?.accessToken,
        };
      }
      return null;
    } catch (e) {
      printError('Error signing in: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> signUpWithEmail(
      String email, String password) async {
    try {
      final response =
          await _client.auth.signUp(email: email, password: password);

      if (response.session != null) {
        return {
          "user": response.user?.toJson(),
          "token": response.session?.accessToken,
        };
      }
      return null;
    } catch (e) {
      printError('Error signing up: $e');
      return null;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      printError('Error sending password reset: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      printError('Error signing out: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session != null) {
        return {
          "user": _client.auth.currentUser?.toJson(),
          "token": session.accessToken,
        };
      }
      return null;
    } catch (e) {
      printError('Error getting current session: $e');
      return null;
    }
  }
}
