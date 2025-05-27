class Vocabulary {
  static int currentIdIndex = 0;
  final int vocabId;
  final String word;
  final String meaning;
  String status; // "remembered", "review"
  final String? imageUrl;

  // Vocabulary(this.word, this.meaning, this.status, this.imageUrl)
  //

  Vocabulary.autoSetId({
    required this.word,
    required this.meaning,
    this.status = 'review',
    this.imageUrl,
  }) : vocabId = registerId();

  Vocabulary.manualSetId({
    required this.vocabId,
    required this.word,
    required this.meaning,
    this.status = 'review',
    this.imageUrl,
  });

  static int registerId() {
    return currentIdIndex++;
  }

  static Set<Vocabulary> getExample1() {
    return {
      Vocabulary.autoSetId(
          word: "Cat", meaning: "Mèo", imageUrl: "", status: "review"),
      Vocabulary.autoSetId(
          word: "Dog", meaning: "Chó", imageUrl: "", status: "review")
    };
  }

  static Set<Vocabulary> getExample2() {
    return {
      Vocabulary.autoSetId(word: "Table", meaning: "Bàn", status: "review"),
      Vocabulary.autoSetId(word: "Chair", meaning: "Ghế", status: "remembered")
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> data) {
    return Vocabulary.manualSetId(
      vocabId: data['vocabId'],
      word: data['word'],
      meaning: data['meaning'],
      status: data['status'] ?? 'review',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vocabId': vocabId,
      'word': word,
      'meaning': meaning,
      'status': status,
      'imageUrl': imageUrl,
    };
  }
}

// class Vocabulary {
//   final String id;
//   final String word;
//   final String meaning;
//   String status; // "remembered", "review"
//   final String? imageUrl;
//
//   Vocabulary({
//     required this.id,
//     required this.word,
//     required this.meaning,
//     this.status = 'review',
//     this.imageUrl,
//   });
//
//   factory Vocabulary.fromJson(Map<String, dynamic> json) {
//     return Vocabulary(
//       id: json['id'],
//       word: json['word'],
//       meaning: json['meaning'],
//       status: json['status'] ?? 'review',
//       imageUrl: json['imageUrl'],
//     );
//   }
//
// //   factory Vocabulary.fromJson(Map<String, dynamic> json) => _$VocabularyFromJson(json);
// //   Map<String, dynamic> toJson() => _$VocabularyToJson(this);
// // }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'word': word,
//       'meaning': meaning,
//       'status': status,
//       'imageUrl': imageUrl, // ✅
//     };
//   }
//
// }
