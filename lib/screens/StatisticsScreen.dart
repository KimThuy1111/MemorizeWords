import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/statistics.dart';
import '../controllers/statistics_controller.dart';

// 6.3. Hệ thống chuyển sang màn hình thống kê và thực hiện khởi tạo (initState())
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Khởi tạo dữ liệu thống kê khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsController>().initializeStatistics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<StatisticsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(child: Text(controller.error!));
          }

          final statistics = controller.statistics;
          if (statistics == null) {
            return const Center(child: Text('Không có dữ liệu thống kê'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCard(controller),
                const SizedBox(height: 20),
                _buildProgressChart(controller),
                const SizedBox(height: 20),
                _buildAchievementsCard(controller),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVocabularyList(controller.getMemorizedWords()),
                      _buildVocabularyList(controller.getWordsToReview()),
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

  Widget _buildOverviewCard(StatisticsController controller) {
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
                  controller.getTotalFlashcards().toString(),
                  Icons.book,
                ),
                _buildStatItem(
                  'Tỷ lệ đúng',
                  '${(controller.getCorrectRate() * 100).toStringAsFixed(1)}%',
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

  Widget _buildProgressChart(StatisticsController controller) {
    final progress = controller.getRecentProgress();
    final maxY = progress.isNotEmpty
        ? progress.map((e) => e.flashcardsLearned.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2
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
                  barGroups: progress
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
                          if (progress.isEmpty || value.toInt() >= progress.length) {
                            return const Text('');
                          }
                          final date = progress[value.toInt()].date;
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

  Widget _buildAchievementsCard(StatisticsController controller) {
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
                  '${controller.getStreakDays()} ngày',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildAchievementItem(
                  'Bộ hoàn thành',
                  '${controller.getCompletedSets()} bộ',
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

  Widget _buildVocabularyList(List<VocabularyStatus> words) {
    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final item = words[index];
        return ListTile(
          leading: Icon(
            item.isMemorized ? Icons.check_circle : Icons.warning,
            color: item.isMemorized ? Colors.green : Colors.orange,
          ),
          title: Text(item.word),
          subtitle: Text(item.meaning),
        );
      },
    );
  }
} 