import 'package:flutter/material.dart';
import '../models/event.dart';

class WeeklyPage extends StatelessWidget {
  final DateTime selectedDay;
  final List<Event> events;   // ใช้ model Event โดยตรง

  const WeeklyPage({
    super.key,
    required this.selectedDay,
    required this.events,
  });

  List<DateTime> getWeekDays(DateTime selectedDay) {
    final firstDayOfWeek = selectedDay.subtract(Duration(days: selectedDay.weekday % 7));
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

  @override
  Widget build(BuildContext context) {
    final weekDays = getWeekDays(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text("สัปดาห์ของ ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}"),
        backgroundColor: Colors.green.shade200,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Tasks",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...weekDays.map((day) {
              final dayEvents = events.where((e) =>
                e.date.year == day.year &&
                e.date.month == day.month &&
                e.date.day == day.day).toList();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getDayColor(day.weekday),
                  borderRadius: BorderRadius.circular(12),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // รายการ events
                    if (dayEvents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 8, top: 4),
                        child: Text(""),
                      )
                    else
                      ...dayEvents.map((ev) => Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: Text(
                          "${ev.title} - ${ev.description}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      )),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.sunday: return "SUNDAY";
      case DateTime.monday: return "MONDAY";
      case DateTime.tuesday: return "TUESDAY";
      case DateTime.wednesday: return "WEDNESDAY";
      case DateTime.thursday: return "THURSDAY";
      case DateTime.friday: return "FRIDAY";
      case DateTime.saturday: return "SATURDAY";
      default: return "";
    }
  }
}
