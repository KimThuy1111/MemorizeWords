import '../models/vocabulary.dart';
import '../services/vocabularyService.dart';

class FlashcardController {
  final VocabularyService _service = VocabularyService();

  List<Vocabulary> _vocabList = [];
  List<Vocabulary> _reviewLaterList = []; // danh sách từ cần ôn lại
  int _currentIndex = 0;

  List<Vocabulary> get vocabList => _vocabList;
  int get currentIndex => _currentIndex;
  Vocabulary? get currentWord {
    if (_vocabList.isNotEmpty && _currentIndex < _vocabList.length) {
      return _vocabList[_currentIndex];
    } else {
      return null;
    }
  }

  Future<void> initSession(String userId, String setName) async {
    _vocabList = await _service.getVocabularySet(userId, setName);
    if (_vocabList.isEmpty) {
    } else {
    }
    _reviewLaterList = [];
    _currentIndex = 0;
  }


  bool nextWord() {
    if (_currentIndex < _vocabList.length - 1) {
      _currentIndex++;
      return true; // ✅ Có từ tiếp theo
    } else if (_reviewLaterList.isNotEmpty) {
      _vocabList = List.from(_reviewLaterList);
      _reviewLaterList.clear();
      _currentIndex = 0;
      return true; // ✅ Bắt đầu ôn lại
    }
    _currentIndex++; // Đặt vượt khỏi length → currentWord sẽ trả về null
    return false;    // ❌ Không còn từ nào
  }




  Future<void> handleAnswer(String status) async {
    final current = currentWord;
    if (current == null) return;

    await updateStatus(current.id, status);

    if (status == 'review') {
      _reviewLaterList.add(current);
    }

    nextWord();

  }


  Future<void> updateStatus(String wordId, String status) async {
    final userId = 'user123'; // Thay thế bằng userId thực tế
    final setName = 'Động vật'; // Thay thế bằng setName thực tế

    await _service.updateWordStatus(userId, setName, wordId, status);
    // Cập nhật trạng thái trong danh sách cục bộ
    if (_currentIndex < _vocabList.length) {
      _vocabList[_currentIndex].status = status;
    }
  }
  // Định nghĩa phương thức addNewVocabularySet
  Future<void> addNewVocabularySet(String userId) async {
    try {
      await _service.addVocabularySet(userId);  // gọi service để thêm bộ từ vựng
      print('Vocabulary set added successfully');
    } catch (e) {
      print('Error adding vocabulary set: $e');
    }
  }

}
