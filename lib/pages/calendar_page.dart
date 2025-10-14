// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import 'dart:convert'; // สำหรับแปลง JSON data
import 'package:flutter/material.dart'; // Flutter UI framework หลัก
import 'package:flutter/services.dart'; // สำหรับเข้าถึง assets files
import 'package:table_calendar/table_calendar.dart'; // Library สำหรับแสดงปฏิทิน
import 'weekly_page.dart'; // หน้ามุมมองรายสัปดาห์
import 'add_event_page.dart'; // หน้าเพิ่มกิจกรรมใหม่
import '../models/important_day.dart'; // Model สำหรับวันสำคัญ
import '../models/event.dart'; // Model สำหรับกิจกรรมผู้ใช้
import '../repo/event_repository.dart'; // Repository สำหรับจัดการข้อมูลกิจกรรม
import '../repo/project_repository.dart'; // Repository สำหรับจัดการข้อมูลโปรเจกต์
import '../services/auth_service.dart'; // Service สำหรับจัดการการเข้าสู่ระบบ

/// 📅 Calendar Page - หน้าปฏิทินหลัก
///
/// StatefulWidget สำหรับแสดงปฏิทินและจัดการกิจกรรมต่างๆ
/// หน้าที่หลัก:
/// 1. แสดงปฏิทินแบบเดือนพร้อม markers สำหรับกิจกรรม
/// 2. แสดงรายการกิจกรรมของวันที่เลือก
/// 3. รองรับการเพิ่มกิจกรรมใหม่
/// 4. รองรับการลบกิจกรรมของผู้ใช้ (swipe to delete)
/// 5. นำทางไปยังหน้ามุมมองรายสัปดาห์
/// 6. รวมข้อมูลจากหลายแหล่ง (assets, SQLite)
/// 
/// ข้อมูลที่แสดง:
/// - วันสำคัญจาก assets/important_days.json (สีเหลือง)
/// - วันสำคัญ KU จาก assets/ku_calendar.json (สีเขียว)
/// - System Events จาก assets/events.json (สีฟ้าอ่อน)
/// - กิจกรรมผู้ใช้จาก SQLite (สีฟ้าน้ำทะเล)
/// - กำหนดส่งโปรเจกต์จาก SQLite (สีม่วง)
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

/// 🏠 State Class สำหรับ CalendarPage
/// จัดการ state และข้อมูลทั้งหมดของหน้าปฏิทิน
class _CalendarPageState extends State<CalendarPage> {
  // ========================================
  // 📅 Calendar State Variables - ตัวแปรสถานะปฏิทิน
  // ========================================
  
  /// วันที่ที่ปฏิทินกำลังโฟกัสอยู่ (เดือนที่แสดง)
  DateTime _focusedDay = DateTime.now();
  
  /// วันที่ที่ผู้ใช้เลือกในปฏิทิน (อาจเป็น null)
  DateTime? _selectedDay;
  
  /// รายการวันสำคัญทั้งหมด (รวมจากทุกแหล่งข้อมูล)
  /// ใช้สำหรับแสดงในปฏิทินและรายการกิจกรรม
  List<ImportantDay> allDays = [];
  
  /// รายการกิจกรรมของผู้ใช้จาก SQLite
  /// เก็บเป็น Event objects เพื่อใช้ในการลบและจัดการ
  List<Event> userEvents = [];

  // ========================================
  // 🔧 Repository & Service Instances - อินสแตนซ์ของ Service
  // ========================================
  
  /// Repository สำหรับจัดการข้อมูลกิจกรรมในฐานข้อมูล SQLite
  final EventRepository _eventRepo = EventRepository();
  
  /// Repository สำหรับจัดการข้อมูลโปรเจกต์ในฐานข้อมูล SQLite
  final ProjectRepository _projectRepo = ProjectRepository();
  
  /// Service สำหรับจัดการการยืนยันตัวตนและการเข้าสู่ระบบ
  final AuthService _authService = AuthService();

  // ========================================
  // 📊 Data Loading Methods - ฟังก์ชันโหลดข้อมูล
  // ========================================
  
