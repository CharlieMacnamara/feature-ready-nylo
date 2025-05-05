import 'package:flutter_app/app/models/household.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for managing household data
class HouseholdRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all households (use with caution, consider admin-only or specific use cases)
  Future<List<Household>> fetchHouseholds() async {
    try {
      final response = await _client.from('households').select();
      return response.map((json) => Household.fromJson(json)).toList();
    } catch (e) {
      printError('Error fetching households: $e');
      return [];
    }
  }

  /// Get a single household by ID
  Future<Household?> getHousehold(String id) async {
    try {
      final response =
          await _client.from('households').select().eq('id', id).single();
      return Household.fromJson(response);
    } catch (e) {
      printError('Error getting household: $e');
      return null;
    }
  }

  /// Fetch households that a user belongs to
  Future<List<Household>> fetchUserHouseholds(String userId) async {
    try {
      final response = await _client
          .from('households')
          .select('*, household_members!inner(user_id)')
          .eq('household_members.user_id', userId);
      
      return (response as List)
          .map((item) => Household.fromJson(item))
          .toList();
    } catch (e) {
      printError('Error fetching user households: $e');
      return [];
    }
  }

  /// Create a new household
  Future<Household?> createHousehold(Household household) async {
    try {
      // First create the household
      final response = await _client
          .from('households')
          .insert({
            'name': household.name,
            'description': household.description,
            'owner_id': household.ownerId,
          })
          .select()
          .single();
      
      final createdHousehold = Household.fromJson(response);
      
      // Then add the owner as a household member
      await _client.from('household_members').insert({
        'household_id': createdHousehold.id,
        'user_id': household.ownerId,
        'role': 'owner',
      });
      
      return createdHousehold;
    } catch (e) {
      printError('Error creating household: $e');
      return null;
    }
  }

  /// Update household details
  Future<Household?> updateHousehold(Household household) async {
    try {
      if (household.id == null) {
        throw Exception('Cannot update household without ID');
      }
      
      final response = await _client
          .from('households')
          .update({
            'name': household.name,
            'description': household.description,
          })
          .eq('id', household.id!)
          .select()
          .single();
      
      return Household.fromJson(response);
    } catch (e) {
      printError('Error updating household: $e');
      return null;
    }
  }

  /// Delete a household
  Future<bool> deleteHousehold(String householdId) async {
    try {
      await _client
          .from('households')
          .delete()
          .eq('id', householdId);
      
      return true;
    } catch (e) {
      printError('Error deleting household: $e');
      return false;
    }
  }

  /// Add a member to a household
  Future<bool> addMember(String householdId, String userId, {String role = 'member'}) async {
    try {
      await _client.from('household_members').insert({
        'household_id': householdId,
        'user_id': userId,
        'role': role,
      });
      
      return true;
    } catch (e) {
      printError('Error adding household member: $e');
      return false;
    }
  }

  /// Remove a member from a household
  Future<bool> removeMember(String householdId, String userId) async {
    try {
      await _client
          .from('household_members')
          .delete()
          .eq('household_id', householdId)
          .eq('user_id', userId);
      
      return true;
    } catch (e) {
      printError('Error removing household member: $e');
      return false;
    }
  }

  /// Get household members
  Future<List<Map<String, dynamic>>> getHouseholdMembers(String householdId) async {
    try {
      final response = await _client
          .from('household_members')
          .select('*, profiles:user_id(*)')
          .eq('household_id', householdId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      printError('Error fetching household members: $e');
      return [];
    }
  }
}
