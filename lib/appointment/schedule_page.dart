import 'package:flutter/material.dart';
import 'day_selector.dart';
import 'time_line.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9), // 🔆 พื้นหลังโทนอ่อน
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'October 2025',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: const [
          // 🔆 ไอคอนปฏิทินด้านขวา
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.calendar_month, color: Colors.black87),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const DaySelector(), // 🔆 แถบเลือกวัน (ปรับสไตล์ในไฟล์ day_selector.dart ด้านล่าง)
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF2D8), // 🔆 พื้นส่วนตารางสีเขียวอ่อน
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  const TimeLine(),
                  Positioned(
                    top: 8,
                    right: 12,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.green,
                      onPressed: () {
                        // TODO: เพิ่มฟังก์ชันเพิ่มนัดหมาย
                      },
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
