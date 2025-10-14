// Import libraries ที่จำเป็นสำหรับการทำงาน
import 'dart:convert'; // สำหรับแปลง JSON
import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:flutter/services.dart'; // สำหรับโหลดไฟล์ assets
import '../models/event.dart'; // Model สำหรับกิจกรรม
import '../models/important_day.dart'; // Model สำหรับวันสำคัญ
import 'add_event_page.dart'; // หน้าเพิ่มกิจกรรมสำหรับ Weekly
import '../services/recurring_event_service.dart'; // Service สำหรับจัดการกิจกรรมที่ทำซ้ำ
import '../services/auth_service.dart'; // Service สำหรับจัดการการเข้าสู่ระบบ

/// 📅 หน้าตารางสัปดาห์
///
/// StatefulWidget ที่แสดงกิจกรรมในรูปแบบสัปดาห์
/// - แสดงกิจกรรมส่วนตัวจากผู้ใช้
/// - แสดงวันสำคัญจากไฟล์ important_days.json
/// - แสดงปฏิทินมหาวิทยาลัยจากไฟล์ ku_calendar.json
/// - แบ่งแสดงตามวันในสัปดาห์พร้อมสีและไอคอนที่แตกต่างกัน
/// - รองรับกิจกรรมที่ทำซ้ำ
class WeeklyPage extends StatefulWidget {
  final DateTime selectedDay; // วันที่ที่เลือกมาเพื่อแสดงสัปดาห์นั้น

  const WeeklyPage({
    super.key,
    required this.selectedDay, // จำเป็นต้องส่งวันที่มา
  });

  @override
  State<WeeklyPage> createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {
  // Services
  final RecurringEventService _recurringEventService = RecurringEventService();
  final AuthService _authService = AuthService();

  // ข้อมูลกิจกรรม
  List<Event> _allEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// 📋 โหลดข้อมูลกิจกรรมทั้งหมด (รวมกิจกรรมที่ทำซ้ำ)
  Future<void> _loadEvents() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return;
      }

      // คำนวณวันเริ่มต้นและสิ้นสุดของสัปดาห์
      final weekDays = getWeekDays(widget.selectedDay);
      final startDate = weekDays.first;
      final endDate = weekDays.last;

      // ดึงกิจกรรมทั้งหมดในช่วงสัปดาห์ (รวมกิจกรรมที่ทำซ้ำ)
      final eventsForWeek = await _recurringEventService.getEventsForDateRange(
        currentUser.id!,
        startDate,
        endDate,
      );

