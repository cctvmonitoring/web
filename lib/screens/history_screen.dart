import 'package:flutter/material.dart';

class History extends StatelessWidget {
  final DateTime selectedDate;

  const History({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 기록'),
      ),
      body: ListView.builder(
        itemCount: 10, // 임시 데이터
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.videocam),
            title: Text('카메라 ${400 + index}호'),
            subtitle: Text('${selectedDate.hour}:${selectedDate.minute} - 이벤트 발생'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 상세 보기 화면으로 이동
            },
          );
        },
      ),
    );
  }
} 