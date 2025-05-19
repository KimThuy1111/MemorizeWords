import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/statistics.dart';
import '../services/statisticsService.dart';

// 6.3. Hệ thống chuyển sang màn hình thống kê và thực hiện khởi tạo (initState())
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  // 6.4. Hệ thống gọi hàm getStatistics() để bắt đầu lấy dữ liệu thống kê
  final StatisticsService _statisticsService = StatisticsService();
  late Future<Statistics> _statisticsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 6.3. Gọi initState() khi vào màn hình thống kê
    _statisticsFuture = _statisticsService.getStatistics(); // 6.4. Gọi getStatistics()
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 6.9. Hệ thống trả về dữ liệu thống kê cho màn hình giao diện
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê học tập'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Đã ghi nhớ'),
            Tab(text: 'Cần ôn lại'),
          ],
        ),
      ),
      body: FutureBuilder<Statistics>(
        future: _statisticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // 6.12. Alternative Flow: Nếu lỗi kết nối hoặc không có dữ liệu
            // Hệ thống hiển thị thông báo lỗi cho người dùng
            return Center(child: Text('Đã có lỗi xảy ra. Vui lòng kiểm tra kết nối mạng.'));
          }

          final statistics = snapshot.data!;
          // 6.10. Màn hình giao diện gọi các hàm hiển thị:
          // 6.10.1. Hiển thị tổng quan, tỷ lệ đúng, tiến độ học tập, thành tích và danh sách từ vựng.
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCard(statistics), // 6.10.1. Hiển thị tổng quan
                const SizedBox(height: 20),
                _buildProgressChart(statistics), // 6.10.1. Hiển thị biểu đồ tiến độ học tập
                const SizedBox(height: 20),
                _buildAchievementsCard(statistics), // 6.10.1. Hiển thị thành tích
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVocabularyList(statistics, true), // 6.10.1. Hiển thị danh sách từ đã ghi nhớ
                      _buildVocabularyList(statistics, false), // 6.10.1. Hiển thị danh sách từ cần ôn lại
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(Statistics statistics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Tổng số từ',
                  statistics.totalFlashcards.toString(),
                  Icons.book,
                ),
                _buildStatItem(
                  'Tỷ lệ đúng',
                  '${(statistics.correctRate * 100).toStringAsFixed(1)}%',
                  Icons.check_circle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProgressChart(Statistics statistics) {
    final maxY = statistics.dailyProgress.isNotEmpty
        ? statistics.dailyProgress.map((e) => e.flashcardsLearned.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2
        : 10.0;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiến độ 7 ngày gần nhất',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barGroups: statistics.dailyProgress
                      .asMap()
                      .entries
                      .map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.flashcardsLearned.toDouble(),
                              color: Theme.of(context).primaryColor,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      })
                      .toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (statistics.dailyProgress.isEmpty || value.toInt() >= statistics.dailyProgress.length) {
                            return const Text('');
                          }
                          final date = statistics.dailyProgress[value.toInt()].date;
                          return Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(Statistics statistics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thành tích',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAchievementItem(
                  'Học liên tục',
                  '${statistics.streakDays} ngày',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildAchievementItem(
                  'Bộ hoàn thành',
                  '${statistics.completedSets} bộ',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildVocabularyList(Statistics statistics, bool isMemorized) {
    final filteredList = statistics.vocabularyStatus
        .where((item) => item.isMemorized == isMemorized)
        .toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return ListTile(
          leading: Icon(
            isMemorized ? Icons.check_circle : Icons.warning,
            color: isMemorized ? Colors.green : Colors.orange,
          ),
          title: Text(item.word),
          subtitle: Text(item.meaning),
        );
      },
    );
  }
} 