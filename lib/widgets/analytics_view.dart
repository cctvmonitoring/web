import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  // 선택된 분석 카테고리
  String _selectedCategory = '시간대별 이상 행동';

  // 시간대별 이상 행동 데이터
  final List<Map<String, dynamic>> _hourlyData = [
    {'hour': 0, 'count': 2},
    {'hour': 1, 'count': 1},
    {'hour': 2, 'count': 0},
    {'hour': 3, 'count': 1},
    {'hour': 4, 'count': 2},
    {'hour': 5, 'count': 1},
    {'hour': 6, 'count': 3},
    {'hour': 7, 'count': 4},
    {'hour': 8, 'count': 5},
    {'hour': 9, 'count': 6},
    {'hour': 10, 'count': 4},
    {'hour': 11, 'count': 3},
    {'hour': 12, 'count': 2},
    {'hour': 13, 'count': 3},
    {'hour': 14, 'count': 4},
    {'hour': 15, 'count': 5},
    {'hour': 16, 'count': 6},
    {'hour': 17, 'count': 7},
    {'hour': 18, 'count': 5},
    {'hour': 19, 'count': 4},
    {'hour': 20, 'count': 3},
    {'hour': 21, 'count': 2},
    {'hour': 22, 'count': 1},
    {'hour': 23, 'count': 1},
  ];

  // 구역별 위험도 데이터
  final List<Map<String, dynamic>> _zoneRiskData = [
    {'zone': 'A구역', 'risk': 0.8},
    {'zone': 'B구역', 'risk': 0.5},
    {'zone': 'C구역', 'risk': 0.3},
    {'zone': 'D구역', 'risk': 0.6},
  ];

  // 객체 감지 통계 데이터
  final List<Map<String, dynamic>> _objectDetectionData = [
    {'type': '사람', 'count': 45},
    {'type': '차량', 'count': 30},
    {'type': '자전거', 'count': 15},
    {'type': '기타', 'count': 10},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 카테고리 선택
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                '분석 카테고리:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedCategory,
                items: [
                  '시간대별 이상 행동',
                  '구역별 위험도',
                  '객체 감지 통계',
                  '트렌드 분석',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        // 분석 결과 표시
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCategory,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildAnalyticsContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsContent() {
    switch (_selectedCategory) {
      case '시간대별 이상 행동':
        return _buildHourlyChart();
      case '구역별 위험도':
        return _buildZoneRiskChart();
      case '객체 감지 통계':
        return _buildObjectDetectionChart();
      case '트렌드 분석':
        return _buildTrendAnalysis();
      default:
        return const Center(child: Text('데이터를 불러오는 중...'));
    }
  }

  Widget _buildHourlyChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
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
                    '$hour시',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _hourlyData.map((data) {
              return FlSpot(
                data['hour'].toDouble(),
                data['count'].toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneRiskChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < _zoneRiskData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _zoneRiskData[index]['zone'],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _zoneRiskData.map((data) {
          return BarChartGroupData(
            x: _zoneRiskData.indexOf(data),
            barRods: [
              BarChartRodData(
                toY: data['risk'],
                color: Colors.orange,
                width: 20,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildObjectDetectionChart() {
    return PieChart(
      PieChartData(
        sections: _objectDetectionData.map((data) {
          return PieChartSectionData(
            value: data['count'].toDouble(),
            title: '${data['type']}\n${data['count']}',
            color: _getColorForObjectType(data['type']),
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Column(
      children: [
        const Text(
          '최근 7일간의 이상 행동 트렌드',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.trending_up),
                  title: Text('${index + 1}일 전'),
                  subtitle: Text('이상 행동 ${10 + index}건 감지'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getColorForObjectType(String type) {
    switch (type) {
      case '사람':
        return Colors.red;
      case '차량':
        return Colors.blue;
      case '자전거':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
} 