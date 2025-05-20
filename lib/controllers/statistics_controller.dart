import 'package:flutter/material.dart';
import '../models/statistics.dart';
import '../services/statisticsService.dart';

class StatisticsController extends ChangeNotifier {
  final StatisticsService _statisticsService;
  Statistics? _statistics;
  bool _isLoading = false;
  String? _error;

  StatisticsController(this._statisticsService);

  // Getters
  Statistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Khởi tạo dữ liệu thống kê
  Future<void> initializeStatistics() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _statistics = await _statisticsService.getStatistics();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Đã có lỗi xảy ra khi tải dữ liệu thống kê: $e';
      notifyListeners();
    }
  }

  // Cập nhật dữ liệu thống kê
  Future<void> updateStatistics(Statistics newStatistics) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _statisticsService.updateStatistics(newStatistics);
      _statistics = newStatistics;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Đã có lỗi xảy ra khi cập nhật dữ liệu thống kê: $e';
      notifyListeners();
    }
  }

  // Lấy danh sách từ vựng đã ghi nhớ
  List<VocabularyStatus> getMemorizedWords() {
    return _statistics?.vocabularyStatus
            .where((item) => item.isMemorized)
            .toList() ??
        [];
  }

  // Lấy danh sách từ vựng cần ôn lại
  List<VocabularyStatus> getWordsToReview() {
    return _statistics?.vocabularyStatus
            .where((item) => !item.isMemorized)
            .toList() ??
        [];
  }

  // Lấy tiến độ học tập 7 ngày gần nhất
  List<DailyProgress> getRecentProgress() {
    return _statistics?.dailyProgress ?? [];
  }

  // Lấy tỷ lệ đúng
  double getCorrectRate() {
    return _statistics?.correctRate ?? 0.0;
  }

  // Lấy số ngày học liên tục
  int getStreakDays() {
    return _statistics?.streakDays ?? 0;
  }

  // Lấy số bộ từ đã hoàn thành
  int getCompletedSets() {
    return _statistics?.completedSets ?? 0;
  }

  // Lấy tổng số flashcard
  int getTotalFlashcards() {
    return _statistics?.totalFlashcards ?? 0;
  }
} 