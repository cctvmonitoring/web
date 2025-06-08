import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../screens/history_screen.dart';

class CalendarDialog extends StatelessWidget {
  const CalendarDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
  }
} 