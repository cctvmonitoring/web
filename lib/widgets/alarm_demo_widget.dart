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
class AlarmDemoWidget extends StatefulWidget {
  const AlarmDemoWidget({super.key});

  @override
  State<AlarmDemoWidget> createState() => _AlarmDemoWidgetState();
}

class _AlarmDemoWidgetState extends State<AlarmDemoWidget> {
  bool _hasShownEvent = false; // 최초 자동 팝업 제어

  // 객체 인지 이벤트(더미) 발생 함수
  void triggerDetectionEvent() {
    final event = DummyEvent(
      cameraId: 'cam401',
      message: '401호에서 이상행동 감지!',
    );
    _showCameraModal(event);
  }

  @override
  void initState() {
    super.initState();
    // 앱 실행 후 12초 뒤에 한 번만 자동 팝업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 12), () {
        if (!_hasShownEvent) {
          _hasShownEvent = true;
          triggerDetectionEvent();
        }
      });
    });
  }

  // 카메라 확대 모달(팝업)
  void _showCameraModal(DummyEvent event) {
    showDialog(
      context: context,
      barrierDismissible: true, // 바깥 클릭 시 닫힘
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: CameraView(cameraId: event.cameraId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 버튼 없이 빈 위젯만 반환
    return const SizedBox.shrink();
  }
}
