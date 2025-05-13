import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'history_video.dart';

/// 선택한 날짜의 이벤트 표시
class History extends StatelessWidget {
  final DateTime selectedDate;

  const History({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    // 선택한 날짜를 표시 형식으로 포맷팅
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('$formattedDate'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 24,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('$formattedDate $index시'),
            subtitle: Text('객체 탐지 개수 넣기'),
            onTap: () {
              // 선택한 날짜와 시간으로 History_video 페이지로 이동
              final selectedDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                index,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => History2(selectedDate: selectedDateTime),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
