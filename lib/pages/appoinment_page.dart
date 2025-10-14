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
/// 📅 Appointment Page - หน้าจัดการนัดหมายรายวัน
/// ===================
/// 
/// หน้าที่หลัก:
/// 1. แสดงรายการกิจกรรม/นัดหมายในวันที่เลือก
/// 2. แสดง Timeline แบบชั่วโมง (00:00 - 23:59)
/// 3. แสดง All-day events (กิจกรรมทั้งวัน)
/// 4. เชื่อมต่อกับ ProjectCalendar เพื่อรับวันที่ที่เลือก
/// 5. อนุญาตให้เพิ่มกิจกรรมใหม่ผ่าน AddEventPage
/// 
/// การทำงาน:
/// - รับวันที่ที่เลือกจาก ProjectCalendar
/// - แสดงสัปดาห์ที่รวมวันที่นั้น
/// - แสดงรายการกิจกรรมในวันที่เลือกแบบ Timeline
/// - รองรับทั้งกิจกรรมที่มีเวลากำหนดและกิจกรรมทั้งวัน
/// 
/// ข้อมูลที่แสดง:
/// - กิจกรรมจาก SQLite (ผู้ใช้สร้างเอง)
/// - กิจกรรมที่ทำซ้ำ (Recurring Events)
/// - วันสำคัญจาก assets
/// - วันสำคัญของ KU
/// - กำหนดส่งโปรเจกต์
/// - System Events
class AppointmentPage extends StatefulWidget {
  /// วันที่ที่ผู้ใช้เลือกจาก ProjectCalendar
  /// ใช้เป็นจุดเริ่มต้นในการแสดงสัปดาห์และกิจกรรม
  final DateTime selectedDate;

  const AppointmentPage({super.key, required this.selectedDate});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

/// 🏠 State Class สำหรับ AppointmentPage
/// จัดการ state และข้อมูลทั้งหมดของหน้านัดหมาย
class _AppointmentPageState extends State<AppointmentPage> {
  // ========================================
  // 📅 State Variables - ตัวแปรสถานะ
  // ========================================
  
  /// วันที่ปัจจุบัน (ได้รับจาก widget.selectedDate)
  late DateTime _today;
  
  /// รายการ 7 วันในสัปดาห์ (เริ่มจากวันอาทิตย์)
  /// ใช้สำหรับแสดงแถบเลือกวันแนวนอน
  late List<DateTime> _weekDays;
  
  /// ดัชนีของวันที่ที่เลือกในสัปดาห์ (0=อาทิตย์, 1=จันทร์, ..., 6=เสาร์)
  int _selectedIndex = 3; // ค่าเริ่มต้นเป็นวันพุธ

  // ========================================
  // 📊 Data Variables - ตัวแปรข้อมูล
  // ========================================
  
  /// รายการวันสำคัญทั้งหมด (รวมจากทุกแหล่งข้อมูล)
  /// ใช้ข้อมูลเดียวกับ ProjectCalendar เพื่อความสอดคล้อง
  List<ImportantDay> _allDays = [];

  /// รายการกิจกรรมที่มีเวลากำหนดสำหรับวันที่เลือก
  /// ใช้แสดงใน Timeline (00:00 - 23:59)
  List<_TimedItem> _timedEventsForSelectedDay = [];
  
  /// รายการกิจกรรมทั้งวันสำหรับวันที่เลือก
  /// แสดงเหนือ Timeline
  List<ImportantDay> _allDayEventsForSelectedDay = [];

  // ========================================
  // 🔧 Service Instances - อินสแตนซ์ของ Service
  // ========================================
  
  /// Repository สำหรับจัดการข้อมูลโปรเจกต์
  final ProjectRepository _projectRepo = ProjectRepository();
  
  /// Repository สำหรับจัดการข้อมูลกิจกรรม
  final EventRepository _eventRepo = EventRepository();
  
  /// Service สำหรับจัดการการยืนยันตัวตน
  final AuthService _authService = AuthService();
  
