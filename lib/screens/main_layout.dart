import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/yolo_provider.dart';
import '../widgets/camera_grid.dart';
import '../widgets/camera_tile.dart';
import '../widgets/event_list.dart';
import '../widgets/settings_widget.dart'; // SettingsWidget import 추가
import '../widgets/dashboard_widget.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // 현재 선택된 NavigationRail 인덱스


  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final provider = Provider.of<YoloProvider>(context, listen: false);

        // 모든 카메라 초기화
        for (int i = 1; i <= 16; i++) {
          provider.addDetection(
            YoloDetection(
              camId: '${400 + i}호',
              objects: [],
            ),
          );
        }

        // 카메라별 객체 설정
        provider.addDetection(
          YoloDetection(
            camId: '404호',
            objects: [
              {'type': 'person', 'bbox': [0.2, 0.2, 0.5, 0.5]},
            ],
          ),
        );
        provider.addDetection(
          YoloDetection(
            camId: '405호',
            objects: [
              {'type': 'dog', 'bbox': [0.3, 0.3, 0.6, 0.6]},
            ],
          ),
        );
        provider.addDetection(
          YoloDetection(
            camId: '406호',
            objects: [
              {'type': 'cat', 'bbox': [0.25, 0.25, 0.55, 0.55]},
            ],
          ),
        );
        provider.addDetection(
          YoloDetection(
            camId: '407호',
            objects: [
              {'type': 'car', 'bbox': [0.1, 0.1, 0.7, 0.5]},
            ],
          ),
        );
        provider.addDetection(
          YoloDetection(
            camId: '408호',
            objects: [
              {'type': 'bird', 'bbox': [0.4, 0.3, 0.6, 0.45]},
            ],
          ),
        );
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
            provider.clearFocus();
          }
        });
      }
    });
  }

  /// 캘린더 모달을 열기 위한 메서드
  void _showCalendarModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // 화면 크기에 맞게 너비 조정
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010),
                  lastDay: DateTime.utc(2030),
                  focusedDay: DateTime.now(),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    // 날짜 선택 시 동작 추가 가능
                    Navigator.of(context).pop(); // 모달 닫기
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 닫기 버튼
                  },
                  child: const Text('닫기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final yoloProvider = Provider.of<YoloProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CCTV 관리'),
      ),
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
               leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.security, color: Colors.blueGrey[900]),
                  ),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: IconButton(
                      icon: Icon(Icons.calendar_month, color: Colors.blueGrey[900]),
                      onPressed: () => _showCalendarModal(context),
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
                          if (_selectedIndex == 2)
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const SettingsWidget(),
                              ),
                            ),
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
                        width: 250,
                        height: calendarHeight,
                        child: SingleChildScrollView(
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
                    );
                  },
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
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        double centerWidth = width * 0.6;
        double centerHeight = height * 0.6;
        double sideWidth = width * 0.18;
        double sideHeight = centerHeight;
        double topBottomWidth = centerWidth;
        double topBottomHeight = height * 0.18;

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

