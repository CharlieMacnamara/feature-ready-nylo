import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  String? id;
  String? name;
  String? email;
  String? avatarUrl;

  static StorageKey key = 'user';

  User({
    this.id,
    this.name,
    this.email,
    this.avatarUrl,
  }) : super(key: key);

  User.fromJson(Map<String, dynamic> data) : super(key: key) {
    id = data['id'];
    name = data['name'];
    email = data['email'];
    avatarUrl = data['avatar_url'];
  }

  @override
  toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "avatar_url": avatarUrl,
      };
}
