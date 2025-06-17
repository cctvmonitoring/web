// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class YoloSocketService {
//   final WebSocketChannel channel;

//   YoloSocketService(String url)
//       : channel = WebSocketChannel.connect(Uri.parse(url));

//   Stream<Map<String, dynamic>> get detectionStream =>
//       channel.stream.map((event) => jsonDecode(event));
// }
