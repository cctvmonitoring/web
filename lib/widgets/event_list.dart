import 'package:flutter/material.dart';

class EventList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 예시용 더미 데이터
    final events = [
      {'title': '일정기간 심박없음', 'color': Colors.red, 'subtitle': '4층 410호, 2초 전'},
      {'title': '침대낙상위험 01', 'color': Colors.orange, 'subtitle': '4층 403호, 4초 전'},
      {'title': '휠체어 혼자 일어나기', 'color': Colors.orange, 'subtitle': '4층 413호, 8초 전'},
      {'title': '심박 하안선 이탈', 'color': Colors.blue, 'subtitle': '4층 411호, 10초 전'},
      {'title': '침대낙상위험 02', 'color': Colors.orange, 'subtitle': '4층 412호, 17초 전'},
    ];

    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          color: (event['color'] as Color).withOpacity(0.15),
          child: ListTile(
            leading: Icon(Icons.warning, color: event['color'] as Color),
            title: Text(event['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: event['color'] as Color)),
            subtitle: Text(event['subtitle'] as String),
            onTap: () {}, // 상세보기 등
          ),
        );
      },
    );
  }
}
