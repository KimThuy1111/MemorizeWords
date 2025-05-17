import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memorize_word/screens/HomeScreen.dart';
import 'screens/flashcardScreen.dart';
import '../controllers/flashcardController.dart';  // Thêm import controller

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // <-- Quan trọng!
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocabulary Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VocabularySetScreen extends StatelessWidget {
  final String userId;
  final FlashcardController controller = FlashcardController();  // Khởi tạo controller

  VocabularySetScreen({super.key, required this.userId});



  @override
  Widget build(BuildContext context) {
    final sets = [
      {'name': 'Động vật', 'icon': Icons.pets, 'color': Colors.orange},
      {'name': 'Đồ vật', 'icon': Icons.chair, 'color': Colors.blue},
      {'name': 'Thời tiết', 'icon': Icons.cloud, 'color': Colors.green},
      {'name': 'Cây cối', 'icon': Icons.nature, 'color': Colors.brown},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chọn bộ từ vựng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => controller.addNewVocabularySet(userId),  // Mở hộp thoại thêm bộ từ vựng
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: sets.length,
          itemBuilder: (context, index) {
            final set = sets[index];

            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                    set['icon'] as IconData, color: set['color'] as Color,
                    size: 32),
                title: Text(
                  set['name'] as String,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(
                    Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashcardScreen(
                        userId: userId,
                        setName: set['name'] as String,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
