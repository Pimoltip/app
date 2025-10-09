import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event.dart';
import '../models/important_day.dart';

class WeeklyPage extends StatelessWidget {
  final DateTime selectedDay;
  final List<Event> events; // ใช้ model Event โดยตรง

  const WeeklyPage({
    super.key,
    required this.selectedDay,
    required this.events,
  });

  List<DateTime> getWeekDays(DateTime selectedDay) {
    final firstDayOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday % 7),
    );
    return List.generate(7, (i) => firstDayOfWeek.add(Duration(days: i)));
  }

  Color _getDayColor(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return Colors.red.shade200;
      case DateTime.monday:
        return Colors.yellow.shade200;
      case DateTime.tuesday:
        return Colors.pink.shade200;
      case DateTime.wednesday:
        return Colors.green.shade200;
      case DateTime.thursday:
        return Colors.orange.shade200;
      case DateTime.friday:
        return Colors.blue.shade200;
      case DateTime.saturday:
        return Colors.purple.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getCircleColor(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return Colors.red.shade700;
      case DateTime.monday:
        return Colors.yellow.shade700;
      case DateTime.tuesday:
        return Colors.pink.shade400;
      case DateTime.wednesday:
        return Colors.green.shade600;
      case DateTime.thursday:
        return Colors.orange.shade700;
      case DateTime.friday:
        return Colors.blue.shade600;
      case DateTime.saturday:
        return Colors.purple.shade600;
      default:
        return Colors.grey;
    }
  }

  /// โหลดข้อมูลวันสำคัญจากไฟล์ JSON
  Future<List<ImportantDay>> _loadImportantDays() async {
    try {
      final impData = await rootBundle.loadString('assets/important_days.json');
      final impJson = json.decode(impData) as List;
      return impJson.map((json) => ImportantDay.fromJson(json)).toList();
    } catch (e) {
      return []; // ส่งคืน list ว่างถ้าเกิด error
    }
  }

  /// โหลดข้อมูลปฏิทิน KU จากไฟล์ JSON
  Future<List<ImportantDay>> _loadKUCalendar() async {
    try {
      final kuData = await rootBundle.loadString('assets/ku_calendar.json');
      final kuJson = json.decode(kuData) as List;
      return kuJson.map((json) => ImportantDay.fromJson(json)).toList();
    } catch (e) {
      return []; // ส่งคืน list ว่างถ้าเกิด error
    }
  }

  /// แปลง string เป็น DateTime
  DateTime? _stringToDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = getWeekDays(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "สัปดาห์ของ ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}",
        ),
        backgroundColor: Colors.green.shade200,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<List<ImportantDay>>>(
        future: Future.wait([_loadImportantDays(), _loadKUCalendar()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final importantDays = snapshot.data?[0] ?? [];
          final kuCalendar = snapshot.data?[1] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Tasks & Events",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ...weekDays.map((day) {
                  final dayEvents = events
                      .where(
                        (e) =>
                            e.date.year == day.year &&
                            e.date.month == day.month &&
                            e.date.day == day.day,
                      )
                      .toList();

                  // หาวันสำคัญที่ตรงกับวันที่
                  final dayImportantDays = importantDays.where((imp) {
                    final impDate = _stringToDate(imp.date);
                    return impDate != null &&
                        impDate.year == day.year &&
                        impDate.month == day.month &&
                        impDate.day == day.day;
                  }).toList();

                  // หาปฏิทิน KU ที่ตรงกับวันที่
                  final dayKUCalendar = kuCalendar.where((ku) {
                    final kuDate = _stringToDate(ku.date);
                    return kuDate != null &&
                        kuDate.year == day.year &&
                        kuDate.month == day.month &&
                        kuDate.day == day.day;
                  }).toList();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getDayColor(day.weekday),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            dayImportantDays.isNotEmpty ||
                                dayKUCalendar.isNotEmpty
                            ? Colors.orange.shade300
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // หัววัน
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _getCircleColor(day.weekday),
                              child: Text(
                                "${day.day}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _weekdayName(day.weekday),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            if (dayImportantDays.isNotEmpty ||
                                dayKUCalendar.isNotEmpty)
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // รายการ events จาก user
                        if (dayEvents.isNotEmpty) ...[
                          const Text(
                            "📋 Personal Tasks:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          ...dayEvents.map(
                            (ev) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.task_alt,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${ev.title} - ${ev.description}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // รายการวันสำคัญ
                        if (dayImportantDays.isNotEmpty) ...[
                          const Text(
                            "⭐ Important Days:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                          ...dayImportantDays.map(
                            (imp) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        int.parse(
                                          imp.color.replaceFirst('#', '0xff'),
                                        ),
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          imp.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          imp.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // รายการปฏิทิน KU
                        if (dayKUCalendar.isNotEmpty) ...[
                          const Text(
                            "🎓 KU Calendar:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                          ...dayKUCalendar.map(
                            (ku) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        int.parse(
                                          ku.color.replaceFirst('#', '0xff'),
                                        ),
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ku.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          ku.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
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

                        // แสดงข้อความถ้าไม่มีกิจกรรมใดๆ
                        if (dayEvents.isEmpty &&
                            dayImportantDays.isEmpty &&
                            dayKUCalendar.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(left: 8, top: 4),
                            child: Text(
                              "ไม่มีกิจกรรมในวันนี้",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
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

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return "SUNDAY";
      case DateTime.monday:
        return "MONDAY";
      case DateTime.tuesday:
        return "TUESDAY";
      case DateTime.wednesday:
        return "WEDNESDAY";
      case DateTime.thursday:
        return "THURSDAY";
      case DateTime.friday:
        return "FRIDAY";
      case DateTime.saturday:
        return "SATURDAY";
      default:
        return "";
    }
  }
}
