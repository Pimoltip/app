import 'package:flutter/material.dart';
import 'info_box.dart';

class ProjectCard extends StatelessWidget {
  final VoidCallback onTapAppointment; // ➕ เปิดปฏิทินโปรเจกต์
  const ProjectCard({super.key, required this.onTapAppointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sample Project',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              InfoBox(
                icon: Icons.calendar_today,
                title: 'Countdowns',
                value: '45',
              ),
              InfoBox(
                icon: Icons.hourglass_bottom,
                title: 'In-Progress',
                value: '100%',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Appointment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onTapAppointment,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Open', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
/*. Widgets

widgets/project_card.dart

เป็น UI component สำหรับแสดง Project 1 อัน

แสดงสมาชิก, ชื่อโปรเจกต์, progress bar

ใช้ใน dashboard_page.dart (GridView.builder → ProjectCard)*/