  /// โหลดข้อมูลทั้งหมดจากแหล่งต่างๆ
  /// รวมข้อมูลจาก Assets และ SQLite เพื่อแสดงในปฏิทิน
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. ตรวจสอบผู้ใช้ปัจจุบัน
  /// 2. อ่านข้อมูลจาก Assets files
  /// 3. ดึงข้อมูลจาก SQLite Database
  /// 4. แปลงข้อมูลเป็น ImportantDay objects
  /// 5. รวมข้อมูลทั้งหมดและอัพเดท UI
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
      final impJson = json.decode(impData) as List;
      final kuJson = json.decode(kuData) as List;
      final evtJson = json.decode(evtData) as List;

      // 💾 ขั้นตอนที่ 3: ดึงข้อมูลจาก SQLite Database
      // กรองข้อมูลตาม user_id เพื่อความปลอดภัย
      final sqliteEvents = await _eventRepo.loadEvents(currentUser.id!);
      final sqliteProjects = await _projectRepo.loadProjects(currentUser.id!);

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
      final userEventsFromSQLite = sqliteEvents.map(
        (e) => ImportantDay(
          title: e.title,
          date:
              "${e.date.year.toString().padLeft(4, '0')}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}",
          description: e.description,
          color: '#03A9F4', // สีฟ้าน้ำทะเลสำหรับกิจกรรมผู้ใช้
        ),
      );

      // 📋 กำหนดส่งโปรเจกต์ (สีม่วง)
      final userProjectsFromSQLite = sqliteProjects.map(
        (p) => ImportantDay(
          title: p.name,
          date: p.deadline != null && p.deadline != 'No deadline'
              ? p.deadline!
              : "${p.createdAt.year.toString().padLeft(4, '0')}-${p.createdAt.month.toString().padLeft(2, '0')}-${p.createdAt.day.toString().padLeft(2, '0')}",
          description:
              "Progress: ${p.progress}% | Members: ${p.members.join(', ')}",
          color: '#9C27B0', // สีม่วงสำหรับ deadline โปรเจกต์
        ),
      );

