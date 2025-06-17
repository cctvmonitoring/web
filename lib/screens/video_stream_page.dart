import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
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
        if (index == -1) {
        print("❌ 인덱스 변환 실패: streamId=$streamId → 위젯 렌더링 안 됨");
        return;
        }

        setState(() {
          _images[index] = image;
          _boxesList[index] = boxes;
          _connectedList[index] = connected;
          print("✅ 데이터 전달: image=${image?.length}, boxes=${boxes.length}, connected=$connected, streamId=$streamId");
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
    //print("📡 수신된 streamId: $name");
    final match = RegExp(r'stream(\d+)').firstMatch(name);
    if (match != null) {
      final n = int.parse(match.group(1)!);
      //print("🔢 streamId $name → index ${n - 1}");
      return (n - 1).clamp(0, streamCount - 1);
    }
    print("❌ streamId 변환 실패: $name");
    return -1;
  }

  void _handleStream(dynamic data, String streamId) {
    try {
      final decoded = data;
      print("📦 [${streamId}] 수신된 데이터: $decoded");

      final imageBytes = base64Decode(decoded['image']);
      print("📥 [${streamId}] 디코딩된 이미지 길이: ${imageBytes.length}");

      final detections = <DetectionBox>[];
      for (var det in decoded['detections']) {
        final rect = Rect.fromLTRB(
          det['bbox'][0].toDouble(),
          det['bbox'][1].toDouble(),
          det['bbox'][2].toDouble(),
          det['bbox'][3].toDouble(),
        );
        detections.add(
          DetectionBox(det['class_id'], det['confidence'].toDouble(), rect),
        );
      }
      print("📥 [${streamId}] 디텍션 수: ${detections.length}");

      onDataReceived(imageBytes, detections, true, streamId);
    } catch (e) {
      print("❌ 데이터 처리 실패: $e");
      onDataReceived(null, [], false, streamId);
    }
  }

  void onDataReceived(Uint8List? image, List<DetectionBox> boxes, bool connected, String streamId) {
    final index = _streamNameToIndex(streamId);
    if (index == -1) {
      print("❌ 인덱스 변환 실패: streamId=$streamId → 위젯 렌더링 안 됨");
      return;
    }

    setState(() {
      _images[index] = image;
      _boxesList[index] = boxes;
      _connectedList[index] = connected;
      print("✅ 데이터 전달: image=${image?.length}, boxes=${boxes.length}, connected=$connected, streamId=$streamId");
    });
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
            imageData: _images[index], // ✅ 수정된 부분
            boxes: _boxesList[index],
            connected: _connectedList[index],
          );
        },
      ),
    );
  }
}
