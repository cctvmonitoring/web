import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/yolo_provider.dart';

class DummyDataService {
  static void setupDummyData(BuildContext context) {
    final provider = Provider.of<YoloProvider>(context, listen: false);

    // 400~415호 카메라 더미 데이터 생성
    for (int i = 1; i <= 16; i++) {
      provider.addDetection(
        YoloDetection(
          camId: '${400 + i}호',
          objects: [],
        ),
      );
    }

    // 각 카메라별 객체 감지 더미 데이터 추가
    _addDummyDetections(provider);

    // 7초 후 포커스 해제
    Future.delayed(const Duration(seconds: 7), () {
      if (context.mounted) {
        provider.clearFocus();
      }
    });
  }

  static void _addDummyDetections(YoloProvider provider) {
    final detections = [
      {'camId': '404호', 'type': 'person', 'bbox': [0.2, 0.2, 0.5, 0.5]},
      {'camId': '405호', 'type': 'dog', 'bbox': [0.3, 0.3, 0.6, 0.6]},
      {'camId': '406호', 'type': 'cat', 'bbox': [0.25, 0.25, 0.55, 0.55]},
      {'camId': '407호', 'type': 'car', 'bbox': [0.1, 0.1, 0.7, 0.5]},
      {'camId': '408호', 'type': 'bird', 'bbox': [0.4, 0.3, 0.6, 0.45]},
      {'camId': '410호', 'type': 'bicycle', 'bbox': [0.2, 0.15, 0.8, 0.65]},
    ];

    for (final detection in detections) {
      provider.addDetection(
        YoloDetection(
          camId: detection['camId'] as String,
          objects: [
            {
              'type': detection['type'],
              'bbox': detection['bbox'],
            },
          ],
        ),
      );
    }
  }
} 