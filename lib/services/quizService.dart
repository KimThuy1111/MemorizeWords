import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memorize_word/screens/QuizScreen.dart';

import '../models/vocabulary.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Vocabulary>> getAllRememberedWords(String userId) async {
    try {
      //3.5 Hàm getAllRememberedWords(userId) sẽ lấy tất cả từ vựng có trạng thái 'remembered' từ Firestore.
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

  Future<void> saveQuizResult(
      String userId, int correctAnswers, int totalQuestions) async {
    //3.16 Hàm saveQuizResult() sẽ lưu kết quả bài kiểm tra vào Firestore
    await _firestore.collection('users').doc(userId).collection('quiz').add({
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