      setState(() {
        _allEvents = eventsForWeek;
      });
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  /// 📅 คำนวณวันทั้ง 7 วันในสัปดาห์
  ///
  /// รับวันที่ที่เลือกมาและคำนวณหาวันทั้ง 7 วันในสัปดาห์นั้น
  /// โดยเริ่มจากวันแรกของสัปดาห์ (วันจันทร์)
  List<DateTime> getWeekDays(DateTime selectedDay) {
    // หาวันแรกของสัปดาห์ (วันจันทร์)
    // weekday % 7 จะได้ 1=จันทร์, 2=อังคาร, ..., 6=เสาร์, 0=อาทิตย์
    final firstDayOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday % 7),
    );

    // สร้างรายการวันทั้ง 7 วัน โดยเพิ่มทีละวัน
    return List.generate(7, (i) => firstDayOfWeek.add(Duration(days: i)));
  }

  /// 🎨 กำหนดสีพื้นหลังสำหรับแต่ละวันในสัปดาห์
  ///
  /// รับหมายเลขวันในสัปดาห์ (1=จันทร์, 7=อาทิตย์)
  /// ส่งกลับสีพื้นหลังที่แตกต่างกันตามวัน
  Color _getDayColor(int weekday) {
    switch (weekday) {
      case DateTime.sunday: // วันอาทิตย์
        return Colors.red.shade200;
      case DateTime.monday: // วันจันทร์
        return Colors.yellow.shade200;
      case DateTime.tuesday: // วันอังคาร
        return Colors.pink.shade200;
      case DateTime.wednesday: // วันพุธ
        return Colors.green.shade200;
      case DateTime.thursday: // วันพฤหัสบดี
        return Colors.orange.shade200;
      case DateTime.friday: // วันศุกร์
        return Colors.blue.shade200;
      case DateTime.saturday: // วันเสาร์
        return Colors.purple.shade200;
      default: // กรณีอื่นๆ
        return Colors.grey.shade200;
    }
  }

  /// 🔵 กำหนดสีวงกลมแสดงหมายเลขวัน
  ///
  /// รับหมายเลขวันในสัปดาห์ (1=จันทร์, 7=อาทิตย์)
  /// ส่งกลับสีเข้มสำหรับวงกลมแสดงหมายเลขวัน
  Color _getCircleColor(int weekday) {
    switch (weekday) {
      case DateTime.sunday: // วันอาทิตย์ - สีแดงเข้ม
        return Colors.red.shade700;
      case DateTime.monday: // วันจันทร์ - สีเหลืองเข้ม
        return Colors.yellow.shade700;
      case DateTime.tuesday: // วันอังคาร - สีชมพูเข้ม
        return Colors.pink.shade400;
      case DateTime.wednesday: // วันพุธ - สีเขียวเข้ม
        return Colors.green.shade600;
      case DateTime.thursday: // วันพฤหัสบดี - สีส้มเข้ม
        return Colors.orange.shade700;
      case DateTime.friday: // วันศุกร์ - สีฟ้าเข้ม
        return Colors.blue.shade600;
      case DateTime.saturday: // วันเสาร์ - สีม่วงเข้ม
        return Colors.purple.shade600;
      default: // กรณีอื่นๆ - สีเทา
        return Colors.grey;
    }
  }

  /// 📋 โหลดข้อมูลวันสำคัญจากไฟล์ JSON
  ///
  /// อ่านไฟล์ important_days.json จาก assets
  /// แปลงข้อมูล JSON เป็น List ของ ImportantDay
  /// ส่งคืน list ว่างถ้าเกิด error ในการโหลด
  Future<List<ImportantDay>> _loadImportantDays() async {
    try {
      // โหลดข้อมูลจากไฟล์ assets/important_days.json
      final impData = await rootBundle.loadString('assets/important_days.json');

      // แปลง JSON string เป็น List
      final impJson = json.decode(impData) as List;

      // แปลงแต่ละ item ใน List เป็น ImportantDay object
      return impJson.map((json) => ImportantDay.fromJson(json)).toList();
    } catch (e) {
      // ส่งคืน list ว่างถ้าเกิด error (ไฟล์ไม่พบ หรือ JSON format ผิด)
      return [];
    }
  }

  /// 🎓 โหลดข้อมูลปฏิทิน KU จากไฟล์ JSON
  ///
  /// อ่านไฟล์ ku_calendar.json จาก assets
  /// แปลงข้อมูล JSON เป็น List ของ ImportantDay
  /// ส่งคืน list ว่างถ้าเกิด error ในการโหลด
  Future<List<ImportantDay>> _loadKUCalendar() async {
    try {
      // โหลดข้อมูลจากไฟล์ assets/ku_calendar.json
      final kuData = await rootBundle.loadString('assets/ku_calendar.json');

      // แปลง JSON string เป็น List
      final kuJson = json.decode(kuData) as List;

      // แปลงแต่ละ item ใน List เป็น ImportantDay object
      return kuJson.map((json) => ImportantDay.fromJson(json)).toList();
    } catch (e) {
      // ส่งคืน list ว่างถ้าเกิด error (ไฟล์ไม่พบ หรือ JSON format ผิด)
      return [];
    }
  }

  /// 📅 แปลง string เป็น DateTime
  ///
  /// รับ string ที่เป็นวันที่ในรูปแบบ "YYYY-MM-DD"
  /// แปลงเป็น DateTime object
  /// ส่งคืน null ถ้า string format ไม่ถูกต้อง
  DateTime? _stringToDate(String dateStr) {
    try {
      // ใช้ DateTime.parse() แปลง string เป็น DateTime
      return DateTime.parse(dateStr);
    } catch (e) {
      // ส่งคืน null ถ้า format ไม่ถูกต้อง
      return null;
    }
  }

  /// 🏗️ สร้าง UI ของหน้าตารางสัปดาห์
  @override
  Widget build(BuildContext context) {
    // คำนวณวันทั้ง 7 วันในสัปดาห์
    final weekDays = getWeekDays(widget.selectedDay);

    return Scaffold(
      // 📱 AppBar แสดงชื่อหน้าและปุ่มกลับ
      appBar: AppBar(
        title: Text(
          "WEEK OF ${widget.selectedDay.day}/${widget.selectedDay.month}/${widget.selectedDay.year}",
        ),
        backgroundColor: Colors.green.shade200, // สีพื้นหลังเขียวอ่อน
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // ไอคอนลูกศรกลับ
          onPressed: () => Navigator.pop(context), // กลับไปหน้าก่อนหน้า
        ),
      ),
      // 📋 เนื้อหาหลักของหน้า
      body: FutureBuilder<List<List<ImportantDay>>>(
        // โหลดข้อมูลจากไฟล์ JSON ทั้ง 2 ไฟล์พร้อมกัน
        future: Future.wait([_loadImportantDays(), _loadKUCalendar()]),
        builder: (context, snapshot) {
          // แสดง loading indicator ขณะโหลดข้อมูล
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // แยกข้อมูลที่โหลดมาได้
          final importantDays = snapshot.data?[0] ?? []; // วันสำคัญ
          final kuCalendar = snapshot.data?[1] ?? []; // ปฏิทิน KU

          // 📜 SingleChildScrollView สำหรับเลื่อนดูเนื้อหา
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16), // ระยะห่างจากขอบ 16 pixels
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // จัดชิดซ้าย
              children: [
                // 📝 หัวข้อหลักของหน้า
                const Text(
                  "Weekly Tasks & Events",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16), // ระยะห่าง 16 pixels
                // 🔄 สร้างการ์ดสำหรับแต่ละวันในสัปดาห์
                ...weekDays.map((day) {
                  // 📋 กรองกิจกรรมส่วนตัวที่ตรงกับวันที่ (รวมกิจกรรมที่ทำซ้ำ)
                  final dayEvents = _allEvents
                      .where(
                        (e) =>
                            e.date.year == day.year &&
                            e.date.month == day.month &&
                            e.date.day == day.day,
                      )
                      .toList();

                  // ⭐ หาวันสำคัญที่ตรงกับวันที่
                  final dayImportantDays = importantDays.where((imp) {
                    final impDate = _stringToDate(
                      imp.date,
                    ); // แปลง string เป็น DateTime
                    return impDate != null &&
                        impDate.year == day.year && // ปีตรงกัน
                        impDate.month == day.month && // เดือนตรงกัน
                        impDate.day == day.day; // วันตรงกัน
                  }).toList();

                  // 🎓 หาปฏิทิน KU ที่ตรงกับวันที่
                  final dayKUCalendar = kuCalendar.where((ku) {
                    final kuDate = _stringToDate(
                      ku.date,
                    ); // แปลง string เป็น DateTime
                    return kuDate != null &&
                        kuDate.year == day.year && // ปีตรงกัน
                        kuDate.month == day.month && // เดือนตรงกัน
                        kuDate.day == day.day; // วันตรงกัน
                  }).toList();

                  // 📦 Container การ์ดสำหรับแต่ละวัน (สามารถกดได้)
                  return GestureDetector(
                    onTap: () => _navigateToAddEvent(
                      context,
                      day,
                    ), // กดเพื่อไปหน้าเพิ่มกิจกรรม
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: 16,
                      ), // ระยะห่างด้านล่าง 16 pixels
                      padding: const EdgeInsets.all(
                        16,
                      ), // ระยะห่างภายใน 16 pixels
                      decoration: BoxDecoration(
                        color: _getDayColor(day.weekday), // สีพื้นหลังตามวัน
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // มุมโค้งมน 12 pixels
                        border: Border.all(
                          // ถ้ามีกิจกรรมพิเศษ ให้แสดงขอบสีส้ม
                          color:
                              dayImportantDays.isNotEmpty ||
                                  dayKUCalendar.isNotEmpty
                              ? Colors.orange.shade300
                              : Colors.transparent,
                          width: 2, // ความหนาของขอบ 2 pixels
                        ),
                        // เพิ่มเงาเมื่อ hover หรือกด
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // จัดชิดซ้าย
                        children: [
                          // 🗓️ ส่วนหัวของวัน (หมายเลขวัน, ชื่อวัน, ไอคอนพิเศษ)
                          Row(
                            children: [
                              // 🔵 วงกลมแสดงหมายเลขวัน
                              CircleAvatar(
                                radius: 20, // รัศมี 20 pixels
                                backgroundColor: _getCircleColor(
                                  day.weekday,
                                ), // สีตามวัน
                                child: Text(
                                  "${day.day}", // แสดงหมายเลขวัน
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, // ตัวหนา
                                    color: Colors.white, // สีขาว
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12), // ระยะห่าง 12 pixels
                              // 📝 ชื่อวัน
                              Text(
                                _weekdayName(day.weekday),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, // ตัวหนา
                                  fontSize: 18, // ขนาดฟอนต์ 18
                                ),
                              ),
                              // ⭐ ไอคอนดาวถ้ามีกิจกรรมพิเศษ
                              if (dayImportantDays.isNotEmpty ||
                                  dayKUCalendar.isNotEmpty)
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              // ➕ ไอคอนเพิ่มกิจกรรม (แสดงเสมอ)
                              const Icon(
                                Icons.add_circle_outline,
                                color: Colors.green,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8), // ระยะห่าง 8 pixels
                          // 📋 รายการกิจกรรมส่วนตัวจากผู้ใช้
                          if (dayEvents.isNotEmpty) ...[
                            const Text(
                              "📋 Personal Tasks:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            // แสดงแต่ละกิจกรรมส่วนตัว
                            ...dayEvents.map(
                              (ev) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  top: 4,
                                ), // ระยะห่างซ้าย 8, บน 4
                                child: Row(
                                  children: [
                                    // ✅ ไอคอนงาน
                                    const Icon(
                                      Icons.task_alt,
                                      size: 16, // ขนาด 16 pixels
                                      color: Colors.blue, // สีน้ำเงิน
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ), // ระยะห่าง 8 pixels
                                    // 📝 ข้อความกิจกรรม
                                    Expanded(
                                      child: Row(
                                        children: [
                                          // 🔄 ไอคอนแสดงกิจกรรมที่ทำซ้ำ
                                          if (ev.isRecurring)
                                            const Icon(
                                              Icons.repeat,
                                              size: 14,
                                              color: Colors.orange,
                                            ),
                                          if (ev.isRecurring)
                                            const SizedBox(width: 4),
                                          // 📝 ข้อความกิจกรรม
                                          Expanded(
                                            child: Text(
                                              "${ev.title} - ${ev.description}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8), // ระยะห่าง 8 pixels
                          ],

                          // ⭐ รายการวันสำคัญ
                          if (dayImportantDays.isNotEmpty) ...[
                            const Text(
                              "⭐ Important Days:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.red, // สีแดง
                              ),
                            ),
                            // แสดงแต่ละวันสำคัญ
                            ...dayImportantDays.map(
                              (imp) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  top: 4,
                                ), // ระยะห่างซ้าย 8, บน 4
                                child: Row(
                                  children: [
                                    // 🔴 วงกลมสีตามที่กำหนดใน JSON
                                    Container(
                                      width: 12, // กว้าง 12 pixels
                                      height: 12, // สูง 12 pixels
                                      decoration: BoxDecoration(
                                        color: Color(
                                          // แปลงสีจาก "#RRGGBB" เป็น Color object
                                          int.parse(
                                            imp.color.replaceFirst('#', '0xff'),
                                          ),
                                        ),
                                        shape: BoxShape.circle, // รูปวงกลม
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ), // ระยะห่าง 8 pixels
                                    // 📝 ข้อความวันสำคัญ
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // จัดชิดซ้าย
                                        children: [
                                          // 📌 ชื่อวันสำคัญ
                                          Text(
                                            imp.title,
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold, // ตัวหนา
                                              fontSize: 14,
                                            ),
                                          ),
                                          // 📄 คำอธิบายวันสำคัญ
                                          Text(
                                            imp.description,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ), // สีดำ
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8), // ระยะห่าง 8 pixels
                          ],

                          // 🎓 รายการปฏิทิน KU
                          if (dayKUCalendar.isNotEmpty) ...[
                            const Text(
                              "🎓 KU Calendar:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.green, // สีเขียว
                              ),
                            ),
                            // แสดงแต่ละกิจกรรมจากปฏิทิน KU
                            ...dayKUCalendar.map(
                              (ku) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  top: 4,
                                ), // ระยะห่างซ้าย 8, บน 4
                                child: Row(
                                  children: [
                                    // 🟢 วงกลมสีตามที่กำหนดใน JSON
                                    Container(
                                      width: 12, // กว้าง 12 pixels
                                      height: 12, // สูง 12 pixels
                                      decoration: BoxDecoration(
                                        color: Color(
                                          // แปลงสีจาก "#RRGGBB" เป็น Color object
                                          int.parse(
                                            ku.color.replaceFirst('#', '0xff'),
                                          ),
                                        ),
                                        shape: BoxShape.circle, // รูปวงกลม
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ), // ระยะห่าง 8 pixels
                                    // 📝 ข้อความปฏิทิน KU
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // จัดชิดซ้าย
                                        children: [
                                          // 📌 ชื่อกิจกรรม KU
                                          Text(
                                            ku.title,
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold, // ตัวหนา
                                              fontSize: 14,
                                            ),
                                          ),
                                          // 📄 คำอธิบายกิจกรรม KU
                                          Text(
                                            ku.description,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ), // สีดำ
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // 📭 แสดงข้อความเมื่อไม่มีกิจกรรมใดๆ
                          if (dayEvents.isEmpty &&
                              dayImportantDays.isEmpty &&
                              dayKUCalendar.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 8,
                                top: 4,
                              ), // ระยะห่างซ้าย 8, บน 4
                              child: Text(
                                " ", //วันว่าง
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 0, 0, 0), // สีดำ
                                  fontStyle: FontStyle.italic, // ตัวเอียง
                                ),
                              ),
                            ),

                          // ➕ แสดงข้อความแนะนำให้กดเพื่อเพิ่มกิจกรรม
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 8,
                              top: 8,
                            ), // ระยะห่างซ้าย 8, บน 8
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 📅 แปลงหมายเลขวันเป็นชื่อวันเป็นภาษาอังกฤษ
  ///
  /// รับหมายเลขวันในสัปดาห์ (1=จันทร์, 7=อาทิตย์)
  /// ส่งกลับชื่อวันเป็นภาษาอังกฤษตัวพิมพ์ใหญ่
  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.sunday: // วันอาทิตย์ (0)
        return "SUNDAY";
      case DateTime.monday: // วันจันทร์ (1)
        return "MONDAY";
      case DateTime.tuesday: // วันอังคาร (2)
        return "TUESDAY";
      case DateTime.wednesday: // วันพุธ (3)
        return "WEDNESDAY";
      case DateTime.thursday: // วันพฤหัสบดี (4)
        return "THURSDAY";
      case DateTime.friday: // วันศุกร์ (5)
        return "FRIDAY";
      case DateTime.saturday: // วันเสาร์ (6)
        return "SATURDAY";
      default: // กรณีอื่นๆ
        return "";
    }
  }

  /// ➕ นำทางไปหน้าเพิ่มกิจกรรมสำหรับวันที่เฉพาะ
  ///
  /// รับวันที่ที่เลือกและนำทางไปหน้า AddEventPage
  /// โดยจะส่งข้อมูลวันที่ไปให้หน้า AddEventPage เพื่อตั้งค่าเริ่มต้น
  /// และจะ refresh ข้อมูลหลังจากเพิ่มกิจกรรมเสร็จ
  void _navigateToAddEvent(BuildContext context, DateTime selectedDay) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEventPage(selectedDate: selectedDay, isWeeklyEvent: true),
      ),
    );

    // Refresh ข้อมูลหลังจากเพิ่มกิจกรรมเสร็จ
    if (result == true && mounted) {
      await _loadEvents();
    }
  }
}
