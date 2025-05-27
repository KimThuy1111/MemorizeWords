import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:memorize_word/services/UserService.dart';
import '../models/Topic.dart';
import '../models/User.dart';
import '../models/vocabulary.dart';

class VocabularyService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  static User user = User.getExample(); //for test

  //7.1.8 Firebase trả về xác nhận lưu thành công nếu add thành công
  Future<bool> addVocabulary(Vocabulary vocab, User user, Topic topic) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: user.username)
          .limit(1)
          .get();
      if (userQuery.docs.isEmpty) {
        print("Không tìm thấy người dùng.");
        return false;
      }
      final userDocId = userQuery.docs.first.id;
      final topicQuery = await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('topicSets')
          .where('topicName', isEqualTo: user.topicSets.first)
          .limit(1)
          .get();
      if (topicQuery.docs.isEmpty) {
        print("Không tìm thấy topic: ${user.topicSets.first}");
        return false;
      }
      final topicDocId = topicQuery.docs.first.id;
      await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('topicSets')
          .doc(topicDocId)
          .collection('vocabularies')
          .add(vocab.toMap());

      print("✅ Đã lưu từ vựng thành công.");
      return true;
    } catch (e) {
      print("❌ Lỗi khi thêm từ vựng: $e");
      return false;
    }
  }

  //7.1.5 Hệ thống kiểm tra từ vựng trùng.
  Future<bool> isVocabularyDuplicate(String username, Vocabulary vocab) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      print('Không tìm thấy người dùng');
      return false;
    }

    final userId = snapshot.docs.first.id;

    // Truy cập collection con vocabs của user
    final vocabSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('vocabs')
        .where('word', isEqualTo: vocab.word)
        .limit(1)
        .get();

    return vocabSnapshot.docs.isNotEmpty;
  }

  Future<List<Vocabulary>> getVocabByUser(User user1) async {
    String username = user.username;
    _userService.getUserByUsername(username);
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc("${user.id}");
    final topicSetsSnapshot = await userDocRef.collection('topicSets').get();

    List<Vocabulary> allVocabularies = [];

    for (var topicDoc in topicSetsSnapshot.docs) {
      final vocabSnapshot =
          await topicDoc.reference.collection('vocabularies').get();

      final vocabularies = vocabSnapshot.docs
          .map((doc) => Vocabulary.fromMap(doc.data()))
          .toList();

      allVocabularies.addAll(vocabularies);
    }

    return allVocabularies;
  }

  // Thêm bộ từ vựng vào Firestore
  Future<void> addVocabularySet(
      Vocabulary vocab, Topic topic, User user1) async {
    // Duyệt qua các bộ từ vựng và thêm vào Firestore
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where("username", isEqualTo: user.id)
        .limit(1)
        .get();
    snapshot.docs.map((doc) {});
  }

// Duyệt qua các bộ từ vựng và thêm vào Firestore
  Future<List<Vocabulary>> getVocabularySet(
      String userId, String setName) async {
    final vocabularySetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('vocabulary_sets')
        .doc(setName)
        .collection('words');

    final querySnapshot = await vocabularySetRef.get();
    return querySnapshot.docs.map((doc) {
      return Vocabulary.manualSetId(
        vocabId: doc['vocabId'],
        word: doc['word'],
        meaning: doc['meaning'],
        imageUrl: doc['imageUrl'],
        status: doc['status'] ?? 'review',
      );
    }).toList();
  }

// Cập nhật trạng thái của từ vựng
  Future<void> updateWordStatus(
      String userId, String setName, int wordId, String status) async {
    // Cập nhật trạng thái từ trong Firestore
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_sets')
        .doc(setName)
        .collection('words')
        .get();

    List<Vocabulary> vocabs = snapshot.docs
        .map((doc) => Vocabulary.manualSetId(
            vocabId: doc['vocabId'],
            word: doc['word'],
            meaning: doc['meaning'],
            imageUrl: doc['imageUrl']))
        .toList();

    // await wordsRef.update({
    //   'status': status,
    //   'lastStudied': FieldValue.serverTimestamp(),
    // });
  }

//3.4 Lấy danh sách các từ có status='remembered' từ database
  Future<List<Vocabulary>> getAllRememberedWords(String userId) async {
    try {
      // Sử dụng collectionGroup với index đã tạo
      final query = await _firestore
          .collectionGroup('words')
          .where('status', isEqualTo: 'remembered')
          .get();

      return query.docs
          .map((doc) => Vocabulary.manualSetId(
                vocabId: doc['vocabId'],
                word: doc['word'],
                meaning: doc['meaning'],
                imageUrl: doc['imageUrl'],
                status: doc['status'],
              ))
          .toList();
    } catch (e) {
      print('Lỗi collectionGroup: $e');
      return [];
    }
  }

// 3.10 Lưu kết quả kiểm tra vào database

  Future<void> saveQuizResult(
      String userId, int correctAnswers, int totalQuestions) async {
    await _firestore.collection('users').doc(userId).collection('quizz').add({
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  bool addTopic(Topic topic, User user) {
    //if topic not exits, create it - > return true
    //if topic exits - > return false
    updateToFireBase(user);
    return false;
  }

  void removeVocabulary(String id) {
    //remove
    updateToFireBase(user);
  }

  void updateToFireBase(User user) {
    _userService.updateUser(user);
  }
}
