import 'package:memorize_word/models/vocabulary.dart';

class Topic {
  final String id;
  final String name;
  final Set<Vocabulary> vocabularies;

  Topic({
    required this.id,
    required this.name,
    required this.vocabularies,
  });

  factory Topic.fromMap(String id, Map<String, dynamic> data) {
    var vocabList = (data['vocabularies'] as List<dynamic>? ?? [])
        .map((e) => Vocabulary.fromMap(e))
        .toSet();

    return Topic(
      id: id,
      name: data['name'] ?? '',
      vocabularies: vocabList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'vocabularies': vocabularies.map((vocab) => vocab.toMap()).toList(),
    };
  }
}
