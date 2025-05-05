import 'package:flutter/material.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/app/models/chore.dart';

class ChoreApiService extends NyApiService {
  ChoreApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  // Access Supabase client directly
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'chores';

  @override
  String get baseUrl => getEnv('SUPABASE_URL');

  /// Fetch all chores for a household
  Future<List<Chore>> fetchHouseholdChores(String householdId) async {
    try {
      final response = await _client
          .from(_table)
          .select('*')
          .eq('household_id', householdId)
          .order('due_date', ascending: true);

      return (response as List).map((json) => Chore.fromJson(json)).toList();
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error fetching chores: $e');
      }
      rethrow;
    }
  }

  /// Fetch chores assigned to a user
  Future<List<Chore>> fetchUserChores(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select('*')
          .eq('assigned_to_user_id', userId)
          .order('due_date', ascending: true);

      return (response as List).map((json) => Chore.fromJson(json)).toList();
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error fetching user chores: $e');
      }
      rethrow;
    }
  }

  /// Fetch a specific chore by ID
  Future<Chore?> fetchChore(String id) async {
    try {
      final response =
          await _client.from(_table).select('*').eq('id', id).single();

      return Chore.fromJson(response);
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error fetching chore: $e');
      }
      return null;
    }
  }

  /// Create a new chore
  Future<Chore?> createChore(Chore chore) async {
    try {
      // Validate chore data
      if (chore.title.isEmpty) {
        throw Exception('Chore title is required');
      }

      // No need to check if householdId is null since it's non-nullable
      // We could check if it's empty if that's a business requirement
      if (chore.householdId.isEmpty) {
        throw Exception('Household ID is required');
      }

      final response =
          await _client.from(_table).insert(chore.toJson()).select().single();

      return Chore.fromJson(response);
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error creating chore: $e');
      }
      rethrow;
    }
  }

  /// Update an existing chore
  Future<Chore?> updateChore(Chore chore) async {
    try {
      // Validate chore data
      if (chore.id == null) {
        throw Exception('Chore ID is required for updates');
      }

      final response = await _client
          .from(_table)
          .update(chore.toJson())
          .eq('id', chore.id!)
          .select()
          .single();

      return Chore.fromJson(response);
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error updating chore: $e');
      }
      rethrow;
    }
  }

  /// Mark a chore as completed
  Future<Chore?> completeChore(String id) async {
    try {
      final response = await _client
          .from(_table)
          .update({
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return Chore.fromJson(response);
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error completing chore: $e');
      }
      rethrow;
    }
  }

  /// Delete a chore
  Future<bool> deleteChore(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);

      return true;
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error deleting chore: $e');
      }
      return false;
    }
  }
}
