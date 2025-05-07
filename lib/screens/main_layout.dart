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
  void initState() {
    super.initState();
    // 16개 카메라 더미 데이터 추가 (객체 타입 다양화)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final provider = Provider.of<YoloProvider>(context, listen: false);
        for (int i = 1; i <= 16; i++) {
          List<Map<String, dynamic>> objects = [];
          String objectType;
          if (i <= 3) {
            objectType = 'person';
          } else if (i == 4) {
            objectType = 'dog';
          } else if (i == 5) {
            objectType = 'cat';
          } else {
            final otherTypes = ['car', 'bird', 'bicycle', 'tree', 'motorcycle'];
            objectType = otherTypes[(i - 6) % otherTypes.length];
          }
          objects.add({
            'type': objectType,
            'bbox': [
              0.1 * (i % 3),
              0.1 * (i % 4),
              0.3 + 0.05 * (i % 2),
              0.5 + 0.05 * (i % 2)
            ],
          });
          provider.addDetection(
            YoloDetection(
              camId: '${400 + i}호',
              objects: objects,
            ),
          );
        }
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
              // NavigationRail에서 trailing 사용하지 않음!
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
              // 우측 메인 컨텐츠
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                           DropdownButton<String>(
                            value: '주요시설(작업그룹)',
                            items: [DropdownMenuItem(value: '주요시설(작업그룹)', child: Text('주요시설(작업그룹)'))],
                            onChanged: null,
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('비디오와 알람'),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedIndex == 0) const DashboardWidget(),
                    Expanded(
                      child: Row(
                        children: [
                          if (_selectedIndex == 0)
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CameraGrid(),
                              ),
                            ),
                          if (_selectedIndex == 1)
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: EventList(),
                              ),
                            ),
                          if (_selectedIndex != 0 && _selectedIndex != 1)
                            const Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: Text('설정 화면', style: TextStyle(fontSize: 24, color: Colors.grey))),
                              ),
                            ),
                          const Expanded(flex: 1, child: SizedBox()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 캘린더 버튼만 NavigationRail의 바닥에 고정
          Positioned(
            left: 0,
            bottom: 24, // 레일 바닥에서의 여백 조절
            child: SizedBox(
              width: 120, // NavigationRail의 minWidth와 맞춤
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
                      onDaySelected: (_, __) => setState(() => isCalendarOpen = false),
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
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: CloseButton(color: Colors.white),
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
