import 'package:flutter/material.dart';

// 카메라 화면 모달 위젯
class CameraView extends StatelessWidget {
  final String cameraId;
  const CameraView({super.key, required this.cameraId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 300,
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: Text(
              cameraId,
              style: const TextStyle(color: Colors.white, fontSize: 32),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop(); // 모달 닫기
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 더미 이벤트 데이터
class DummyEvent {
  final String cameraId;
  final String message;
  DummyEvent({required this.cameraId, required this.message});
}

// 알람 데모 위젯
class AlarmDemoWidget extends StatelessWidget {
  const AlarmDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
