import 'package:supabase_flutter/supabase_flutter.dart';
import '/app/models/chore.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Repository for managing chore data
class ChoreRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  /// Fetch chores by household ID
  Future<List<Chore>> fetchByHousehold(String householdId) async {
    try {
      final response = await _client
          .from('chore_definitions')
          .select('*, chore_assignments(*), households(*)')
          .eq('household_id', householdId);
      
      return (response as List)
          .map((item) => Chore.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      printError('Error fetching chores: $e');
      return [];
    }
  }
  
  /// Fetch chores assigned to a specific user
  Future<List<Chore>> fetchAssignedToUser(String userId) async {
    try {
      final response = await _client
          .from('chore_assignments')
          .select('*, chore_definitions(*), households(*)')
          .eq('assigned_to', userId);
      
      List<Chore> chores = [];
      for (var item in response) {
        final choreDefinition = item['chore_definitions'];
        if (choreDefinition != null) {
          // Merge the assignment data with the chore definition
          final merged = {
            ...Map<String, dynamic>.from(choreDefinition),
            'assigned_to': item['assigned_to'],
            'assigned_at': item['assigned_at'],
            'due_date': item['due_date'],
            'completed': item['completed'],
            'completed_at': item['completed_at'],
            'assignment_id': item['id'],
          };
          chores.add(Chore.fromJson(merged));
        }
      }
      
      return chores;
    } catch (e) {
      printError('Error fetching assigned chores: $e');
      return [];
    }
  }
  
  /// Create a new chore
  Future<Chore?> createChore(Chore chore) async {
    try {
      // Create the chore definition
      final response = await _client
          .from('chore_definitions')
          .insert({
            'title': chore.title,
            'description': chore.description,
            'frequency': chore.frequency,
            'points': chore.points,
            'household_id': chore.householdId,
            'created_by': chore.createdBy,
          })
          .select()
          .single();
      
      return Chore.fromJson(response);
    } catch (e) {
      printError('Error creating chore: $e');
      return null;
    }
  }
  
  /// Update an existing chore
  Future<Chore?> updateChore(Chore chore) async {
    try {
      if (chore.id == null) {
        throw Exception('Cannot update chore without ID');
      }
      
      final response = await _client
          .from('chore_definitions')
          .update({
            'title': chore.title,
            'description': chore.description,
            'frequency': chore.frequency,
            'points': chore.points,
          })
          .eq('id', chore.id!)
          .select()
          .single();
      
      return Chore.fromJson(response);
    } catch (e) {
      printError('Error updating chore: $e');
      return null;
    }
  }
  
  /// Delete a chore
  Future<bool> deleteChore(String choreId) async {
    try {
      await _client
          .from('chore_definitions')
          .delete()
          .eq('id', choreId);
      
      return true;
    } catch (e) {
      printError('Error deleting chore: $e');
      return false;
    }
  }
  
  /// Assign a chore to a user
  Future<bool> assignChore(String choreId, String userId, {DateTime? dueDate}) async {
    try {
      await _client.from('chore_assignments').insert({
        'chore_id': choreId,
        'assigned_to': userId,
        'assigned_at': DateTime.now().toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
        'completed': false,
      });
      
      return true;
    } catch (e) {
      printError('Error assigning chore: $e');
      return false;
    }
  }
  
  /// Mark a chore as complete
  Future<bool> markComplete(String assignmentId) async {
    try {
      await _client
          .from('chore_assignments')
          .update({
            'completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', assignmentId);
      
      return true;
    } catch (e) {
      printError('Error marking chore as complete: $e');
      return false;
    }
  }
  
  /// Get chore history
  Future<List<Map<String, dynamic>>> getChoreHistory(String choreId) async {
    try {
      final response = await _client
          .from('chore_assignments')
          .select('*, profiles:assigned_to(*)')
          .eq('chore_id', choreId)
          .order('assigned_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      printError('Error fetching chore history: $e');
      return [];
    }
  }
}
