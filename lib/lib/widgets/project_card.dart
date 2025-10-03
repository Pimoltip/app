import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFB7E5A2),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แถว avatar สมาชิกแบบง่าย (ตัวอักษรย่อ)
          SizedBox(
            height: 28,
            child: Stack(
              children: [
                for (int i = 0; i < project.members.length && i < 3; i++)
                  Positioned(
                    left: i * 22,
                    child: CircleAvatar(
                      radius: 14,
                      child: Text(project.members[i][0]),
                    ),
                  ),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black,
                    child: Text(
                      '${project.members.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text("Task", style: TextStyle(fontSize: 12)),
          const Spacer(),
          Slider(
            value: project.progress.toDouble(),
            min: 0,
            max: 100,
            onChanged: (_) {},
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${project.progress}'),
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