import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_event_page.dart';
import 'package:plannerapp/pages/weekly_page.dart'; // 👈 import WeeklyPage

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 10, 7):  ['วันสุดท้ายของการขอเทียบโอนรายวิชา'],
    DateTime.utc(2025, 10, 13): ['วันคล้ายวันสวรรคต ร.9', 'นิสิตกรอกแบบประเมินการสอนผ่านเว็บ ครั้งที่ 2'],
    DateTime.utc(2025, 10, 17): ['นิสิตกรอกแบบประเมินการสอนวันสุดท้าย', 'วันสุดท้ายของการส่งใบจองการศึกษาภาคปลาย'],
    DateTime.utc(2025, 10, 21): ['วันสอบไล่***'],
  };

  List<String> _getEventsForDay(DateTime day) =>
      _events[DateTime.utc(day.year, day.month, day.day)] ?? [];

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner Calendar'),
        actions: [
          IconButton(
  icon: const Icon(Icons.calendar_month),
  tooltip: 'ไปยัง Weekly',
  onPressed: () {
    Navigator.pushNamed(context, '/weekly');
  },
),
        ],  
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
  setState(() {
    _selectedDay = selected;
    _focusedDay  = focused;
  });

  final eventsForSelected = _getEventsForDay(selected);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => WeeklyPage(
        selectedDay: selected,
        events: _getEventsForDay(selected),
      ),
    ),
  );
},

            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            eventLoader: _getEventsForDay,
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarStyle: const CalendarStyle(outsideDaysVisible: false),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.lightBlueAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('calendars',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.amber.shade200,
                              child: Text(
                                '${(_selectedDay ?? _focusedDay).day}',
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(events[i])),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
  child: const Icon(Icons.add),
  onPressed: () async {
    await Navigator.pushNamed(context, AddEventPage.routeName);
    setState(() {}); // refresh หลังกลับมา
  },
),

    );
  }
}
