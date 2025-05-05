import 'package:flutter/material.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/app/models/household.dart';

class HouseholdApiService extends NyApiService {
  HouseholdApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  // Access Supabase client directly
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'households';

  @override
  String get baseUrl => getEnv('SUPABASE_URL');

  /// Fetch all households that a user belongs to
  Future<List<Household>> fetchUserHouseholds(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select('*, household_members!inner(*)')
          .eq('household_members.user_id', userId);

      return (response as List)
          .map((json) => Household.fromJson(json))
          .toList();
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error fetching households: $e');
      }
      rethrow;
    }
  }

  /// Fetch a specific household by ID
  Future<Household?> fetchHousehold(String id) async {
    try {
      final response =
          await _client.from(_table).select('*').eq('id', id).single();

      return Household.fromJson(response);
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error fetching household: $e');
      }
      return null;
    }
  }

  /// Create a new household
  Future<Household?> createHousehold(Household household) async {
    try {
      // Validate the household data
      if (household.name.isEmpty) {
        throw Exception('Household name is required');
      }

      final response = await _client
          .from(_table)
          .insert(household.toJson())
          .select()
          .single();

      return Household.fromJson(response);
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error creating household: $e');
      }
      rethrow;
    }
  }

  /// Update an existing household
  Future<Household?> updateHousehold(Household household) async {
    try {
      // Validate the household data
      if (household.id == null) {
        throw Exception('Household ID is required for updates');
      }

      final response = await _client
          .from(_table)
          .update(household.toJson())
          .eq(
              'id',
              household
                  .id!) // Use non-null assertion as we've validated it above
          .select()
          .single();

      return Household.fromJson(response);
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error updating household: $e');
      }
      rethrow;
    }
  }

  /// Delete a household
  Future<bool> deleteHousehold(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);

      return true;
    } catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        printError('Error deleting household: $e');
      }
      return false;
    }
  }
}
