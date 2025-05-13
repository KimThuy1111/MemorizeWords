class Vocabulary {
  final String id;
  final String word;
  final String meaning;
  String status; // "remembered", "review"
  final String? imageUrl; // ✅ thêm thuộc tính mới

  Vocabulary({
    required this.id,
    required this.word,
    required this.meaning,
    this.status = 'review',
    this.imageUrl, // ✅
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'],
      word: json['word'],
      meaning: json['meaning'],
      status: json['status'] ?? 'review',
      imageUrl: json['imageUrl'], // ✅
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'status': status,
      'imageUrl': imageUrl, // ✅
    };
  }
}
