import 'package:nylo_framework/nylo_framework.dart';

class Household {
  final String? id;
  final String name;
  final String? description;
  final String ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  Household({
    this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.createdAt,
    this.updatedAt,
  });
  
  /// Create a Household from Supabase JSON response
  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['owner_id'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
  
  /// Convert Household to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// Create a copy of this Household with the given fields updated
  Household copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'Household{id: $id, name: $name, description: $description, ownerId: $ownerId}';
  }
}
