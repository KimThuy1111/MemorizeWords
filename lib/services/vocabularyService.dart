import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocabulary.dart';

class VocabularyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thêm bộ từ vựng vào Firestore
  Future<void> addVocabularySet(String userId) async {
    // Dữ liệu mẫu
    final mockData = {
      'Động vật': [
        Vocabulary(id: '1', word: 'Cat', meaning: 'Con mèo', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/3a/Cat03.jpg'),
        Vocabulary(id: '2', word: 'Dog', meaning: 'Con chó', imageUrl: 'https://i.pinimg.com/736x/66/21/d6/6621d6c3a9b44d4f022d96facdba04e4.jpg'),
      ],
      'Đồ vật': [
        Vocabulary(id: '3', word: 'Table', meaning: 'Cái bàn', imageUrl: 'https://i.pinimg.com/736x/33/c5/51/33c55165bd7c0be17fa86c3fdd62bcf0.jpg'),
        Vocabulary(id: '4', word: 'Chair', meaning: 'Cái ghế', imageUrl: 'https://i.pinimg.com/736x/2a/34/37/2a3437af6cdaf8584f90449a87e8095a.jpg'),
      ],
      'Thời tiết': [
        Vocabulary(id: '5', word: 'Rain', meaning: 'Mưa', imageUrl: 'https://i.pinimg.com/736x/25/bf/5a/25bf5a29a626e3daa95b26b7c2df7c52.jpg'),
        Vocabulary(id: '6', word: 'Snow', meaning: 'Tuyết', imageUrl: 'https://i.pinimg.com/736x/c6/47/b6/c647b6642495b2ab9e09e16035ec648c.jpg'),
      ],
      'Cây cối': [
        Vocabulary(id: '7', word: 'Tree', meaning: 'Cây', imageUrl: 'https://i.pinimg.com/736x/81/9c/3b/819c3b2fb762b1149588591569e4a260.jpg'),
        Vocabulary(id: '8', word: 'Leaf', meaning: 'Lá cây', imageUrl: 'https://i.pinimg.com/736x/e8/72/51/e872511675261f99ecd4a76d1e0b147c.jpg'),
      ],
    };

    // Duyệt qua các bộ từ vựng và thêm vào Firestore
    for (var set in mockData.keys) {
      // Tạo document cho bộ từ vựng
      final vocabularySetRef = _firestore.collection('users').doc(userId).collection('vocabulary_sets').doc(set);

      for (var vocabulary in mockData[set]!) {
        // Thêm từ vào collection 'words' của bộ từ vựng
        await vocabularySetRef.collection('words').doc(vocabulary.id).set({
          'word': vocabulary.word,
          'meaning': vocabulary.meaning,
          'imageUrl': vocabulary.imageUrl,
          'status': vocabulary.status,
          'lastStudied': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Duyệt qua các bộ từ vựng và thêm vào Firestore
  Future<List<Vocabulary>> getVocabularySet(String userId, String setName) async {
    final vocabularySetRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_sets')
        .doc(setName)
        .collection('words');

    final querySnapshot = await vocabularySetRef.get();
    return querySnapshot.docs.map((doc) {
      return Vocabulary(
        id: doc.id,
        word: doc['word'],
        meaning: doc['meaning'],
        imageUrl: doc['imageUrl'],
        status: doc['status'] ?? 'review',
      );
    }).toList();
  }

  // Cập nhật trạng thái của từ vựng
  Future<void> updateWordStatus(String userId, String setName, String wordId, String status) async {
    // Cập nhật trạng thái từ trong Firestore
    final wordRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_sets')
        .doc(setName)
        .collection('words')
        .doc(wordId);

    await wordRef.update({
      'status': status,
      'lastStudied': FieldValue.serverTimestamp(),
    });
  }
  //3.5 Lấy danh sách các từ có status='remembered' từ database
  Future<List<Vocabulary>> getAllRememberedWords(String userId) async {
    try {
      // Sử dụng collectionGroup với index đã tạo
      final query = await _firestore
          .collectionGroup('words')
          .where('status', isEqualTo: 'remembered')
          .get();

      return query.docs.map((doc) => Vocabulary(
        id: doc.id,
        word: doc['word'],
        meaning: doc['meaning'],
        imageUrl: doc['imageUrl'],
        status: doc['status'],
      )).toList();
    } catch (e) {
      print('Lỗi collectionGroup: $e');
      return [];
    }
  }

  // 3.11 Lưu kết quả kiểm tra vào database

  Future<void> saveQuizResult(
      String userId, int correctAnswers, int totalQuestions) async {
    await _firestore.collection('users').doc(userId).collection('quizz').add({
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
