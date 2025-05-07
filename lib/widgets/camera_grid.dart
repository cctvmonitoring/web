import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/yolo_provider.dart';
import 'camera_tile.dart';

class CameraGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final yoloProvider = Provider.of<YoloProvider>(context);
    final cameras = yoloProvider.cameraIds;
    final focused = yoloProvider.focusedCamId;

    if (focused != null) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CameraTile(roomName: focused, isAlert: true),
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 16 / 9,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final id = cameras.where((id) => id != focused).elementAt(index);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CameraTile(roomName: id),
                );
              },
              childCount: cameras.length - 1,
            ),
          ),
        ],
      );
    } else {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 16 / 9,
        ),
        itemCount: cameras.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: CameraTile(roomName: cameras[index]),
        ),
      );
    }
  }
}
