import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> fixLastStudiedToTimestamp(String userId) async {
  final firestore = FirebaseFirestore.instance;
  final setsSnapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('vocabulary_sets')
      .get();

  for (var setDoc in setsSnapshot.docs) {
    final wordsSnapshot = await setDoc.reference.collection('words').get();
    for (var wordDoc in wordsSnapshot.docs) {
      final data = wordDoc.data();
      final lastStudied = data['lastStudied'];
      // Nếu là string, chuyển sang Timestamp
      if (lastStudied is String) {
        try {
          final dateTime = DateTime.parse(lastStudied);
          await wordDoc.reference.update({
            'lastStudied': Timestamp.fromDate(dateTime),
          });
          print('Đã sửa lastStudied cho từ: ${data['word']}');
        } catch (e) {
          print('Không chuyển được $lastStudied: $e');
        }
      }
    }
  }
  print('Hoàn thành sửa dữ liệu lastStudied!');
} 