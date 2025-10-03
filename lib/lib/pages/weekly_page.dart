import 'package:flutter/material.dart';

class WeeklyPage extends StatelessWidget {
  final DateTime selectedDay;
  final List<dynamic> events;   // 👈 แก้เป็น dynamic

  const WeeklyPage({
    super.key,
    required this.selectedDay,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    // ข้อมูล mock สำหรับ 1 สัปดาห์
    final weekTasks = [
      {
        "day": "5",
        "weekday": "SUNDAY",
        "color": Colors.red.shade200,
        "circleColor": Colors.red.shade700,
        "events": [],
      },
      {
        "day": "6",
        "weekday": "MONDAY",
        "color": Colors.yellow.shade200,
        "circleColor": Colors.yellow.shade700,
        "events": [],
      },
      {
        "day": "7",
        "weekday": "TUESDAY",
        "color": Colors.pink.shade200,
        "circleColor": Colors.pink.shade400,
        "events": [
          {"code": "วันสุดท้ายของการขอเทียบโอนรายวิชา", "title": ""},
          {"code": "KH80-203", "title": "Data Structures and Algorithms"},
        ],
      },
      {
        "day": "8",
        "weekday": "WEDNESDAY",
        "color": Colors.green.shade200,
        "circleColor": Colors.green.shade600,
        "events": [
          {"code": "LH4-305", "title": "Information Media for Learning"},
          {"code": "SC9-333", "title": "C Programming"},
          {"code": "SC9-333", "title": "C Programming"},
        ],
      },
      {
        "day": "9",
        "weekday": "THURSDAY",
        "color": Colors.orange.shade200,
        "circleColor": Colors.orange.shade700,
        "events": [
          {"code": "LH4-502", "title": "The Art of Living with Others"},
          {
            "code": "LH3-303",
            "title": "Business Management for Social Sustainability",
          },
        ],
      },
      {
        "day": "10",
        "weekday": "FRIDAY",
        "color": Colors.blue.shade200,
        "circleColor": Colors.blue.shade600,
        "events": [
          {"code": "LH4-604", "title": "English for Job Opportunities"},
          {"code": "LH2-205", "title": "Software Construction"},
          {"code": "SC9-330", "title": "Software Construction"},
        ],
      },
      {
        "day": "11",
        "weekday": "SATURDAY",
        "color": Colors.purple.shade200,
        "circleColor": Colors.purple.shade600,
        "events": [
          {"code": "LH4-502", "title": "Computer Architecture"},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("October 2025"),
        backgroundColor: Colors.green.shade200,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.pop(context);  // ย้อนกลับไปหน้าก่อนหน้า
            },
          ),

           // ปุ่มใหม่ (ไป Dashboard)
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.pushNamed(context, '/dashboard'); // ✅ ไปหน้า Dashboard
            },
          ),
        ],
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

            // วน loop แสดงแต่ละวัน
            ...weekTasks.map((day) {
              final events = day["events"] as List;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: day["color"] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // วันและเลขวันที่
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: day["circleColor"] as Color,
                          child: Text(
                            day["day"] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          day["weekday"] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // รายการ event ของวันนั้น
                    ...events.map((ev) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: Text(
                          ev["title"] == ""
                              ? ev["code"]
                              : "${ev["code"]}  ${ev["title"]}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
