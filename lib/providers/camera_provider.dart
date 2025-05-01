import 'package:flutter/material.dart';

class CameraProvider with ChangeNotifier {
  int _activeCameraIndex = 0;
  int get activeCameraIndex => _activeCameraIndex;

  void setActiveCamera(int index) {
    _activeCameraIndex = index;
    notifyListeners();
  }
}