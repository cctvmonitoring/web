import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/detection_box.dart';

class SocketService {
  final Function(Uint8List?, List<DetectionBox>, bool connected, String streamId) onDataReceived;

  late IO.Socket _socket;

  SocketService({required this.onDataReceived});

  void connect() {
    final url = 'http://localhost:3001'; // 현재 컴퓨터에서 실행

    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('✅ Socket.IO connected');
    });

    _socket.onError((_) => onDataReceived(null, [], false, ''));
    _socket.onConnectError((_) => onDataReceived(null, [], false, ''));

    // stream1 ~ stream9 구독
    for (int i = 1; i <= 9; i++) {
      final streamName = 'stream$i';
      _socket.on(streamName, (data) {
        _handleStream(data, streamName);
      });
    }

    _socket.connect();
  }

  void _handleStream(dynamic data, String streamId) {
    try {
      final decoded = data;
      final imageBytes = base64Decode(decoded['image']);
      print("📥 [${streamId}] 이미지 길이: ${decoded['image']?.length}, 디텍션 수: ${decoded['detections'].length}");
      final detections = <DetectionBox>[];
      //print("📦 [${streamId}] 수신된 데이터: $data");
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

      onDataReceived(imageBytes, detections, true, streamId);
    } catch (e) {
      onDataReceived(null, [], false, streamId);
    }
  }

  void disconnect() {
    _socket.disconnect();
    _socket.dispose();
  }
} 