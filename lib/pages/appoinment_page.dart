// lib/pages/appoinment_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'project_calendar.dart';
import 'add_event_page.dart'; // ✅ import AddEventPage
import '../models/important_day.dart';
import '../repo/project_repository.dart';
import '../repo/event_repository.dart';
import '../services/auth_service.dart';
import '../services/recurring_event_service.dart';

/// ===================
/// Appointment Page (เชื่อมข้อมูลจริงให้ตรงกับ ProjectCalendar)
/// ===================
class AppointmentPage extends StatefulWidget {
  final DateTime selectedDate; // วันที่ที่เลือกจาก ProjectCalendar

  const AppointmentPage({super.key, required this.selectedDate});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  // state วัน/สัปดาห์
  late DateTime _today;
  late List<DateTime> _weekDays; // 7 วัน (เริ่มวันอาทิตย์)
  int _selectedIndex = 3; // 0=Sun..6=Satพ

  // ข้อมูลรวมแบบเดียวกับ ProjectCalendar
  List<ImportantDay> _allDays = [];

  // ข้อมูลงานที่มี time (ใช้ลง timeline)
  List<_TimedItem> _timedEventsForSelectedDay = [];
  List<ImportantDay> _allDayEventsForSelectedDay = [];

  // Repository instances
  final ProjectRepository _projectRepo = ProjectRepository();
  final EventRepository _eventRepo = EventRepository();
  final AuthService _authService = AuthService();
  final RecurringEventService _recurringEventService = RecurringEventService();

  @override
  void initState() {
    super.initState();
    _today = widget.selectedDate;
    _weekDays = _buildWeekOf(_today);

    // วาง index ให้ตรงกับวันที่ที่เลือก
    final wd = (_today.weekday) % 7; // 1..7 → 0..6 (Sun=0)
    _selectedIndex = wd;

    _loadAllData().then((_) => _rebuildSelectedDayLists());
  }