      // 🔄 ขั้นตอนที่ 5: อัพเดท State ด้วยข้อมูลที่รวมกัน
      setState(() {
        allDays = [
          ...impDays,      // วันสำคัญทั่วไป
          ...kuDays,       // วันสำคัญ KU
          ...sysEvents,    // System Events
          ...userEventsFromSQLite,   // กิจกรรมผู้ใช้
          ...userProjectsFromSQLite, // กำหนดส่งโปรเจกต์
        ];
        userEvents = sqliteEvents; // เก็บ events สำหรับ weekly view และการจัดการ
      });
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
    }
  }

  // ========================================
  // 🛠️ Helper Methods - ฟังก์ชันช่วยเหลือ
  // ========================================
  
  /// ดึงรายการกิจกรรมสำหรับวันที่ที่กำหนด
  /// ใช้สำหรับ TableCalendar.eventLoader
  /// 
  /// @param day วันที่ที่ต้องการดึงกิจกรรม
  /// @return List<ImportantDay> รายการกิจกรรมในวันที่นั้น
  List<ImportantDay> _getDaysFor(DateTime day) {
    // แปลง DateTime เป็น String ในรูปแบบ YYYY-MM-DD
    final dateStr =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    
    // ค้นหากิจกรรมที่มีวันที่ตรงกัน
    return allDays.where((e) => e.date == dateStr).toList();
  }

  /// ลบกิจกรรมของผู้ใช้ออกจากฐานข้อมูลและ UI
  /// รองรับการลบแบบ swipe to delete
  /// 
  /// @param day ข้อมูลกิจกรรมที่ต้องการลบ (ImportantDay)
  Future<void> _deleteUserEvent(ImportantDay day) async {
    try {
      // 🔍 ขั้นตอนที่ 1: หา event ที่ตรงกันใน SQLite
      // เปรียบเทียบตาม title, description และ date
      final eventToDelete = userEvents.firstWhere(
        (e) =>
            e.title == day.title &&
            e.description == day.description &&
            "${e.date.year.toString().padLeft(4, '0')}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}" ==
                day.date,
        orElse: () => throw Exception('Event not found'),
      );

      // 🗑️ ขั้นตอนที่ 2: ลบจาก SQLite Database
      if (eventToDelete.id != null) {
        await _eventRepo.deleteEvent(eventToDelete.id!);
      }

      // 🔄 ขั้นตอนที่ 3: อัพเดท UI State
      setState(() {
        // ลบออกจากรายการ allDays (สำหรับแสดงในปฏิทิน)
        allDays.removeWhere(
          (d) =>
              d.title == day.title &&
              d.date == day.date &&
              d.description == day.description &&
              d.color == '#03A9F4', // เฉพาะกิจกรรมผู้ใช้ (สีฟ้าน้ำทะเล)
        );
        
        // ลบออกจากรายการ userEvents (สำหรับการจัดการ)
        userEvents.removeWhere((e) => e.id == eventToDelete.id);
      });

      // ✅ ขั้นตอนที่ 4: แสดงข้อความสำเร็จ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ลบ Event สำเร็จแล้ว! 🗑️"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (err) {
      // ❌ จัดการ error ที่อาจเกิดขึ้นขณะลบ
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

  // ========================================
  // 🚀 Lifecycle Methods - วงจรชีวิตของ Widget
  // ========================================
  
  /// ฟังก์ชันที่เรียกเมื่อ Widget ถูกสร้างขึ้น
  /// ใช้สำหรับการเตรียมข้อมูลเริ่มต้น
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลทั้งหมดเมื่อเริ่มต้น
    _loadAllData();
  }

  // ========================================
  // 🎨 UI Build Methods - ฟังก์ชันสร้าง UI
  // ========================================
  
  /// สร้าง UI หลักของหน้าปฏิทิน
  /// ประกอบด้วย:
  /// 1. AppBar พร้อมปุ่มนำทางและเมนู
  /// 2. TableCalendar แสดงปฏิทินแบบเดือน
  /// 3. รายการกิจกรรมของวันที่เลือก
  /// 4. ปุ่ม Home และ Add Event
  @override
  Widget build(BuildContext context) {
    // ดึงรายการกิจกรรมของวันที่เลือก (หรือวันที่โฟกัส)
    final selectedList = _getDaysFor(_selectedDay ?? _focusedDay);

    return Scaffold(
      // 🧭 AppBar - แถบด้านบน
      appBar: AppBar(
        title: const Text('📅 KU Calendar'),
        backgroundColor: Colors.green,
        actions: [
          // 📅 ปุ่มไปยังหน้ามุมมองรายสัปดาห์
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
          // 🍔 เมนูเพิ่มเติม (ออกจากระบบ)
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
      // 📱 Body - เนื้อหาหลัก
      body: Column(
        children: [
          // 📅 ส่วนแสดงปฏิทินแบบเดือน
          TableCalendar(
            // กำหนดช่วงวันที่ที่แสดงได้
            firstDay: DateTime.utc(2020, 1, 1), // วันที่แรก
            lastDay: DateTime.utc(2035, 12, 31), // วันที่สุดท้าย
            
            // สถานะปฏิทิน
            focusedDay: _focusedDay, // วันที่โฟกัส (เดือนที่แสดง)
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day), // วันที่ที่เลือก
            
            // การจัดการการเลือกวันที่
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected; // อัพเดทวันที่ที่เลือก
                _focusedDay = focused;   // อัพเดทวันที่โฟกัส
              });
            },
            
            // โหลดกิจกรรมสำหรับแต่ละวัน
            eventLoader: _getDaysFor,
            
            // สไตล์หัวข้อ (เดือน/ปี)
            headerStyle: const HeaderStyle(titleCentered: true),

            // 🎨 Custom Calendar Builders - ส่วนปรับแต่งปฏิทิน
            calendarBuilders: CalendarBuilders(
              // สร้าง markers สำหรับแสดงกิจกรรมในแต่ละวัน
              markerBuilder: (context, date, events) {
                // ไม่แสดงอะไรถ้าไม่มีกิจกรรม
                if (events.isEmpty) return const SizedBox.shrink();
                
                // แปลง events เป็น ImportantDay objects
                final items = events.cast<ImportantDay>();
                
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: items.map((e) {
                      // แปลงสี hex เป็น Color object
                      Color markerColor;
                      try {
                        markerColor = Color(
                          int.parse(e.color.replaceFirst('#', '0xff')),
                        );
                      } catch (_) {
                        markerColor = Colors.red; // สีแดงเป็น fallback
                      }
                      
                      // สร้างจุดสีเล็กๆ แทนแต่ละกิจกรรม
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
            
            // สไตล์ปฏิทิน - ซ่อนวันที่นอกเดือน
            calendarStyle: const CalendarStyle(outsideDaysVisible: false),
          ),

          // 📋 ส่วนแสดงรายการกิจกรรมของวันที่เลือก
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
                        final isUser = day.color == '#03A9F4'; // ตรวจสอบว่าเป็นกิจกรรมของผู้ใช้หรือไม่

                        // 🎨 กำหนดสีตามประเภทของเหตุการณ์
                        Color cardColor;
                        Color iconColor;

                        if (day.color == '#FFEB3B') {
                          // วันสำคัญทั่วไป - สีเหลือง
                          cardColor = Colors.yellow.shade50;
                          iconColor = Colors.orange;
                        } else if (day.color == '#4CAF50') {
                          // วันสำคัญ KU - สีเขียว
                          cardColor = Colors.green.shade50;
                          iconColor = Colors.green;
                        } else if (day.color == '#03A9F4') {
                          // กิจกรรมผู้ใช้ - สีฟ้าน้ำทะเล
                          cardColor = Colors.blue.shade50;
                          iconColor = Colors.blue;
                        } else if (day.color == '#9C27B0') {
                          // กำหนดส่งโปรเจกต์ - สีม่วง
                          cardColor = Colors.purple.shade50;
                          iconColor = Colors.purple;
                        } else {
                          // System Events - สีฟ้าอ่อน
                          cardColor = Colors.cyan.shade50;
                          iconColor = Colors.cyan;
                        }

                        // 📄 สร้างการ์ดกิจกรรม
                        final card = Card(
                          color: cardColor,
                          child: ListTile(
                            leading: Icon(Icons.event, color: iconColor),
                            title: Text(
                              day.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(day.description),
                            // แสดงปุ่มลบเฉพาะกิจกรรมของผู้ใช้
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
                        
                        // 🔄 รองรับการลบแบบ swipe to delete สำหรับกิจกรรมของผู้ใช้
                        if (isUser) {
                          return Dismissible(
                            key: ValueKey(
                              'user-${day.date}-${day.title}-${day.description}',
                            ),
                            // พื้นหลังเมื่อ swipe ซ้าย
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
                            // พื้นหลังเมื่อ swipe ขวา
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

          // 🏠 ส่วนปุ่มนำทางและเพิ่มกิจกรรม
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🏠 ปุ่มกลับไปหน้า Dashboard
                FloatingActionButton(
                  heroTag: "homeBtn", // ต้องระบุ heroTag เพื่อไม่ให้ชนกับปุ่มอื่น
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.home),
                  onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                ),
                
                // ➕ ปุ่มเพิ่มกิจกรรมใหม่
                FloatingActionButton(
                  heroTag: "addBtn", // ต้องระบุ heroTag เพื่อไม่ให้ชนกับปุ่มอื่น
                  backgroundColor: Colors.lightGreen,
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final selectedDay = _selectedDay ?? _focusedDay;
                    
                    // นำทางไปยังหน้าเพิ่มกิจกรรม
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEventPage(
                          selectedDate: selectedDay,
                          isWeeklyEvent: true, // เปิดเป็น Weekly Event
                        ),
                      ),
                    );

                    // 🔄 รีเฟรชข้อมูลหลังจากเพิ่ม event ใหม่
                    if (result == true && mounted) {
                      await _loadAllData(); // โหลดข้อมูลใหม่
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
