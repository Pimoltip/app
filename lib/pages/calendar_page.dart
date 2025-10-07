import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'AddEventPage.dart';
import 'weekly_page.dart'; // ✅ import WeeklyPage
import '../models/important_day.dart';
import '../models/event.dart'; // ✅ ใช้ model Event สำหรับ WeeklyPage
import '../repo/json_file_manager.dart'; // ✅ import JsonFileManager

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ImportantDay> allDays = [];

  // ✅ โหลดข้อมูลทั้งหมด
  Future<void> _loadAllData() async {
    try {
      // ✅ Copy assets to local storage first
      final eventFile = JsonFileManager('addevent.json');
      await eventFile.copyFromAsset('assets/events.json');

      final projectFile = JsonFileManager('projects.json');
      await projectFile.copyFromAsset('assets/projects.json');

      final impData = await rootBundle.loadString('assets/important_days.json');
      final kuData = await rootBundle.loadString('assets/ku_calendar.json');
      final projectData = await rootBundle.loadString('assets/projects.json');
      final eventsData = await rootBundle.loadString('assets/events.json');

      final impJson = json.decode(impData) as List;
      final kuJson = json.decode(kuData) as List;
      final projJson = json.decode(projectData) as List;
      final evtJson = json.decode(eventsData) as List;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/addevent.json');
      List<dynamic> addEventJson = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) addEventJson = json.decode(content);
      }

      final impDays = impJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#FFA726',
        ),
      );

      final kuDays = kuJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#4CAF50',
        ),
      );

      final projDays = projJson.map(
        (p) => ImportantDay(
          title: p['name'],
          date: p['deadline'],
          description:
              "Progress: ${p['progress']}% | Members: ${(p['members'] as List).join(', ')}",
          color: '#9C27B0',
        ),
      );

      final sysEvents = evtJson.map(
        (e) => ImportantDay(
          title: e['title'] ?? 'System Event',
          date: e['date'],
          description: e['note'] ?? '',
          color: '#42A5F5',
        ),
      );

      final userEvents = addEventJson.map(
        (e) => ImportantDay(
          title: e['title'] ?? 'Untitled Event',
          date: e['date'],
          description: e['note'] ?? '',
          color: '#03A9F4',
        ),
      );

      setState(() {
        allDays = [
          ...impDays,
          ...kuDays,
          ...projDays,
          ...sysEvents,
          ...userEvents,
        ];
      });
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
    }
  }

  // ✅ ดึง event ของวัน
  List<ImportantDay> _getDaysFor(DateTime day) {
    final dateStr =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return allDays.where((e) => e.date == dateStr).toList();
  }

  Future<void> _deleteUserEvent(ImportantDay day) async {
    try {
      final file = JsonFileManager('addevent.json');
      final data = await file.readJson();
      data.removeWhere(
        (e) =>
            (e['title'] ?? '') == day.title &&
            (e['date'] ?? '') == day.date &&
            (e['note'] ?? '') == day.description,
      );
      await file.writeJson(data);
      setState(() {
        allDays.removeWhere(
          (d) =>
              d.title == day.title &&
              d.date == day.date &&
              d.description == day.description &&
              d.color == '#03A9F4',
        );
      });
    } catch (err) {
      debugPrint('❌ Delete user event failed: $err');
    }
  }

  // ✅ ดึง event ทั้งสัปดาห์
  List<Event> _getEventsForWeek(DateTime selectedDay) {
    final firstDay = selectedDay.subtract(
      Duration(days: selectedDay.weekday % 7),
    );
    final lastDay = firstDay.add(const Duration(days: 6));

    return allDays
        .where((e) {
          final d = DateTime.parse(e.date);
          return !d.isBefore(firstDay) && !d.isAfter(lastDay);
        })
        .map(
          (e) => Event(
            title: e.title,
            description: e.description,
            date: DateTime.parse(e.date),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    final selectedList = _getDaysFor(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 KU Academic Calendar'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Weekly View',
            onPressed: () {
              final day = _selectedDay ?? _focusedDay;
              final weekEvents = _getEventsForWeek(day);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WeeklyPage(selectedDay: day, events: weekEvents),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== Calendar =====
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: _getDaysFor,
            headerStyle: const HeaderStyle(titleCentered: true),

            // Marker
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                final items = events.cast<ImportantDay>();
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: items.map((e) {
                      Color markerColor;
                      try {
                        markerColor = Color(
                          int.parse(
                            (e.color ?? '#FF0000').replaceFirst('#', '0xff'),
                          ),
                        );
                      } catch (_) {
                        markerColor = Colors.red;
                      }
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: markerColor,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            calendarStyle: const CalendarStyle(outsideDaysVisible: false),
          ),

          // ===== รายการของวันที่เลือก =====
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(12),
              ),
              child: selectedList.isEmpty
                  ? const Center(child: Text("ไม่มีเหตุการณ์วันนี้"))
                  : ListView.builder(
                      itemCount: selectedList.length,
                      itemBuilder: (_, i) {
                        final day = selectedList[i];
                        final isUser = day.color == '#03A9F4';
                        final card = Card(
                          color: Colors.green.shade50,
                          child: ListTile(
                            leading: const Icon(
                              Icons.event,
                              color: Colors.green,
                            ),
                            title: Text(
                              day.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(day.description),
                            trailing: isUser
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteUserEvent(day),
                                  )
                                : null,
                          ),
                        );
                        if (isUser) {
                          return Dismissible(
                            key: ValueKey(
                              'user-${day.date}-${day.title}-${day.description}',
                            ),
                            background: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              alignment: Alignment.centerLeft,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) => _deleteUserEvent(day),
                            child: card,
                          );
                        }
                        return card;
                      },
                    ),
            ),
          ),

          // ===== ปุ่ม Home / Add =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  heroTag: "homeBtn",
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.home),
                  onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                ),
                FloatingActionButton(
                  heroTag: "addBtn",
                  backgroundColor: Colors.lightGreen,
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AddEventPage.routeName,
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      final newEvent = ImportantDay(
                        title: result['title'] ?? 'Untitled Event',
                        date: result['date'],
                        description: result['note'] ?? '',
                        color: '#03A9F4',
                      );

                      setState(() {
                        allDays.add(newEvent);
                        _focusedDay = DateTime.parse(result['date']);
                        _selectedDay = _focusedDay;
                      });
                      await _loadAllData();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
