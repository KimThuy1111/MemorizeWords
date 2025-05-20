import 'package:flutter/material.dart';

import '../main.dart';

import 'QuizScreen.dart';

import 'StatisticsScreen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 6.1. Người dùng đang ở màn hình chính (HomeScreen)
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Xin chào!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Hãy bắt đầu học từ vựng ngay hôm nay',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      _buildFeatureCard(
                        context,
                        'Học từ vựng',
                        Icons.school,
                        Colors.orange,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VocabularySetScreen(
                                userId: 'user123',
                              ),
                            ),
                          );
                        },
                      ),
                      //3.1 Thẻ chức năng "Kiểm tra"
                      _buildFeatureCard(
                        context,
                        'Kiểm tra',
                        Icons.quiz,
                        Colors.green,
                            () {
                          Navigator.push(
                            context,
                            //3.2 Khởi tạo QuizScreen với userId của người dùng hiện tại.
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(userId: 'user123'),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        'Từ đã nhớ',
                        Icons.check_circle,
                        Colors.blue,
                            () {
                          // TODO: Implement remembered words screen
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        'Thống kê',
                        Icons.bar_chart,
                        Colors.purple,

                        () {
                          // 6.2. Người dùng chọn icon "Xem thống kê kết quả học tập"
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StatisticsScreen(),
                            ),
                          );

                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}