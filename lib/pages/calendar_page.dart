import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_event_page.dart';
import 'package:plannerapp/pages/weekly_page.dart';

// ➕ import repository + model
import '../repo/event_repository.dart';
import '../models/event.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final EventRepository repo = EventRepository();
  Map<DateTime, List<Event>> eventsMap = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await repo.loadEvents();
    setState(() {
      eventsMap = {
        for (var e in events)
          DateTime(e.date.year, e.date.month, e.date.day): [
            ...(eventsMap[DateTime(e.date.year, e.date.month, e.date.day)] ?? []),
            e
          ]
      };
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return eventsMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

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
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });

              final eventsForSelected = _getEventsForDay(selected);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeeklyPage(
                    selectedDay: selected,
                    events: eventsForSelected.map((e) => e.title).toList(),
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
                  const Text('Events',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(events[i].title)),
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
          await _loadEvents(); // refresh หลังเพิ่ม event
        },
      ),
    );
  }
}
