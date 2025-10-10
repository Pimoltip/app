import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'weekly_page.dart'; // ✅ import WeeklyPage
import 'add_event_page.dart'; // ✅ import AddEventPage
import '../models/important_day.dart';
import '../models/event.dart'; // ✅ ใช้ model Event สำหรับ WeeklyPage
import '../repo/event_repository.dart'; // ✅ import EventRepository
import '../repo/project_repository.dart'; // ✅ import ProjectRepository
import '../services/auth_service.dart'; // ✅ import AuthService

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ImportantDay> allDays = [];
  List<Event> userEvents = []; // ✅ เก็บ events จาก SQLite
  final EventRepository _eventRepo = EventRepository(); // ✅ EventRepository
  final ProjectRepository _projectRepo =
      ProjectRepository(); // ✅ ProjectRepository
  final AuthService _authService = AuthService(); // ✅ AuthService

  // ✅ โหลดข้อมูลทั้งหมด
  Future<void> _loadAllData() async {
    try {
      // 🔐 ดึงข้อมูลผู้ใช้ปัจจุบัน
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return;
      }

      final impData = await rootBundle.loadString('assets/important_days.json');
      final kuData = await rootBundle.loadString('assets/ku_calendar.json');
      final evtData = await rootBundle.loadString('assets/events.json');

      final impJson = json.decode(impData) as List;
      final kuJson = json.decode(kuData) as List;
      final evtJson = json.decode(evtData) as List;

      // ✅ โหลด user events จาก SQLite (กรองตาม user_id)
      final sqliteEvents = await _eventRepo.loadEvents(currentUser.id!);

      // ✅ โหลด projects จาก SQLite (กรองตาม user_id)
      final sqliteProjects = await _projectRepo.loadProjects(currentUser.id!);

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

      // ✅ system events จาก assets/events.json
      final sysEvents = evtJson.map(
        (e) => ImportantDay(
          title: e['title'] ?? 'System Event',
          date: e['date'],
          description: e['note'] ?? '',
          color: '#42A5F5',
        ),
      );

      // ✅ แปลง SQLite events เป็น ImportantDay
      final userEventsFromSQLite = sqliteEvents.map(
        (e) => ImportantDay(
          title: e.title,
          date:
              "${e.date.year.toString().padLeft(4, '0')}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}",
          description: e.description,
          color: '#03A9F4',
        ),
      );

      // ✅ แปลง SQLite projects เป็น ImportantDay
      final userProjectsFromSQLite = sqliteProjects.map(
        (p) => ImportantDay(
          title: p.name,
          date: p.deadline != null && p.deadline != 'No deadline'
              ? p.deadline!
              : "${p.createdAt.year.toString().padLeft(4, '0')}-${p.createdAt.month.toString().padLeft(2, '0')}-${p.createdAt.day.toString().padLeft(2, '0')}",
          description:
              "Progress: ${p.progress}% | Members: ${p.members.join(', ')}",
          color: '#9C27B0',
        ),
      );

      setState(() {
        allDays = [
          ...impDays,
          ...kuDays,
          ...sysEvents,
          ...userEventsFromSQLite,
          ...userProjectsFromSQLite, // ✅ เพิ่ม projects จาก SQLite
        ];
        userEvents = sqliteEvents; // ✅ เก็บ events สำหรับ weekly view
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
      // ✅ หา event ที่ตรงกันใน SQLite
      final eventToDelete = userEvents.firstWhere(
        (e) =>
            e.title == day.title &&
            e.description == day.description &&
            "${e.date.year.toString().padLeft(4, '0')}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}" ==
                day.date,
        orElse: () => throw Exception('Event not found'),
      );

      // ✅ ลบจาก SQLite
      if (eventToDelete.id != null) {
        await _eventRepo.deleteEvent(eventToDelete.id!);
      }

      // ✅ อัปเดต UI
      setState(() {
        allDays.removeWhere(
          (d) =>
              d.title == day.title &&
              d.date == day.date &&
              d.description == day.description &&
              d.color == '#03A9F4',
        );
        userEvents.removeWhere((e) => e.id == eventToDelete.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ลบ Event สำเร็จแล้ว! 🗑️"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (err) {
      debugPrint('❌ Delete user event failed: $err');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาดในการลบ: $err"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        title: const Text('📅 KU Calendar'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Weekly View',
            onPressed: () {
              final day = _selectedDay ?? _focusedDay;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WeeklyPage(selectedDay: day)),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final navigator = Navigator.of(context);
                await _authService.logout();
                if (mounted) {
                  navigator.pushReplacementNamed('/login');
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('ออกจากระบบ'),
                  ],
                ),
              ),
            ],
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
                          int.parse(e.color.replaceFirst('#', '0xff')),
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
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final selectedDay = _selectedDay ?? _focusedDay;
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEventPage(
                          selectedDate: selectedDay,
                          isWeeklyEvent: true,
                        ),
                      ),
                    );

                    // ✅ รีเฟรชข้อมูลหลังจากเพิ่ม event ใหม่
                    if (result == true && mounted) {
                      await _loadAllData();
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text("เพิ่ม Weekly Event ใหม่แล้ว! 🎉"),
                          backgroundColor: Colors.green,
                        ),
                      );
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
