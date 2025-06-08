import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/yolo_provider.dart';

const Map<String, Color> objectBoxColors = {
  'person': Colors.red,
  'dog': Colors.blue,
  'cat': Colors.green,
  'car': Colors.orange,
  'bird': Colors.purple,
  'bicycle': Colors.teal,
  'tree': Colors.brown,
  'motorcycle': Colors.pink,
};

class CameraTile extends StatelessWidget {
  final String roomName;
  final bool isAlert;
  final bool isFocused;

  const CameraTile({
    super.key,
    required this.roomName,
    this.isAlert = false,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    final detections = context.select<YoloProvider, List<Map<String, dynamic>>>(
          (provider) => provider.getLatestDetections(roomName),
    );

    // 사람이 감지되었는지 확인
    final hasPerson = detections.any((obj) => obj['type'] == 'person');
    
    // 사람이 감지되면 포커스 설정
    if (hasPerson) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<YoloProvider>(context, listen: false).setFocus(roomName);
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth;
        final tileHeight = constraints.maxHeight;

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: isAlert
                ? Border.all(color: Colors.red, width: 2)
                : isFocused
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
          ),
          child: Stack(
            children: [
              // 카메라 영상 (임시로 회색 배경)
              Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(
                    Icons.videocam,
                    size: 48,
                    color: Colors.white54,
                  ),
                ),
              ),
              // 객체 인식 결과 오버레이 (타입별 색상 적용)
              ...detections.map((obj) {
                final bbox = obj['bbox'] as List<dynamic>;
                final type = obj['type'] as String;
                final color = objectBoxColors[type] ?? Colors.grey;
                return Positioned(
                  left: tileWidth * bbox[0],
                  top: tileHeight * bbox[1],
                  width: tileWidth * (bbox[2] - bbox[0]),
                  height: tileHeight * (bbox[3] - bbox[1]),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor: color,
                      ),
                    ),
                  ),
                );
              }),
              // 카메라 정보
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    roomName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // 경고 표시
              if (isAlert)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.warning, color: Colors.red, size: 28),
                ),
            ],
          ),
        );
      },
    );
  }
}
