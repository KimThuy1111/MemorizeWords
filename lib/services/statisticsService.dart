import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/statistics.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'user123'; // Set cứng user ID

  Future<Statistics> getStatistics() async {
    try {
      print('--- Bắt đầu lấy thống kê (collectionGroup) ---');
      final totalFlashcards = await _getTotalFlashcards();
      final correctRate = await _getCorrectRate();
      final dailyProgress = await _getDailyProgress();
      final vocabularyStatus = await _getVocabularyStatus();
      final streakDays = await _getStreakDays();
      final completedSets = await _getCompletedSets();
      print('--- Kết thúc lấy thống kê (collectionGroup) ---');
      return Statistics(
        totalFlashcards: totalFlashcards,
        correctRate: correctRate,
        dailyProgress: dailyProgress,
        vocabularyStatus: vocabularyStatus,
        streakDays: streakDays,
        completedSets: completedSets,
      );
    } catch (e) {
      print('Error getting statistics: $e');
      return _createSampleData();
    }
  }

  Future<int> _getTotalFlashcards() async {
    try {
      final query = await _firestore.collectionGroup('words').get();
      print('Tổng số từ (collectionGroup): ${query.docs.length}');
      return query.docs.length;
    } catch (e) {
      print('Error getting total flashcards: $e');
      return 0;
    }
  }

  Future<double> _getCorrectRate() async {
    try {
      final quizResults = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizz')
          .get();
      print('Số lần làm quiz: ${quizResults.docs.length}');
      if (quizResults.docs.isEmpty) return 0.0;
      int totalCorrect = 0;
      int totalQuestions = 0;
      for (var result in quizResults.docs) {
        print('Quiz: correct=${result['correctAnswers']}, total=${result['totalQuestions']}');
        totalCorrect += (result['correctAnswers'] as num).toInt();
        totalQuestions += (result['totalQuestions'] as num).toInt();
      }
      print('Tổng đúng: $totalCorrect, Tổng câu hỏi: $totalQuestions');
      return totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;
    } catch (e) {
      print('Error getting correct rate: $e');
      return 0.0;
    }
  }

  Future<List<DailyProgress>> _getDailyProgress() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 6));
      final dailyProgress = <DailyProgress>[];
      for (int i = 0; i < 7; i++) {
        final date = sevenDaysAgo.add(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        final query = await _firestore
            .collectionGroup('words')
            .where('lastStudied', isGreaterThanOrEqualTo: startOfDay)
            .where('lastStudied', isLessThan: endOfDay)
            .get();
        print('Ngày ${date.day}/${date.month}: Tổng số từ học (collectionGroup): ${query.docs.length}');
        dailyProgress.add(DailyProgress(
          date: date,
          flashcardsLearned: query.docs.length,
        ));
      }
      return dailyProgress;
    } catch (e) {
      print('Error getting daily progress: $e');
      return [];
    }
  }

  Future<List<VocabularyStatus>> _getVocabularyStatus() async {
    try {
      final query = await _firestore.collectionGroup('words').get();
      final vocabularyStatus = <VocabularyStatus>[];
      for (var word in query.docs) {
        print('Từ: ${word['word']} - status: ${word['status']}');
        vocabularyStatus.add(VocabularyStatus(
          word: word['word'] as String,
          meaning: word['meaning'] as String,
          isMemorized: word['status'] == 'remembered',
        ));
      }
      print('Tổng số từ cho danh sách (collectionGroup): ${vocabularyStatus.length}');
      return vocabularyStatus;
    } catch (e) {
      print('Error getting vocabulary status: $e');
      return [];
    }
  }

  Future<int> _getStreakDays() async {
    try {
      final now = DateTime.now();
      var currentDate = DateTime(now.year, now.month, now.day);
      var streakDays = 0;
      while (true) {
        final startOfDay = currentDate;
        final endOfDay = startOfDay.add(const Duration(days: 1));
        final query = await _firestore
            .collectionGroup('words')
            .where('lastStudied', isGreaterThanOrEqualTo: startOfDay)
            .where('lastStudied', isLessThan: endOfDay)
            .get();
        print('Streak - Ngày ${currentDate.day}/${currentDate.month}: Tổng số từ học (collectionGroup): ${query.docs.length}');
        if (query.docs.isEmpty) break;
        streakDays++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      }
      print('Số ngày streak (collectionGroup): $streakDays');
      return streakDays;
    } catch (e) {
      print('Error getting streak days: $e');
      return 0;
    }
  }

  Future<int> _getCompletedSets() async {
    try {
      // Đếm số bộ mà tất cả các từ đều remembered
      final setsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vocabulary_sets')
          .get();
      int completedSets = 0;
      for (var set in setsSnapshot.docs) {
        final wordsSnapshot = await set.reference.collection('words').get();
        if (wordsSnapshot.docs.isNotEmpty &&
            wordsSnapshot.docs.every((word) => word['status'] == 'remembered')) {
          completedSets++;
        }
      }
      print('Số bộ hoàn thành (collectionGroup): $completedSets');
      return completedSets;
    } catch (e) {
      print('Error getting completed sets: $e');
      return 0;
    }
  }

  // Giữ lại phương thức này để tạo dữ liệu mẫu khi cần
  Statistics _createSampleData() {
    final now = DateTime.now();
    final dailyProgress = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DailyProgress(
        date: date,
        flashcardsLearned: 10 + (index * 2),
      );
    });
    final vocabularyStatus = [
      VocabularyStatus(word: 'Hello', meaning: 'Xin chào', isMemorized: true),
      VocabularyStatus(word: 'World', meaning: 'Thế giới', isMemorized: true),
      VocabularyStatus(word: 'Flutter', meaning: 'Framework', isMemorized: false),
      VocabularyStatus(word: 'Dart', meaning: 'Ngôn ngữ lập trình', isMemorized: false),
    ];
    return Statistics(
      totalFlashcards: 120,
      correctRate: 0.75,
      dailyProgress: dailyProgress,
      vocabularyStatus: vocabularyStatus,
      streakDays: 3,
      completedSets: 5,
    );
  }

  Future<void> updateStatistics(Statistics statistics) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('statistics')
          .doc('learning_stats')
          .set(statistics.toJson());
    } catch (e) {
      print('Error updating statistics: $e');
    }
  }

  /// Hàm test: In ra toàn bộ từ vựng thực tế bằng collectionGroup
  Future<void> debugPrintAllWordsCollectionGroup() async {
    final query = await _firestore.collectionGroup('words').get();
    print('Tổng số từ (collectionGroup): ${query.docs.length}');
    for (var doc in query.docs) {
      print('Từ: ${doc.data()} | Đường dẫn: ${doc.reference.path}');
    }
  }
} 