  /// Service สำหรับจัดการกิจกรรมที่ทำซ้ำ
  final RecurringEventService _recurringEventService = RecurringEventService();

  // ========================================
  // 🚀 Lifecycle Methods - วงจรชีวิตของ Widget
  // ========================================
  
  /// ฟังก์ชันที่เรียกเมื่อ Widget ถูกสร้างขึ้น
  /// ใช้สำหรับการเตรียมข้อมูลเริ่มต้น
  @override
  void initState() {
    super.initState();
    
    // ตั้งค่าวันที่ปัจจุบันจากวันที่ที่ส่งมาจาก ProjectCalendar
    _today = widget.selectedDate;
    
    // สร้างรายการ 7 วันในสัปดาห์ที่รวมวันที่เลือก
    _weekDays = _buildWeekOf(_today);

    // คำนวณดัชนีของวันที่เลือกในสัปดาห์
    // DateTime.weekday ให้ค่า 1=จันทร์, 2=อังคาร, ..., 7=อาทิตย์
    // แต่เราต้องการ 0=อาทิตย์, 1=จันทร์, ..., 6=เสาร์
    final wd = (_today.weekday) % 7; // แปลง 1..7 → 0..6 (อาทิตย์=0)
    _selectedIndex = wd;

    // โหลดข้อมูลทั้งหมดแล้วสร้างรายการกิจกรรมสำหรับวันที่เลือก
    _loadAllData().then((_) => _rebuildSelectedDayLists());
  }

  // ========================================
  // 📊 Data Loading Methods - ฟังก์ชันโหลดข้อมูล
  // ========================================
  
  /// โหลดข้อมูลทั้งหมดจากแหล่งต่างๆ
  /// รวมข้อมูลจาก Assets และ SQLite เพื่อแสดงในหน้านัดหมาย
  /// ใช้ข้อมูลเดียวกับ ProjectCalendar เพื่อความสอดคล้อง
  Future<void> _loadAllData() async {
    try {
      // 🔐 ขั้นตอนที่ 1: ดึงข้อมูลผู้ใช้ปัจจุบัน
      // จำเป็นสำหรับการกรองข้อมูลตามผู้ใช้ (multi-user support)
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return;
      }

      // 📁 ขั้นตอนที่ 2: อ่านข้อมูลจาก Assets Files
      // ไฟล์เหล่านี้เก็บข้อมูลสถิตที่ใช้ร่วมกัน
      final impData = await rootBundle.loadString('assets/important_days.json');
      final kuData = await rootBundle.loadString('assets/ku_calendar.json');
      final evtData = await rootBundle.loadString('assets/events.json');

      // แปลง JSON เป็น List
      final List impJson = json.decode(impData) as List;
      final List kuJson = json.decode(kuData) as List;
      final List evtJson = json.decode(evtData) as List;

      // 💾 ขั้นตอนที่ 3: ดึงข้อมูลจาก SQLite Database
      // กรองข้อมูลตาม user_id เพื่อความปลอดภัย
      final sqliteProjects = await _projectRepo.loadProjects(currentUser.id!);
      final sqliteEvents = await _eventRepo.loadEvents(currentUser.id!);

      // 🎨 ขั้นตอนที่ 4: แปลงข้อมูลเป็น ImportantDay Objects
      // แต่ละประเภทมีสีที่แตกต่างกันเพื่อความชัดเจน

      // 📅 วันสำคัญทั่วไป (สีเหลือง)
      final impDays = impJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#FFEB3B', // สีเหลืองสำหรับวันสำคัญทั่วไป
        ),
      );

