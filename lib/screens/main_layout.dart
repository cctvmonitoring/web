import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/yolo_provider.dart';
import '../widgets/camera_grid.dart';
import '../widgets/camera_tile.dart';
import '../widgets/event_list.dart';
import '../widgets/dashboard_widget.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool isCalendarOpen = false;

  @override
  @override
  void initState() {
    super.initState();

    // 초기 더미 데이터 설정 (1초 후)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final provider = Provider.of<YoloProvider>(context, listen: false);

        // 모든 카메라 초기화 (객체 없음)
        for (int i = 1; i <= 16; i++) {
          provider.addDetection(
            YoloDetection(
              camId: '${400 + i}호',
              objects: [], // 빈 객체 리스트로 초기화
            ),
          );
        }

        // 카메라별 객체 설정
        // 404호: 사람 (빨간색)
        provider.addDetection(
          YoloDetection(
            camId: '404호',
            objects: [
              {'type': 'person', 'bbox': [0.2, 0.2, 0.5, 0.5]},
            ],
          ),
        );

        // 405호: 강아지 (파란색)
        provider.addDetection(
          YoloDetection(
            camId: '405호',
            objects: [
              {'type': 'dog', 'bbox': [0.3, 0.3, 0.6, 0.6]},
            ],
          ),
        );

        // 406호: 고양이 (녹색)
        provider.addDetection(
          YoloDetection(
            camId: '406호',
            objects: [
              {'type': 'cat', 'bbox': [0.25, 0.25, 0.55, 0.55]},
            ],
          ),
        );

        // 407호: 자동차 (주황색)
        provider.addDetection(
          YoloDetection(
            camId: '407호',
            objects: [
              {'type': 'car', 'bbox': [0.1, 0.1, 0.7, 0.5]},
            ],
          ),
        );

        // 408호: 새 (보라색)
        provider.addDetection(
          YoloDetection(
            camId: '408호',
            objects: [
              {'type': 'bird', 'bbox': [0.4, 0.3, 0.6, 0.45]},
            ],
          ),
        );

        // 410호: 자전거 (청록색)
        provider.addDetection(
          YoloDetection(
            camId: '410호',
            objects: [
              {'type': 'bicycle', 'bbox': [0.2, 0.15, 0.8, 0.65]},
            ],
          ),
        );

        // 8초 후 객체 감지 종료 (사람 제거)
        Future.delayed(const Duration(seconds: 7), () {
          if (mounted) {
            provider.clearFocus(); // 포커스 제거
          }
        });
      }
    });
  }

  void _toggleCalendar() => setState(() => isCalendarOpen = !isCalendarOpen);

  @override
  Widget build(BuildContext context) {
    final yoloProvider = Provider.of<YoloProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              NavigationRail(
                minWidth: 120,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) =>
                    setState(() => _selectedIndex = index),
                backgroundColor: const Color(0xFF2A312A),
                labelType: NavigationRailLabelType.all,
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.security, color: Colors.blueGrey),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.videocam),
                    label: Text('CCTV', style: TextStyle(color: Colors.white)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.notifications),
                    label: Text('알람', style: TextStyle(color: Colors.white)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('설정', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    const DashboardWidget(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          DropdownButton<String>(
                            value: '주요시설(작업그룹)',
                            items: const [
                              DropdownMenuItem(
                                value: '주요시설(작업그룹)',
                                child: Text('주요시설(작업그룹)'),
                              ),
                            ],
                            onChanged: (_) {},
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('비디오와 알람'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildMainContent(yoloProvider),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            bottom: 24,
            child: SizedBox(
              width: 120,
              child: PortalTarget(
                anchor: const Aligned(
                  follower: Alignment.bottomCenter,
                  target: Alignment.topCenter,
                  offset: Offset(0, -10),
                ),
                visible: isCalendarOpen,
                portalFollower: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 250,
                    height: 200,
                    child: TableCalendar(
                      firstDay: DateTime.utc(2010),
                      lastDay: DateTime.utc(2030),
                      focusedDay: DateTime.now(),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      onDaySelected: (_, __) =>
                          setState(() => isCalendarOpen = false),
                    ),
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.calendar_month, color: Colors.blueGrey),
                      onPressed: _toggleCalendar,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(YoloProvider yoloProvider) {
    if (_selectedIndex == 0) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: yoloProvider.focusedCamId != null
            ? _buildFocusedLayout(context, yoloProvider.focusedCamId!)
            :  CameraGrid(),
      );
    }
    return _selectedIndex == 1
        ?  EventList()
        : const Center(child: Text('설정 화면'));
  }

  Widget _buildFocusedLayout(BuildContext context, String focusedCamId) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 비율 계산 (16:9 비율로 고정)
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        // 중앙 영역 비율 (전체의 60%)
        double centerWidth = width * 0.6;
        double centerHeight = height * 0.6;

        // 주변 카메라 크기 계산 (위/아래는 너비 조정, 좌/우는 높이 조정)
        double sideWidth = width * 0.18;  // 좌우 카메라 너비 (18%)
        double sideHeight = centerHeight; // 좌우 카메라 높이 (중앙 높이와 동일)

        double topBottomWidth = centerWidth; // 상하 카메라 너비 (중앙 너비와 동일)
        double topBottomHeight = height * 0.18; // 상하 카메라 높이 (18%)

        return Stack(
          children: [
            // 상단 카메라들
            Positioned(
              top: 0,
              left: (width - topBottomWidth) / 2,
              width: topBottomWidth,
              height: topBottomHeight,
              child: Row(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CameraTile(roomName: '${400 + index}호'),
                    ),
                  ),
                ),
              ),
            ),

            // 좌측 카메라들
            Positioned(
              top: topBottomHeight + 8,
              left: 0,
              width: sideWidth,
              height: sideHeight,
              child: Column(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CameraTile(roomName: '${403 + index}호'),
                    ),
                  ),
                ),
              ),
            ),

            // 우측 카메라들
            Positioned(
              top: topBottomHeight + 8,
              right: 0,
              width: sideWidth,
              height: sideHeight,
              child: Column(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CameraTile(roomName: '${406 + index}호'),
                    ),
                  ),
                ),
              ),
            ),

            // 하단 카메라들
            Positioned(
              bottom: 0,
              left: (width - topBottomWidth) / 2,
              width: topBottomWidth,
              height: topBottomHeight,
              child: Row(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CameraTile(roomName: '${409 + index}호'),
                    ),
                  ),
                ),
              ),
            ),

            // 중앙 확대 카메라
            Center(
              child: Container(
                width: centerWidth,
                height: centerHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CameraTile(
                  roomName: focusedCamId,
                  isAlert: true,
                ),
              ),
            ),

            // 상단 알림 라벨
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🚨 사람 탐지: $focusedCamId',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
