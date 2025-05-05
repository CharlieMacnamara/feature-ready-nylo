import 'package:flutter/material.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '/app/models/user.dart';

class AuthApiService extends NyApiService {
  AuthApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  // Access Supabase client directly
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;
  final supabase.GoTrueClient _auth = supabase.Supabase.instance.client.auth;

  @override
  String get baseUrl => getEnv('SUPABASE_URL');

  /// Get the current authenticated user
  User? getCurrentUser() {
    final authUser = _auth.currentUser;
    if (authUser == null) return null;

    return User(
      id: authUser.id,
      email: authUser.email,
      name: authUser.userMetadata?['name'] as String?,
      avatarUrl: authUser.userMetadata?['avatar_url'] as String?,
    );
  }

  /// Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = response.user;
      if (authUser == null) return null;

      return User(
        id: authUser.id,
        email: authUser.email,
        name: authUser.userMetadata?['name'] as String?,
        avatarUrl: authUser.userMetadata?['avatar_url'] as String?,
      );
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error signing in: $e');
      }
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<User?> signUp(String email, String password, String name) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

      final authUser = response.user;
      if (authUser == null) return null;

      // Create user profile in the profiles table
      await _client.from('profiles').insert({
        'id': authUser.id,
        'email': email,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      });

      return User(
        id: authUser.id,
        email: authUser.email,
        name: name,
      );
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error signing up: $e');
      }
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error signing out: $e');
      }
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error resetting password: $e');
      }
      rethrow;
    }
  }

  /// Update user profile
  Future<User?> updateProfile(User user) async {
    try {
      if (user.id == null) {
        throw Exception('User ID is required for profile updates');
      }

      // Update profile in the profiles table
      await _client.from('profiles').update({
        'name': user.name,
        'avatar_url': user.avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id!);

      // Also update metadata in auth.users if user is currently authenticated
      final authUser = _auth.currentUser;
      if (authUser != null && authUser.id == user.id) {
        await _auth.updateUser(supabase.UserAttributes(
          data: {
            'name': user.name,
            'avatar_url': user.avatarUrl,
          },
        ));
      }

      return user;
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error updating profile: $e');
      }
      rethrow;
    }
  }

  /// Get user profile by ID
  Future<User?> getUserProfile(String id) async {
    try {
      final response =
          await _client.from('profiles').select('*').eq('id', id).single();

      return User.fromJson(response);
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error fetching user profile: $e');
      }
      return null;
    }
  }
}
