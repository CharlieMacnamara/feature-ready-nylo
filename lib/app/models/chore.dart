import 'package:nylo_framework/nylo_framework.dart';

class Chore {
  final String? id;
  final String title;
  final String? description;
  final String? frequency; // daily, weekly, monthly, etc.
  final int? points;
  final String householdId;
  final String? assignmentId;
  final String? assignedTo;
  final DateTime? assignedAt;
  final DateTime? dueDate;
  final bool? completed;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  
  Chore({
    this.id,
    required this.title,
    this.description,
    this.frequency,
    this.points,
    required this.householdId,
    this.assignmentId,
    this.assignedTo,
    this.assignedAt,
    this.dueDate,
    this.completed,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });
  
  /// Create a Chore from Supabase JSON response
  factory Chore.fromJson(Map<String, dynamic> json) {
    return Chore(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      frequency: json['frequency'],
      points: json['points'],
      householdId: json['household_id'],
      assignmentId: json['assignment_id'],
      assignedTo: json['assigned_to'],
      assignedAt: json['assigned_at'] != null 
          ? DateTime.parse(json['assigned_at']) 
          : null,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date']) 
          : null,
      completed: json['completed'],
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      createdBy: json['created_by'],
    );
  }
  
  /// Convert Chore to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency,
      'points': points,
      'household_id': householdId,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// Create a copy of this Chore with the given fields updated
  Chore copyWith({
    String? id,
    String? title,
    String? description,
    String? frequency,
    int? points,
    String? householdId,
    String? assignmentId,
    String? assignedTo,
    DateTime? assignedAt,
    DateTime? dueDate,
    bool? completed,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Chore(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      points: points ?? this.points,
      householdId: householdId ?? this.householdId,
      assignmentId: assignmentId ?? this.assignmentId,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedAt: assignedAt ?? this.assignedAt,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
  
  @override
  String toString() {
    return 'Chore{id: $id, title: $title, householdId: $householdId, assignedTo: $assignedTo, completed: $completed}';
  }
}