  // -----------------------------
  // Load data เหมือน ProjectCalendar
  // -----------------------------
  Future<void> _loadAllData() async {
    try {
      // 🔐 ดึงข้อมูลผู้ใช้ปัจจุบัน
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return;
      }

      // อ่านจาก assets
      final impData = await rootBundle.loadString('assets/important_days.json');
      final kuData = await rootBundle.loadString('assets/ku_calendar.json');
      final evtData = await rootBundle.loadString('assets/events.json');

      final List impJson = json.decode(impData) as List;
      final List kuJson = json.decode(kuData) as List;
      final List evtJson = json.decode(evtData) as List;

      // ✅ ดึงข้อมูลจาก SQLite (กรองตาม user_id)
      final sqliteProjects = await _projectRepo.loadProjects(currentUser.id!);
      final sqliteEvents = await _eventRepo.loadEvents(currentUser.id!);

      // map → ImportantDay (ใช้สีเดียวกับ ProjectCalendar)
      final impDays = impJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#FFA726', // ส้ม: important
        ),
      );

      final kuDays = kuJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#4CAF50', // เขียว: KU
        ),
      );

      // ✅ โปรเจกต์จาก SQLite
      final projDays = sqliteProjects
          .where((p) => p.deadline != null && p.deadline!.isNotEmpty)
          .map(
            (p) => ImportantDay(
              title: p.name,
              date: p.deadline!,
              description:
                  "Progress: ${p.progress}% | Members: ${p.members.join(', ')}",
              color: '#9C27B0', // ม่วง: deadline โปรเจกต์
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

      // ✅ อีเวนต์จาก SQLite
      final userEvents = sqliteEvents.map(
        (e) => ImportantDay(
          title: e.title,
          date:
              "${e.date.year.toString().padLeft(4, '0')}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}",
          description: e.description,
          color: '#03A9F4', // ฟ้าน้ำทะเล: user
        ),
      );

      setState(() {
        _allDays = [
          ...impDays,
          ...kuDays,
          ...sysEvents,
          ...projDays,
          ...userEvents,
        ];
      });
    } catch (e) {
      debugPrint('Appointment::_loadAllData error: $e');
    }
  }

  // -----------------------------
  // Build week / helpers
  // -----------------------------
  List<DateTime> _buildWeekOf(DateTime ref) {
    // หา "อาทิตย์" ของสัปดาห์ที่อ้างอิง (Sun=0)
    final sunday = ref.subtract(Duration(days: ref.weekday % 7));
    return List.generate(
      7,
      (i) => DateTime(sunday.year, sunday.month, sunday.day + i),
    );
  }

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return 'Sun';
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return '';
    }
  }

  // -----------------------------
  // สร้างรายการของ "วันที่เลือก" สำหรับ timeline
  //   - ถ้ามี time: อยู่ใน _timedEventsForSelectedDay
  //   - ถ้าไม่มี time: อยู่ใน _allDayEventsForSelectedDay
  // -----------------------------
  Future<void> _rebuildSelectedDayLists() async {
    final day = _weekDays[_selectedIndex];
    final key = _ymd(day);

    // 🔐 ดึงข้อมูลผู้ใช้ปัจจุบัน
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) {
      debugPrint('❌ No user logged in');
      return;
    }

    // ✅ ดึงข้อมูลกิจกรรมสำหรับวันที่เฉพาะ (รวมกิจกรรมที่ทำซ้ำ)
    final eventsForDay = await _recurringEventService.getEventsForDate(
      currentUser.id!,
      day,
    );

    // สร้าง map "date -> list of time items" จากกิจกรรมที่ได้
    final timed = <_TimedItem>[];

    // ✅ แปลงกิจกรรมเป็น TimedItem
    for (final e in eventsForDay) {
      final eventDate = _ymd(e.date);
      if (eventDate == key) {
        timed.add(
          _TimedItem(
            hour: e.date.hour,
            minute: e.date.minute,
            title: e.title,
            detail: e.description,
            colorHex: e.isRecurring
                ? '#FF9800'
                : '#03A9F4', // สีส้มสำหรับกิจกรรมที่ทำซ้ำ
          ),
        );
      }
    }

    // จัดกลุ่ม All-day (ทุกอันที่ "ไม่มี time") จาก _allDays รวมทุกแหล่ง
    final allDay = _allDays.where((d) => d.date == key).where((d) {
      // ไม่มี time ใน d.description โดยดีไซน์ (ImportantDay ไม่มี field time)
      // เพราะฉะนั้น treat เป็น All-day ทั้งหมด
      // (ถ้าอยากจับเวลาจาก text ก็เพิ่มพาร์สเองได้)
      return true;
    }).toList();

    // sort timeline ตามเวลา (hour/minute null → ดันไปท้าย)
    timed.sort((a, b) {
      final ak = (a.hour ?? 99) * 60 + (a.minute ?? 99);
      final bk = (b.hour ?? 99) * 60 + (b.minute ?? 99);
      return ak.compareTo(bk);
    });

    setState(() {
      _timedEventsForSelectedDay = timed;
      _allDayEventsForSelectedDay = allDay;
    });
  }

  // -----------------------------
  // Build
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final d = _weekDays[_selectedIndex];
    final title =
        'Appointment — ${d.day}/${d.month}/${d.year} (${_weekdayShort(d.weekday)})';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectCalendar()),
            );
          },
        ),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final selectedDay = _weekDays[_selectedIndex];
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventPage(
                    selectedDate: selectedDay,
                    isWeeklyEvent: true,
                  ),
                ),
              );

              // รีเฟรชข้อมูลหลังจากเพิ่ม event ใหม่
              if (result == true && mounted) {
                await _loadAllData();
                await _rebuildSelectedDayLists();
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
      body: Column(
        children: [
          // เลือกวันในสัปดาห์
          _DaySelectorBar(
            weekDays: _weekDays,
            selectedIndex: _selectedIndex,
            onSelected: (i) async {
              setState(() => _selectedIndex = i);
              await _rebuildSelectedDayLists();
            },
          ),
          const SizedBox(height: 12),

          // All-day events
          if (_allDayEventsForSelectedDay.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All-day',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._allDayEventsForSelectedDay.map(
                    (e) => _EventPill(
                      title: e.title,
                      detail: e.description,
                      color: _safeColor(e.color),
                    ),
                  ),
                ],
              ),
            ),

          // Timeline 00–23
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF2D8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _TimelineView(items: _timedEventsForSelectedDay),
            ),
          ),
        ],
      ),
    );
  }

  Color _safeColor(String? hex) {
    try {
      return Color(int.parse((hex ?? '#9E9E9E').replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }
}

/// แถบเลือกวันแนวนอน (อาทิตย์..เสาร์)
class _DaySelectorBar extends StatelessWidget {
  final List<DateTime> weekDays;
  final int selectedIndex;
  final void Function(int) onSelected;

  const _DaySelectorBar({
    required this.weekDays,
    required this.selectedIndex,
    required this.onSelected,
  });

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return 'Sun';
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weekDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = weekDays[i];
          final isSelected = i == selectedIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelected(i),
            child: Container(
              width: 74,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '${d.day} ${_weekdayShort(d.weekday)}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ไอเท็มที่มีเวลา (hour/minute) สำหรับ timeline
class _TimedItem {
  final int? hour; // null = ไม่มีเวลาแน่นอน → ดันไปท้าย
  final int? minute; // null = ''
  final String title;
  final String detail;
  final String colorHex;

  _TimedItem({
    required this.hour,
    required this.minute,
    required this.title,
    required this.detail,
    required this.colorHex,
  });
}

/// การ์ดสั้นๆ สำหรับ All-day
class _EventPill extends StatelessWidget {
  final String title;
  final String detail;
  final Color color;

  const _EventPill({
    required this.title,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title — $detail',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// ไทม์ไลน์ 00–23 พร้อมแปะอีเวนต์ในชั่วโมงนั้นๆ
class _TimelineView extends StatelessWidget {
  final List<_TimedItem> items;

  const _TimelineView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 24,
      itemBuilder: (context, i) {
        final hour24 = i;
        final labelHour = hour24 % 12 == 0 ? 12 : hour24 % 12;
        final isAM = hour24 < 12;
        final label =
            '${labelHour.toString().padLeft(2, '0')} ${isAM ? 'AM' : 'PM'}';

        final matches = items.where((e) => e.hour == hour24).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const Divider(height: 18, color: Colors.black12),
            ...matches.map((e) => _TimelineCard(item: e)),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final _TimedItem item;
  const _TimelineCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _safe(item.colorHex);
    final timeText = (item.hour != null && item.minute != null)
        ? '${item.hour!.toString().padLeft(2, '0')}:${item.minute!.toString().padLeft(2, '0')}'
        : '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(timeText, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Color _safe(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }
}
