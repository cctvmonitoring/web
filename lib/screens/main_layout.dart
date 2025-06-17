import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../screens/video_stream_page.dart';
// import '../providers/yolo_provider.dart'; // ❌ 더 이상 필요하지 않음
import '../widgets/camera_grid.dart';
import '../widgets/event_list.dart';
import '../widgets/settings_widget.dart';
import '../widgets/dashboard_widget.dart';
import '../widgets/map_view.dart';
import '../widgets/analytics_view.dart';
import '../widgets/management_view.dart';
import '../widgets/history_list.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _showCalendarModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16),
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
                    titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    outsideDaysVisible: false,
                  ),
                  onDaySelected: (selectedDay, _) {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => History(selectedDate: selectedDay),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('닫기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return const MultiStreamPage(); // ✅ CCTV 스트림
      case 1:
        return EventList();
      case 2:
        return const DashboardWidget();
      case 3:
        return const MapView();
      case 4:
        return const AnalyticsView();
      case 5:
        return const ManagementView();
      case 6:
        return const SettingsWidget();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('보안관제 시스템', style: TextStyle(color: Colors.white)),
      ),
      body: Row(
        children: [
          NavigationRail(
            minWidth: 120,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            backgroundColor: const Color(0xFF1A1A1A),
            labelType: NavigationRailLabelType.all,
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
                 padding: const EdgeInsets.only(bottom: 24),
                 child: CircleAvatar(
                   backgroundColor: const Color(0xFF2C2C2C),
                   radius: 25,
                   child: IconButton(
                     icon: const Icon(Icons.calendar_month, color: Colors.grey),
                     onPressed: () => _showCalendarModal(context),
                   ),
                 ),
               ),
             ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF2C2C2C),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildMainContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
