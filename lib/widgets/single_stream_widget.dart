import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/detection_box.dart';
import 'detection_overlay.dart';

class SingleStreamWidget extends StatelessWidget {
  final Uint8List? imageData;
  final List<DetectionBox> boxes;
  final bool connected;

  const SingleStreamWidget({
    super.key,
    required this.imageData,
    required this.boxes,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    const originalWidth = 1920.0;
    const originalHeight = 1080.0;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: !connected || imageData == null
          ? Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: const Text(
                '📡 No Signal',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  children: [
                    Image.memory(
                      imageData!,
                      gaplessPlayback: true,
                      fit: BoxFit.cover,
                      width: width,
                      height: height,
                    ),
                    DetectionOverlay(
                      boxes: boxes,
                      imageWidth: originalWidth,
                      imageHeight: originalHeight,
                      renderWidth: width,
                      renderHeight: height,
                    ),
                  ],
                );
              },
            ),
    );
  }
} 