      // 🎓 วันสำคัญของมหาวิทยาลัย (สีเขียว)
      final kuDays = kuJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#4CAF50', // สีเขียวสำหรับ KU
        ),
      );

      // 📋 กำหนดส่งโปรเจกต์ (สีม่วง)
      // กรองเฉพาะโปรเจกต์ที่มี deadline
      final projDays = sqliteProjects
          .where((p) => p.deadline != null && p.deadline!.isNotEmpty)
          .map(
            (p) => ImportantDay(
              title: p.name,
              date: p.deadline!,
              description:
                  "Progress: ${p.progress}% | Members: ${p.members.join(', ')}",
              color: '#9C27B0', // สีม่วงสำหรับ deadline โปรเจกต์
            ),
          );

      // ⚙️ System Events (สีฟ้าอ่อน)
      final sysEvents = evtJson.map(
        (e) => ImportantDay(
          title: e['title'] ?? 'System Event',
          date: e['date'],
          description: e['note'] ?? '',
          color: '#42A5F5', // สีฟ้าอ่อนสำหรับ system events
        ),
      );

      // 👤 กิจกรรมของผู้ใช้ (สีฟ้าน้ำทะเล)
      final userEvents = sqliteEvents.map(
        (e) => ImportantDay(
          title: e.title,
          date:
              "${e.date.year.toString().padLeft(4, '0')}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}",
          description: e.description,
          color: '#03A9F4', // สีฟ้าน้ำทะเลสำหรับกิจกรรมผู้ใช้
        ),
      );

      // 🔄 อัพเดท State ด้วยข้อมูลที่รวมกัน
      setState(() {
        _allDays = [
          ...impDays,      // วันสำคัญทั่วไป
          ...kuDays,       // วันสำคัญ KU
          ...sysEvents,    // System Events
          ...projDays,     // กำหนดส่งโปรเจกต์
          ...userEvents,   // กิจกรรมผู้ใช้
        ];
      });
    } catch (e) {
      debugPrint('Appointment::_loadAllData error: $e');
    }
  }

  // ========================================
  // 🛠️ Helper Methods - ฟังก์ชันช่วยเหลือ
  // ========================================
  
  /// สร้างรายการ 7 วันในสัปดาห์ที่รวมวันที่อ้างอิง
  /// เริ่มจากวันอาทิตย์ (index 0) ถึงวันเสาร์ (index 6)
  /// 
  /// @param ref วันที่อ้างอิง (วันที่ที่ต้องการหาสัปดาห์)
  /// @return List<DateTime> รายการ 7 วันในสัปดาห์
  List<DateTime> _buildWeekOf(DateTime ref) {
    // หาวันอาทิตย์ของสัปดาห์ที่รวมวันที่อ้างอิง
    // DateTime.weekday % 7 จะให้ 0=อาทิตย์, 1=จันทร์, ..., 6=เสาร์
    final sunday = ref.subtract(Duration(days: ref.weekday % 7));
    
    // สร้างรายการ 7 วัน โดยเริ่มจากวันอาทิตย์
    return List.generate(
      7,
      (i) => DateTime(sunday.year, sunday.month, sunday.day + i),
    );
  }

  /// แปลง DateTime เป็น String ในรูปแบบ YYYY-MM-DD
  /// ใช้สำหรับเปรียบเทียบวันที่
  /// 
  /// @param d DateTime ที่ต้องการแปลง
  /// @return String ในรูปแบบ YYYY-MM-DD
  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// แปลงเลขวันในสัปดาห์เป็นชื่อย่อภาษาอังกฤษ
  /// 
  /// @param weekday เลขวันในสัปดาห์ (1=จันทร์, 2=อังคาร, ..., 7=อาทิตย์)
  /// @return String ชื่อวันย่อ (Sun, Mon, Tue, ...)
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

  // ========================================
  // 📅 Timeline Building Methods - ฟังก์ชันสร้าง Timeline
  // ========================================
  
  /// สร้างรายการกิจกรรมสำหรับวันที่เลือก
  /// แบ่งเป็น 2 ประเภท:
  /// 1. กิจกรรมที่มีเวลากำหนด (_timedEventsForSelectedDay) - แสดงใน Timeline
  /// 2. กิจกรรมทั้งวัน (_allDayEventsForSelectedDay) - แสดงเหนือ Timeline
  /// 
  /// เรียกใช้เมื่อ:
  /// - ผู้ใช้เปลี่ยนวันที่เลือก
  /// - หลังจากโหลดข้อมูลใหม่
  Future<void> _rebuildSelectedDayLists() async {
    // กำหนดวันที่ที่เลือกจากดัชนีในสัปดาห์
    final day = _weekDays[_selectedIndex];
    final key = _ymd(day); // แปลงเป็น YYYY-MM-DD สำหรับเปรียบเทียบ

    // 🔐 ขั้นตอนที่ 1: ตรวจสอบผู้ใช้ปัจจุบัน
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) {
      debugPrint('❌ No user logged in');
      return;
    }

    // ⏰ ขั้นตอนที่ 2: ดึงกิจกรรมที่มีเวลากำหนด
    // รวมกิจกรรมที่ทำซ้ำ (Recurring Events) ด้วย
    final eventsForDay = await _recurringEventService.getEventsForDate(
      currentUser.id!,
      day,
    );

    // 📝 ขั้นตอนที่ 3: แปลงกิจกรรมเป็น TimedItem สำหรับ Timeline
    final timed = <_TimedItem>[];

    for (final e in eventsForDay) {
      final eventDate = _ymd(e.date);
      if (eventDate == key) {
        timed.add(
          _TimedItem(
            hour: e.date.hour,
            minute: e.date.minute,
            title: e.title,
            detail: e.description,
            // ใช้สีที่แตกต่างกันสำหรับกิจกรรมที่ทำซ้ำ
            colorHex: e.isRecurring
                ? '#FF9800'  // สีส้มสำหรับกิจกรรมที่ทำซ้ำ
                : '#03A9F4', // สีฟ้าน้ำทะเลสำหรับกิจกรรมปกติ
          ),
        );
      }
    }

    // 🌅 ขั้นตอนที่ 4: รวบรวมกิจกรรมทั้งวัน
    // กิจกรรมจาก _allDays (ImportantDay) ถือเป็นกิจกรรมทั้งวัน
    // เพราะไม่มี field time ในการออกแบบ
    final allDay = _allDays.where((d) => d.date == key).where((d) {
      // ทุกกิจกรรมใน _allDays ถือเป็น All-day events
      // หากต้องการแยกเวลาในอนาคต สามารถเพิ่มการ parse จาก description ได้
      return true;
    }).toList();

    // 🔄 ขั้นตอนที่ 5: เรียงลำดับ Timeline ตามเวลา
    // กิจกรรมที่ไม่มีเวลาจะถูกดันไปท้ายสุด
    timed.sort((a, b) {
      final ak = (a.hour ?? 99) * 60 + (a.minute ?? 99);
      final bk = (b.hour ?? 99) * 60 + (b.minute ?? 99);
      return ak.compareTo(bk);
    });

    // 🎯 ขั้นตอนที่ 6: อัพเดท State
    setState(() {
      _timedEventsForSelectedDay = timed;      // กิจกรรมที่มีเวลากำหนด
      _allDayEventsForSelectedDay = allDay;    // กิจกรรมทั้งวัน
    });
  }

  // ========================================
  // 🎨 UI Build Methods - ฟังก์ชันสร้าง UI
  // ========================================
  
  /// สร้าง UI หลักของหน้านัดหมาย
  /// ประกอบด้วย:
  /// 1. AppBar พร้อมปุ่มนำทางและเพิ่มกิจกรรม
  /// 2. แถบเลือกวันในสัปดาห์
  /// 3. รายการกิจกรรมทั้งวัน
  /// 4. Timeline แสดงกิจกรรมที่มีเวลากำหนด
  @override
  Widget build(BuildContext context) {
    // คำนวณวันที่ที่เลือกและสร้างชื่อ title
    final d = _weekDays[_selectedIndex];
    final title =
        'Appointment — ${d.day}/${d.month}/${d.year} (${_weekdayShort(d.weekday)})';

    return Scaffold(
      // กำหนดสีพื้นหลังเป็นสีครีมอ่อน
      backgroundColor: const Color(0xFFF6F2E9),
      
      // 🧭 AppBar - แถบด้านบน
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2E9),
        elevation: 0, // ไม่มีเงา
        leading: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            // นำทางกลับไปยัง ProjectCalendar
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectCalendar()),
            );
          },
        ),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          // ➕ ปุ่มเพิ่มกิจกรรมใหม่
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final selectedDay = _weekDays[_selectedIndex];
              
              // นำทางไปยังหน้าเพิ่มกิจกรรม
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
      
      // 📱 Body - เนื้อหาหลัก
      body: Column(
        children: [
          // 📅 แถบเลือกวันในสัปดาห์
          _DaySelectorBar(
            weekDays: _weekDays,
            selectedIndex: _selectedIndex,
            onSelected: (i) async {
              setState(() => _selectedIndex = i);
              await _rebuildSelectedDayLists();
            },
          ),
          const SizedBox(height: 12),

          // 🌅 ส่วนแสดงกิจกรรมทั้งวัน
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
                  // แสดงรายการกิจกรรมทั้งวันเป็น pills
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

          // ⏰ Timeline แสดงกิจกรรมที่มีเวลากำหนด (00:00 - 23:59)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF2D8), // สีเขียวอ่อน
                borderRadius: BorderRadius.circular(16),
              ),
              child: _TimelineView(items: _timedEventsForSelectedDay),
            ),
          ),
        ],
      ),
    );
  }

  /// แปลง String hex color เป็น Color object อย่างปลอดภัย
  /// หากการแปลงล้มเหลวจะคืนค่า Colors.grey
  /// 
  /// @param hex String hex color (เช่น "#FF0000")
  /// @return Color object
  Color _safeColor(String? hex) {
    try {
      return Color(int.parse((hex ?? '#9E9E9E').replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }
}

// ========================================
// 🧩 UI Components - Widget Components
// ========================================

/// 📅 แถบเลือกวันแนวนอน (อาทิตย์..เสาร์)
/// แสดง 7 วันในสัปดาห์ให้ผู้ใช้เลือก
/// วันที่เลือกจะมีการไฮไลท์สีเขียว
class _DaySelectorBar extends StatelessWidget {
  /// รายการ 7 วันในสัปดาห์ (เริ่มจากวันอาทิตย์)
  final List<DateTime> weekDays;
  
  /// ดัชนีของวันที่ที่เลือก (0=อาทิตย์, 1=จันทร์, ..., 6=เสาร์)
  final int selectedIndex;
  
  /// Callback function ที่เรียกเมื่อผู้ใช้เลือกวันใหม่
  final void Function(int) onSelected;

  const _DaySelectorBar({
    required this.weekDays,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// แปลงเลขวันในสัปดาห์เป็นชื่อย่อภาษาอังกฤษ
  /// (ใช้ซ้ำกับฟังก์ชันใน main class)
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
        scrollDirection: Axis.horizontal, // แสดงแนวนอน
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weekDays.length, // 7 วัน
        separatorBuilder: (_, __) => const SizedBox(width: 8), // ระยะห่างระหว่างวัน
        itemBuilder: (context, i) {
          final d = weekDays[i];
          final isSelected = i == selectedIndex;
          
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelected(i), // เรียก callback เมื่อถูกแตะ
            child: Container(
              width: 74,
              decoration: BoxDecoration(
                // เปลี่ยนสีตามสถานะการเลือก
                color: isSelected ? Colors.green : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '${d.day} ${_weekdayShort(d.weekday)}', // แสดงวันที่และชื่อวัน
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

/// ⏰ Data Model สำหรับกิจกรรมที่มีเวลากำหนด
/// ใช้สำหรับแสดงใน Timeline (00:00 - 23:59)
class _TimedItem {
  /// ชั่วโมง (0-23), null = ไม่มีเวลาแน่นอน → ดันไปท้ายสุด
  final int? hour;
  
  /// นาที (0-59), null = ไม่มีเวลาแน่นอน
  final int? minute;
  
  /// ชื่อกิจกรรม
  final String title;
  
  /// รายละเอียดกิจกรรม
  final String detail;
  
  /// สีของกิจกรรมในรูปแบบ hex (เช่น "#FF0000")
  final String colorHex;

  _TimedItem({
    required this.hour,
    required this.minute,
    required this.title,
    required this.detail,
    required this.colorHex,
  });
}

/// 🌅 การ์ดแสดงกิจกรรมทั้งวัน (All-day Events)
/// แสดงเหนือ Timeline เป็นรูป pills เล็กๆ
class _EventPill extends StatelessWidget {
  /// ชื่อกิจกรรม
  final String title;
  
  /// รายละเอียดกิจกรรม
  final String detail;
  
  /// สีของกิจกรรม
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
        // สีพื้นหลังโปร่งใสตามสีของกิจกรรม
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        // เส้นขอบสีอ่อนตามสีของกิจกรรม
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // จุดสีแสดงประเภทกิจกรรม
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          // ข้อความชื่อและรายละเอียดกิจกรรม
          Expanded(
            child: Text(
              '$title — $detail',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis, // ตัดข้อความยาว
            ),
          ),
        ],
      ),
    );
  }
}

/// ⏰ Timeline View - แสดงกิจกรรมตามชั่วโมง (00:00 - 23:59)
/// แสดง 24 ชั่วโมงในแต่ละวัน พร้อมกิจกรรมที่เกิดขึ้นในชั่วโมงนั้นๆ
class _TimelineView extends StatelessWidget {
  /// รายการกิจกรรมที่มีเวลากำหนด
  final List<_TimedItem> items;

  const _TimelineView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 24, // 24 ชั่วโมง
      itemBuilder: (context, i) {
        final hour24 = i; // ชั่วโมงแบบ 24 ชั่วโมง (0-23)
        
        // แปลงเป็นรูปแบบ 12 ชั่วโมง สำหรับการแสดงผล
        final labelHour = hour24 % 12 == 0 ? 12 : hour24 % 12;
        final isAM = hour24 < 12;
        final label =
            '${labelHour.toString().padLeft(2, '0')} ${isAM ? 'AM' : 'PM'}';

        // หากิจกรรมที่เกิดขึ้นในชั่วโมงนี้
        final matches = items.where((e) => e.hour == hour24).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงป้ายเวลาชั่วโมง
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const Divider(height: 18, color: Colors.black12),
            
            // แสดงกิจกรรมในชั่วโมงนี้
            ...matches.map((e) => _TimelineCard(item: e)),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}

/// 📋 การ์ดแสดงกิจกรรมใน Timeline
/// แสดงรายละเอียดกิจกรรมพร้อมเวลาที่กำหนด
class _TimelineCard extends StatelessWidget {
  /// ข้อมูลกิจกรรมที่ต้องการแสดง
  final _TimedItem item;
  
  const _TimelineCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // แปลงสี hex เป็น Color object
    final color = _safe(item.colorHex);
    
    // สร้างข้อความเวลา (HH:MM)
    final timeText = (item.hour != null && item.minute != null)
        ? '${item.hour!.toString().padLeft(2, '0')}:${item.minute!.toString().padLeft(2, '0')}'
        : '--:--'; // แสดง --:-- หากไม่มีเวลากำหนด

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // เส้นขอบสีอ่อนตามสีของกิจกรรม
        border: Border.all(color: color.withValues(alpha: 0.4)),
        // เงาเล็กน้อยเพื่อให้ดูมีมิติ
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Row(
        children: [
          // จุดสีแสดงประเภทกิจกรรม
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          
          // ชื่อกิจกรรม
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          
          // เวลาที่กำหนด
          Text(timeText, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  /// แปลง String hex color เป็น Color object อย่างปลอดภัย
  /// หากการแปลงล้มเหลวจะคืนค่า Colors.grey
  Color _safe(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }
}
