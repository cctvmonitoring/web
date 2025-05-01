import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/yolo_provider.dart';
import '../widgets/camera_grid.dart';
import '../widgets/camera_tile.dart';
import '../widgets/event_list.dart';

/// Main layout for the app, including navigation rail and main content area.
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // 현재 선택된 NavigationRail 인덱스
  bool isCalendarOpen = false; // 캘린더 팝업 표시 여부

  @override
  void initState() {
    super.initState();
    // [테스트용] 5초 후 더미 카메라 데이터 추가
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final provider = Provider.of<YoloProvider>(context, listen: false);
        provider.addDetection(
          YoloDetection(
            camId: '401호',
            objects: [
              {'type': 'person', 'bbox': [0.2, 0.3, 0.5, 0.6]},
              {'type': 'person', 'bbox': [0.4, 0.4, 0.7, 0.8]},
            ],
          ),
        );
        // 여러 카메라를 테스트하려면 아래처럼 추가
        // provider.addDetection(YoloDetection(camId: '402호', objects: [...]));
      }
    });
  }

  /// 캘린더 버튼 클릭 시 호출: 캘린더 팝업 열기/닫기
  void _toggleCalendar() {
    setState(() => isCalendarOpen = !isCalendarOpen);
  }

  @override
  Widget build(BuildContext context) {
    final yoloProvider = Provider.of<YoloProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // 좌측 네비게이션 레일
              NavigationRail(
                minWidth: 120,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) =>
                    setState(() => _selectedIndex = index),
                backgroundColor: const Color(0xFF2A312A),
                labelType: NavigationRailLabelType.all,
                // 상단 보안 아이콘
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.security, color: Colors.blueGrey[900]),
                  ),
                ),
                // 하단 캘린더 버튼 (PortalTarget으로 팝업 위치 제어)
                trailing: PortalTarget(
                  anchor: const Aligned(
                    follower: Alignment.bottomCenter, // 캘린더 하단을 버튼 상단에 맞춤
                    target: Alignment.topCenter,
                    offset: Offset(0, -10), // 버튼과 캘린더 사이 여백
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: IconButton(
                        icon: Icon(Icons.calendar_month, color: Colors.blueGrey[900]),
                        onPressed: _toggleCalendar,
                      ),
                    ),
                  ),
                ),
                // 네비게이션 메뉴
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
              // 우측 메인 컨텐츠
              Expanded(
                child: Column(
                  children: [
                    // 상단 필터/액션 바
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
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('비디오와 알람'),
                          ),
                        ],
                      ),
                    ),
                    // 메인 컨텐츠 영역 (CCTV/알람/설정)
                    Expanded(
                      child: Row(
                        children: [
                          // CCTV 그리드
                          if (_selectedIndex == 0)
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CameraGrid(),
                              ),
                            ),
                          // 알람 리스트
                          if (_selectedIndex == 1)
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: EventList(),
                              ),
                            ),
                          // 설정/기타 화면
                          if (_selectedIndex != 0 && _selectedIndex != 1)
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    '설정 화면 ',
                                    style: TextStyle(fontSize: 24, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          // 우측 여백
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 카메라 확대 팝업 오버레이
          if (yoloProvider.focusedCamId != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => yoloProvider.clearFocus(),
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 600,
                        height: 400,
                        child: Stack(
                          children: [
                            CameraTile(roomName: yoloProvider.focusedCamId!),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => yoloProvider.clearFocus(),
                              ),
                            ),
                          ],
                        ),
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
}
