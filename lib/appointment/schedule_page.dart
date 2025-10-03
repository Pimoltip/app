import 'package:flutter/material.dart';
import 'package:plannerapp/pages/calendar_page.dart';
import 'day_selector.dart';
import 'time_line.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required DateTime selectedDay});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int selectedDay = 3; // เริ่มต้นให้เป็นวันพุธ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2E9),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // ✅ กดแล้วไป CalendarPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
          ),
      ),
      body: Column(
        children: [
          // ✅ รับค่าจาก DaySelector
          DaySelector(
            onDaySelected: (index) {
              setState(() {
                selectedDay = index;
              });
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF2D8),
                borderRadius: BorderRadius.circular(16),
              ),
              // ✅ ส่ง selectedDay ให้ TimeLine
              child: TimeLine(selectedDay: selectedDay),
            ),
          ),
        ],
      ),
    );
  }
}