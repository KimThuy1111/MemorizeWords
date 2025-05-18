class Statistics {
  final int totalFlashcards;
  final double correctRate;
  final List<DailyProgress> dailyProgress;
  final List<VocabularyStatus> vocabularyStatus;
  final int streakDays;
  final int completedSets;

  Statistics({
    required this.totalFlashcards,
    required this.correctRate,
    required this.dailyProgress,
    required this.vocabularyStatus,
    required this.streakDays,
    required this.completedSets,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalFlashcards: json['totalFlashcards'] ?? 0,
      correctRate: (json['correctRate'] ?? 0.0).toDouble(),
      dailyProgress: (json['dailyProgress'] as List?)
          ?.map((e) => DailyProgress.fromJson(e))
          .toList() ?? [],
      vocabularyStatus: (json['vocabularyStatus'] as List?)
          ?.map((e) => VocabularyStatus.fromJson(e))
          .toList() ?? [],
      streakDays: json['streakDays'] ?? 0,
      completedSets: json['completedSets'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFlashcards': totalFlashcards,
      'correctRate': correctRate,
      'dailyProgress': dailyProgress.map((e) => e.toJson()).toList(),
      'vocabularyStatus': vocabularyStatus.map((e) => e.toJson()).toList(),
      'streakDays': streakDays,
      'completedSets': completedSets,
    };
  }
}

class DailyProgress {
  final DateTime date;
  final int flashcardsLearned;

  DailyProgress({
    required this.date,
    required this.flashcardsLearned,
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date']),
      flashcardsLearned: json['flashcardsLearned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'flashcardsLearned': flashcardsLearned,
    };
  }
}

class VocabularyStatus {
  final String word;
  final String meaning;
  final bool isMemorized;

  VocabularyStatus({
    required this.word,
    required this.meaning,
    required this.isMemorized,
  });

  factory VocabularyStatus.fromJson(Map<String, dynamic> json) {
    return VocabularyStatus(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      isMemorized: json['isMemorized'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      'isMemorized': isMemorized,
    };
  }
} 