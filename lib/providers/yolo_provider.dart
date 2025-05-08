import 'package:flutter/material.dart';

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

class YoloProvider extends ChangeNotifier {
  List<YoloDetection> _detections = [];
  String? _focusedCamId;
  bool _isDialogShowing = false;

  // 게터
  List<YoloDetection> get detections => _detections;
  String? get focusedCamId => _focusedCamId;
  bool get isDialogShowing => _isDialogShowing;

  // 새로운 cameraIds 게터 추가
  List<String> get cameraIds => _detections
      .map((detection) => detection.camId)
      .toSet() // 중복 제거
      .toList();

  // 사람만 감지되었을 때 포커스
  void addDetection(YoloDetection detection) {
    _detections = [..._detections, detection];

    // 사람이 감지된 카메라만 포커스
    if (detection.objects.any((o) => o['type'] == 'person')) {
      _focusedCamId = detection.camId;
    }
    notifyListeners();
  }

  // 게터로 정의 (괄호 제거)
  int get countPersonDetections {
    int count = 0;
    for (var detection in _detections) {
      count += detection.objects.where((o) => o['type'] == 'person').length;
    }
    return count;
  }



  void clearFocus() {
    _focusedCamId = null;
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
