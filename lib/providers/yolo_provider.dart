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
  bool _isDialogShowing = false;
  String? _focusedCamId;

  List<String> get cameraIds =>
      _detections.map((d) => d.camId).toSet().toList();

  List<YoloDetection> get detections => _detections;
  bool get isDialogShowing => _isDialogShowing;
  String? get focusedCamId => _focusedCamId;

  bool get shouldShowAlert {
    return _detections.any((d) =>
    d.objects.where((o) => o['type'] == 'person').length >= 2
    );
  }
   int countPersonDetections() {
    int count = 0;
    for (var detection in _detections) {
      count += detection.objects.where((obj) => obj['type'] == 'person').length;
    }
    return count;
   }
  void setDialogStatus(bool showing) {
    _isDialogShowing = showing;
    notifyListeners();
  }

  void addDetection(YoloDetection detection) {
    _detections = [..._detections, detection];
    if (detection.objects.any((o) => o['type'] == 'person')) {
      _focusedCamId = detection.camId;
    }
    notifyListeners();
  }

  void clearFocus() {
    _focusedCamId = null;
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
