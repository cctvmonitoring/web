import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/yolo_provider.dart';

// 시간대별 이벤트 더미 데이터
final List<Map<String, int>> hourlyEvents = [
  {'hour': 0, 'event_count': 7},
  {'hour': 1, 'event_count': 4},
  {'hour': 2, 'event_count': 3},
  {'hour': 3, 'event_count': 4},
  {'hour': 4, 'event_count': 6},
  {'hour': 5, 'event_count': 4},
  {'hour': 6, 'event_count': 3},
  {'hour': 7, 'event_count': 3},
  {'hour': 8, 'event_count': 4},
  {'hour': 9, 'event_count': 4},
  {'hour': 10, 'event_count': 5},
  {'hour': 11, 'event_count': 5},
  {'hour': 12, 'event_count': 4},
  {'hour': 13, 'event_count': 6},
  {'hour': 14, 'event_count': 7},
  {'hour': 15, 'event_count': 8},
  {'hour': 16, 'event_count': 4},
  {'hour': 17, 'event_count': 5},
  {'hour': 18, 'event_count': 4},
  {'hour': 19, 'event_count': 7},
  {'hour': 20, 'event_count': 9},
  {'hour': 21, 'event_count': 5},
  {'hour': 22, 'event_count': 1},
  {'hour': 23, 'event_count': 3},
];

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final yoloProvider = Provider.of<YoloProvider>(context);
    final totalEvents = yoloProvider.detections.length;
    final cameraCount = yoloProvider.cameraIds.length;
    final personCount = yoloProvider.countPersonDetections;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 실시간 모니터링 섹션
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '실시간 모니터링',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatusCard(
                        '카메라 상태',
                        Icons.videocam,
                        '${yoloProvider.detections.length}대 연결됨',
                        Colors.blue,
                        [
                          _buildStatusItem('정상', 8),
                          _buildStatusItem('점검중', 2),
                          _buildStatusItem('오프라인', 1),
                        ],
                      ),
                      _buildStatusCard(
                        '객체 감지',
                        Icons.person_search,
                        '${_countTotalDetections(yoloProvider)}개 감지됨',
                        Colors.green,
                        [
                          _buildStatusItem('사람', _countDetectionsByType(yoloProvider, 'person')),
                          _buildStatusItem('차량', _countDetectionsByType(yoloProvider, 'car')),
                          _buildStatusItem('기타', _countDetectionsByType(yoloProvider, 'other')),
                        ],
                      ),
                      _buildStatusCard(
                        '알림 현황',
                        Icons.notifications_active,
                        '${_countActiveAlerts(yoloProvider)}개 활성화됨',
                        Colors.orange,
                        [
                          _buildStatusItem('긴급', 2),
                          _buildStatusItem('경고', 3),
                          _buildStatusItem('정보', 5),
                        ],
                      ),
                      _buildStatusCard(
                        '시스템 리소스',
                        Icons.memory,
                        '정상 작동중',
                        Colors.purple,
                        [
                          _buildStatusItem('CPU', '45%'),
                          _buildStatusItem('메모리', '60%'),
                          _buildStatusItem('저장공간', '75%'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 기존 통계 섹션
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('실시간 보안 현황',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('활성 카메라', '$cameraCount대'),
                      _buildStatItem('오늘 이벤트', '$totalEvents건'),
                      _buildStatItem('중요 경고', '$personCount건'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('시간대별 이벤트 발생',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: _buildHourlyEventsChart(hourlyEvents),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    IconData icon,
    String subtitle,
    Color color,
    List<Widget> statusItems,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ...statusItems,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey
            )),
      ],
    );
  }

  Widget _buildHourlyEventsChart(List<Map<String, int>> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (data.map((e) => e['event_count']!).reduce((a, b) => a > b ? a : b) + 2).toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 3,
              getTitlesWidget: (double value, TitleMeta meta) {
                final hour = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '$hour',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data
            .map((e) => BarChartGroupData(
          x: e['hour']!,
          barRods: [
            BarChartRodData(
              toY: e['event_count']!.toDouble(),
              color: Colors.blueAccent,
              width: 10,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ))
            .toList(),
        gridData: FlGridData(show: true),
      ),
    );
  }

  int _countTotalDetections(YoloProvider provider) {
    return provider.detections.fold(
      0,
      (sum, detection) => sum + detection.objects.length,
    );
  }

  int _countDetectionsByType(YoloProvider provider, String type) {
    return provider.detections.fold(
      0,
      (sum, detection) => sum + detection.objects.where((obj) => obj['type'] == type).length,
    );
  }

  int _countActiveAlerts(YoloProvider provider) {
    return provider.detections.where((d) => d.objects.isNotEmpty).length;
  }
}
