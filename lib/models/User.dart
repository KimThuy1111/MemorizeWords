import 'package:cloud_firestore/cloud_firestore.dart';

import 'Topic.dart';

class User {
  late final int id;
  late final String username;
  late final String password;
  late final Set<Topic> topicSets;

  User.getExample() {
    this.id = 1;
    this.username = "thinhlien";
    this.password = "nhom9";
    this.topicSets = {Topic.getExample1(), Topic.getExample2()};
  }

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

  factory User.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: data['id'] ?? 0,
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      topicSets: data['topicSets'] ?? Set<Topic>(),
    );
  }
}
