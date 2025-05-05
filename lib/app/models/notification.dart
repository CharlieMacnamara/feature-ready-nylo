import 'package:nylo_framework/nylo_framework.dart';

class Notification extends Model {
  static StorageKey key = "notification";

  String? id;
  String? userId;
  String? title;
  String? message;
  String? type;
  bool isRead = false;
  DateTime? createdAt;

  Notification({
    this.id,
    this.userId,
    this.title,
    this.message,
    this.type,
    this.isRead = false,
    this.createdAt,
  }) : super(key: key);

  Notification.fromJson(Map<String, dynamic> data) : super(key: key) {
    id = data['id'];
    userId = data['user_id'];
    title = data['title'];
    message = data['message'];
    type = data['type'];
    isRead = data['is_read'] ?? false;
    createdAt =
        data['created_at'] != null ? DateTime.parse(data['created_at']) : null;
  }

  @override
  toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
