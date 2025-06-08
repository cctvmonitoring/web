import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/yolo_provider.dart';
import 'camera_tile.dart';

class CameraGrid extends StatelessWidget {
  const CameraGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final yoloProvider = Provider.of<YoloProvider>(context);
    final focused = yoloProvider.focusedCamera;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: yoloProvider.detections.length,
      itemBuilder: (context, index) {
        final detection = yoloProvider.detections[index];
        return CameraTile(
          roomName: detection.camId,
          isAlert: detection.objects.isNotEmpty,
          isFocused: detection.camId == focused,
        );
      },
    );
  }
}
