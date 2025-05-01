import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:provider/provider.dart';
import 'providers/camera_provider.dart';
import 'providers/yolo_provider.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(
    Portal(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CameraProvider()),
          ChangeNotifierProvider(create: (_) => YoloProvider()),
        ],
        child: MaterialApp(
          home: MainLayout(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCTV Monitoring',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
