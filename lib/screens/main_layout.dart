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


/// CCTV 메인 레이아웃 화면 (NavigationRail + 메인 컨텐츠)
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // 현재 선택된 NavigationRail 인덱스 (0: CCTV, 1: 알람, 2: 설정)
  int _selectedIndex = 0;

  // 캘린더 모달 높이
  double calendarHeight = 400;

  // 캘린더 모달 열림 여부
  bool isCalendarOpen = false;

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
    // 앱 시작 1초 후 더미 카메라 데이터 및 객체 감지 데이터 셋업
    Future.delayed(const Duration(seconds: 1), () {
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
    // 객체 감지/포커스 등 상태 관리용 Provider
    final yoloProvider = Provider.of<YoloProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CCTV 관리'),
      ),
      body: Stack(
        children: [
          // 좌측 NavigationRail + 우측 메인 컨텐츠
          Row(
            children: [
              // 좌측 NavigationRail (네비/설정/캘린더)
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
                // 네비게이션 메뉴 (CCTV/알람/설정)
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
                    icon: Icon(Icons.dashboard),
                    label: Text('대시보드', style: TextStyle(color: Colors.white)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('설정', style: TextStyle(color: Colors.white)),
                  ),
                  ],
                // 캘린더 버튼을 NavigationRail 맨 하단에 고정
                trailing: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: IconButton(
                        icon: Icon(Icons.calendar_month, color: Colors.blueGrey[900]),
                        onPressed: () => _showCalendarModal(context),
                      ),
                    ),
                  ),
                ),
              ),
              // 우측 메인 컨텐츠 영역
              Expanded(
                child: Column(
                  children: [
                    // 상단 필터/버튼 영역
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          DropdownButton(
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
                    // 실제 CCTV/알람/설정 화면
                    Expanded(
                      child: Row(
                        children: [
                          // CCTV 화면
                          if (_selectedIndex == 0)
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CameraGrid(),
                              ),
                            ),
                          // 알람 화면
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
                          // 설정 화면
                          if (_selectedIndex == 3)
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SettingsWidget(),
                              ),
                            ),

                          // 우측 빈 공간 (레이아웃 정렬용)
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
              const AlarmDemoWidget(),
            ],
          ),
          // 사람이 감지된 카메라가 있으면 팝업 오버레이로 확대 표시
          // if (yoloProvider.focusedCamId != null)
          //   Positioned.fill(
          //     child: GestureDetector(
          //       onTap: () => yoloProvider.clearFocus(),
          //       child: Container(
          //         color: Colors.black54,
          //         child: Center(
          //           child: Material(
          //             elevation: 8,
          //             borderRadius: BorderRadius.circular(12),
          //             child: SizedBox(
          //               width: 250,
          //               height: calendarHeight,
          //               child: SingleChildScrollView(
          //                 child: TableCalendar(
          //                   firstDay: DateTime.utc(2010),
          //                   lastDay: DateTime.utc(2030),
          //                   focusedDay: DateTime.now(),
          //                   headerStyle: const HeaderStyle(
          //                     formatButtonVisible: false,
          //                     titleCentered: true,
          //                   ),
          //                   onDaySelected: (selectedDay, focusedDay) {
          //                     setState(() => isCalendarOpen = false);
          //                   },
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  /// CCTV 화면에서 포커스된 카메라가 있을 때의 레이아웃
  Widget _buildMainContent(YoloProvider yoloProvider) {
    if (_selectedIndex == 0) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: yoloProvider.focusedCamId != null
            ? _buildFocusedLayout(context, yoloProvider.focusedCamId!)
            : CameraGrid(),
      );
    }
    return _selectedIndex == 1
        ? EventList()
        : const Center(child: Text('설정 화면'));
  }

  /// 사람 감지 시 중앙 확대, 나머지 카메라는 가장자리 배치
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
            // 중앙 확대 카메라 (사람 감지)
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
