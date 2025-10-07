import 'package:flutter/material.dart';
import 'package:plannerapp/pages/projectcalendar.dart';
import '../data/tab_tag.dart';
import '../repo/in_memory_project_repo.dart';
import '../widgets/project_card.dart';
import '../models/project.dart';
import 'new_project_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final repo = InMemoryProjectRepo();
  String current = TabTag.values.first;

  @override
  Widget build(BuildContext context) {
    final items = repo.byTag(current);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3D6),
        elevation: 0,
        title: const Text(
          "Welcome back,\nYour Name",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.tune),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProjectCalendar(),
                        ),
                      );
                    },
                    child: ProjectCard(
                      project: const Project(
                        name: 'Sample Project',
                        tag: 'Today',
                        progress: 65,
                        members: ['Alice', 'Bob'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewProjectPage()),
          );
          // Optional: หลังกลับมาอาจรีเฟรชหรือโหลดจากไฟล์
        },
      ),
    );
  }
}
