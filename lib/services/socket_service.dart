import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/detection_box.dart';

class SocketService {
  final Function(Uint8List?, List<DetectionBox>, bool connected, String streamId) onDataReceived;

  late IO.Socket _socket;
  Timer? _reconnectTimer;

  SocketService({required this.onDataReceived});

  void connect() {
    final url = 'http://localhost:5005'; // 현재 컴퓨터에서 실행
    print('🔌 Socket.IO 연결 시도: $url');

    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
      'timeout': 20000,
      'forceNew': true,
    });

    _socket.onConnect((_) {
      print('✅ Socket.IO connected successfully');
      _cancelReconnectTimer();
    });

    _socket.onConnectError((error) {
      print('❌ Socket.IO connection error: $error');
      onDataReceived(null, [], false, '');
      _scheduleReconnect();
    });

    _socket.onError((error) {
      print('❌ Socket.IO error: $error');
      onDataReceived(null, [], false, '');
    });

    _socket.onDisconnect((reason) {
      print('🔌 Socket.IO disconnected: $reason');
      onDataReceived(null, [], false, '');
      _scheduleReconnect();
    });

    // stream1 ~ stream9 구독
    for (int i = 1; i <= 9; i++) {
      final streamName = 'stream$i';
      _socket.on(streamName, (data) {
        print('📡 Received data for $streamName');
        _handleStream(data, streamName);
      });
    }

    _socket.connect();
  }

  void _scheduleReconnect() {
    _cancelReconnectTimer();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      print('🔄 Attempting to reconnect...');
      connect();
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _handleStream(dynamic data, String streamId) {
    try {
      print('🔄 Processing data for $streamId');
      final decoded = data;
      
      if (decoded['image'] == null) {
        print('❌ No image data in stream $streamId');
        onDataReceived(null, [], false, streamId);
        return;
      }
      
      final imageBytes = base64Decode(decoded['image']);
      print("📥 [${streamId}] 이미지 길이: ${imageBytes.length}, 디텍션 수: ${decoded['detections']?.length ?? 0}");
      
      final detections = <DetectionBox>[];
      if (decoded['detections'] != null) {
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
      }

      print('✅ Successfully processed data for $streamId: image=${imageBytes.length} bytes, detections=${detections.length}');
      onDataReceived(imageBytes, detections, true, streamId);
    } catch (e) {
      print('❌ Error processing data for $streamId: $e');
      onDataReceived(null, [], false, streamId);
    }
  }

  void disconnect() {
    print('🔌 Disconnecting Socket.IO');
    _cancelReconnectTimer();
    _socket.disconnect();
    _socket.dispose();
  }
} 