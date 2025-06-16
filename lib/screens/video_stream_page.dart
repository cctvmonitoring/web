import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/detection_box.dart';
import '../services/socket_service.dart';
import '../widgets/single_stream_widget.dart';

class MultiStreamPage extends StatefulWidget {
  const MultiStreamPage({super.key});

  @override
  State<MultiStreamPage> createState() => _MultiStreamPageState();
}

class _MultiStreamPageState extends State<MultiStreamPage> {
  final int streamCount = 9;

  final List<Uint8List?> _images = List.filled(9, null);
  final List<List<DetectionBox>> _boxesList = List.generate(9, (_) => []);
  final List<bool> _connectedList = List.filled(9, false);

  late SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService(
      onDataReceived: (image, boxes, connected, streamId) {
        final index = _streamNameToIndex(streamId);
        if (index == -1) return;

        setState(() {
          _images[index] = image;
          _boxesList[index] = boxes;
          _connectedList[index] = connected;
        });
      },
    );
    _socketService.connect();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  int _streamNameToIndex(String name) {
    final match = RegExp(r'stream(\d+)').firstMatch(name);
    if (match != null) {
      final n = int.parse(match.group(1)!);
      return (n - 1).clamp(0, streamCount - 1);
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // ✅ 배경 투명 처리
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: streamCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 16 / 9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (_, index) {
          return SingleStreamWidget(
            imageData: _images[index],
            boxes: _boxesList[index],
            connected: _connectedList[index],
          );
        },
      ),
    );
  }
}
