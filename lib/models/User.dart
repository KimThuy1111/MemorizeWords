import 'Topic.dart';

class User {
  final int id;
  final String username;
  final String password;
  final Set<Topic> topicSets;

  User(
      {required this.id,
      required this.username,
      required this.password,
      required this.topicSets});

  // Hàm chuyển từ Map (Firestore) sang User
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? 0,
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      topicSets: data['topicSets'] ?? Set<Topic>(),
    );
  }

  // Hàm chuyển từ User sang Map (để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }
}
