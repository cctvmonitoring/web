import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/yolo_provider.dart';

class CameraTile extends StatelessWidget {
  final String roomName;
  final bool isAlert;

  const CameraTile({required this.roomName, this.isAlert = false, super.key});

  @override
  Widget build(BuildContext context) {
    final detections = context.select<YoloProvider, List<Map<String, dynamic>>>(
          (provider) => provider.getLatestDetections(roomName),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth;
        final tileHeight = constraints.maxHeight;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isAlert ? Colors.red : Colors.grey[700]!,
              width: isAlert ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // CCTV 영상 플레이스홀더
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.videocam, color: Colors.white54, size: 48),
                  ),
                ),
              ),

              // 객체 인식 결과 오버레이 (수정된 부분)
              ...detections.map((obj) {
                final bbox = obj['bbox'] as List<dynamic>;
                return Positioned(
                  left: tileWidth * bbox[0],
                  top: tileHeight * bbox[1],
                  width: tileWidth * (bbox[2] - bbox[0]),
                  height: tileHeight * (bbox[3] - bbox[1]),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Text(
                      obj['type'],
                      style: const TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                );
              }),

              // 상단 라벨
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    roomName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
