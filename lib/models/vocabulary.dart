class Vocabulary {
  final String vocabId;
  final String word;
  final String meaning;
  String status; // "remembered", "review"
  final String? imageUrl;

  Vocabulary({
    required this.vocabId,
    required this.word,
    required this.meaning,
    this.status = 'review',
    this.imageUrl,
  });

  factory Vocabulary. fromMap(Map<String, dynamic> data) {
    return Vocabulary(
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
