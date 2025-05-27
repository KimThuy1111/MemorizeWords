import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vocabulary.dart';

class VocabularyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Thêm từ vựng vào Firestore cho user cụ thể
  Future<void> addVocabulary(String userId, Vocabulary vocab) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabs')
        .add(vocab.toMap());
  }

  /// Lấy danh sách từ vựng của 1 user
  Future<List<Vocabulary>> getVocabularies(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabs')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Vocabulary.fromMap(data);
    }).toList();
  }
}
