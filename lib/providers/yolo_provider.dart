import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class YoloDetection {
  final String camId;
  final List<Map<String, dynamic>> objects;

  YoloDetection({
    required this.camId,
    required this.objects,
  });

  factory YoloDetection.fromJson(Map<String, dynamic> json) {
    return YoloDetection(
      camId: json['camId'] as String,
      objects: (json['objects'] as List).cast<Map<String, dynamic>>(),
    );
  }
}

class YoloProvider with ChangeNotifier {
  List<YoloDetection> _detections = [];
  String? _focusedCamera;
  bool _isDialogShowing = false;

  // 게터
  List<YoloDetection> get detections => _detections;
  String? get focusedCamera => _focusedCamera;
  bool get isDialogShowing => _isDialogShowing;

  // 새로운 cameraIds 게터 추가
  List<String> get cameraIds => _detections
      .map((detection) => detection.camId)
      .toSet() // 중복 제거
      .toList();

  // 사람만 감지되었을 때 포커스
  void addDetection(YoloDetection detection) {
    final index = _detections.indexWhere((d) => d.camId == detection.camId);
    if (index != -1) {
      _detections[index] = detection;
    } else {
      _detections.add(detection);
    }
    notifyListeners();
  }

  // 게터로 정의
  int get countPersonDetections {
    int count = 0;
    for (var detection in _detections) {
      count += detection.objects.where((o) => o['type'] == 'person').length;
    }
    return count;
  }

  void setFocus(String? camId) {
    _focusedCamera = camId;
    notifyListeners();
  }

  void clearFocus() {
    _focusedCamera = null;
    notifyListeners();
  }

  void setDialogStatus(bool showing) {
    _isDialogShowing = showing;
    notifyListeners();
  }

  List<Map<String, dynamic>> getLatestDetections(String camId) {
    final detection = _detections.lastWhere(
          (d) => d.camId == camId,
      orElse: () => YoloDetection(camId: camId, objects: []),
    );
    return detection.objects;
  }
}
