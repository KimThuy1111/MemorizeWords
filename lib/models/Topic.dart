import 'package:memorize_word/models/vocabulary.dart';

class Topic {
  late final String id;
  late final String name;
  late final Set<Vocabulary> vocabularies;

  Topic({
    required this.id,
    required this.name,
    required this.vocabularies,
  });

  Topic.getExample1() {
    this.id = "1";
    this.name = "Animal";
    this.vocabularies = Vocabulary.getExample1();
  }

  Topic.getExample2() {
    this.id = "2";
    this.name = "Things";
    this.vocabularies = Vocabulary.getExample2();
  }

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
