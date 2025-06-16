import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/yolo_provider.dart';
import '../widgets/camera_grid.dart';
import '../widgets/camera_tile.dart';
import '../widgets/event_list.dart';
import '../widgets/history_list.dart';
import '../widgets/settings_widget.dart';
import '../widgets/dashboard_widget.dart';
import '../widgets/alarm_demo_widget.dart';
import '../widgets/map_view.dart';
import '../widgets/analytics_view.dart';
import '../widgets/management_view.dart';
import 'video_stream_page.dart';

/// CCTV 메인 레이아웃 화면 (NavigationRail + 메인 컨텐츠)
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // 현재 선택된 NavigationRail 인덱스
  // 0: CCTV, 1: 알람, 2: 대시보드, 3: 지도, 4: 분석, 5: 관리, 6: 설정
  int _selectedIndex = 0;

  // 캘린더 모달 높이
  double calendarHeight = 400;

  // 캘린더 모달 열림 여부
  bool isCalendarOpen = false;

  // 시스템 상태 정보
  final Map<String, String> _systemStatus = {
    '서버': '정상',
    '네트워크': '정상',
    '카메라': '정상',
    '저장공간': '정상',
  };

  // 날씨 정보
  final Map<String, dynamic> _weatherInfo = {
    'condition': '맑음',
    'temperature': 23,
    'humidity': 45,
  };

  /// 캘린더 버튼 클릭 시 열림/닫힘 토글
  void _toggleCalendar() {
    setState(() {
      isCalendarOpen = !isCalendarOpen;
    });
  }

  /// 더미 데이터 및 초기 상태 세팅
  @override
  void initState() {
    super.initState();
    // 앱 시작 3초 후 더미 카메라 데이터 및 객체 감지 데이터 셋업
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final provider = Provider.of<YoloProvider>(context, listen: false);

        // 400~415호 카메라 더미 데이터 생성
        for (int i = 1; i <= 16; i++) {
          provider.addDetection(
            YoloDetection(
              camId: '${400 + i}호',
              objects: [],
            ),
          );
        }

        // 각 카메라별 객체 감지 더미 데이터 추가 (사람, 동물 등)
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

        // 7초 후 포커스 해제 (사람 감지 상태 해제)
        Future.delayed(const Duration(seconds: 7), () {
          if (mounted) {
            provider.clearFocus();
          }
        });
      }
    });
  }

  /// 캘린더 모달 다이얼로그 오픈
  void _showCalendarModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 달력 위젯
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
                    // 날짜 선택 시 모달 닫기
                    Navigator.of(context).pop();
                    // History 화면으로 이동 
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => History(selectedDate: selectedDay),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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

  /// 메인 빌드 함수
  @override
  Widget build(BuildContext context) {
    final yoloProvider = Provider.of<YoloProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          '보안관제 시스템',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
      ),
      body: Row(
        children: [
          NavigationRail(
            minWidth: 120,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) =>
                setState(() => _selectedIndex = index),
            backgroundColor: const Color(0xFF1A1A1A),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF2C2C2C),
                child: Icon(Icons.security, color: Colors.grey[400]),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.videocam_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.videocam, color: Colors.white),
                label: Text('CCTV', style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.notifications, color: Colors.white),
                label: Text('알람', style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.dashboard, color: Colors.white),
                label: Text('대시보드', style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.map_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.map, color: Colors.white),
                label: Text('지도', style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.analytics, color: Colors.white),
                label: Text('분석', style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.admin_panel_settings_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.admin_panel_settings, color: Colors.white),
                label: Text('관리', style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.settings, color: Colors.white),
                label: Text('설정', style: TextStyle(color: Colors.white)),
              ),
            ],
            trailing: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF2C2C2C),
                  radius: 25,
                  child: IconButton(
                    icon: Icon(Icons.calendar_month, color: Colors.grey[400]),
                    onPressed: () => _showCalendarModal(context),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF2C2C2C),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[800]!),
                          ),
                          child: DropdownButton(
                            value: '주요시설(작업그룹)',
                            items: const [
                              DropdownMenuItem(
                                value: '주요시설(작업그룹)',
                                child: Text(
                                  '주요시설(작업그룹)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (_) {},
                            dropdownColor: const Color(0xFF1A1A1A),
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A1A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey[800]!),
                              ),
                            ),
                            child: const Text(
                              '비디오와 알람',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
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
                              child: yoloProvider.focusedCamera != null
                                  ? _buildFocusedLayout(context, yoloProvider.focusedCamera!)
                                  : CameraGrid(),
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
                              child: DashboardWidget(),
                            ),
                          ),
                        if (_selectedIndex == 3)
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MapView(),
                            ),
                          ),
                        if (_selectedIndex == 4)
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AnalyticsView(),
                            ),
                          ),
                        if (_selectedIndex == 5)
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ManagementView(),
                            ),
                          ),
                        if (_selectedIndex == 6)
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SettingsWidget(),
                            ),
                          ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CCTV 화면에서 포커스된 카메라가 있을 때의 레이아웃
  Widget _buildFocusedLayout(BuildContext context, String focusedCamId) {
    return const MultiStreamPage();
  }

  // 시스템 상태 아이템 위젯
  Widget _buildStatusItem(String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == '정상' ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == '정상' ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 시스템 상태 다이얼로그
  void _showSystemStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('시스템 상태'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusItem('서버', _systemStatus['서버']!),
            _buildStatusItem('네트워크', _systemStatus['네트워크']!),
            _buildStatusItem('카메라', _systemStatus['카메라']!),
            _buildStatusItem('저장공간', _systemStatus['저장공간']!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
