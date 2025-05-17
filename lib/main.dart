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
  final FlashcardController controller = FlashcardController();

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
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chọn bộ từ vựng',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () => controller.addNewVocabularySet(userId),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade100,
                Colors.white,
              ],
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            itemCount: sets.length,
            itemBuilder: (context, index) {
              final set = sets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: (set['color'] as Color).withOpacity(0.15),
                            radius: 28,
                            child: Icon(
                              set['icon'] as IconData,
                              color: set['color'] as Color,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              set['name'] as String,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
