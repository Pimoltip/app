import 'package:flutter/material.dart';

// 📱 Pages
import 'project_calendar.dart';
import 'new_project_page.dart';
import 'calendar_page.dart';

// 🗄️ Data & Services
import '../repo/project_repository.dart';
import '../models/project.dart';
import '../services/auth_service.dart';

/// 📋 การ์ดแสดงข้อมูลโปรเจกต์
/// แสดงสถิติ countdown, in-progress และปุ่ม appointment
class ProjectCard extends StatelessWidget {
  final VoidCallback onTapAppointment; // ฟังก์ชันเมื่อกดปุ่ม appointment
  final List<Project> projects; // รายการโปรเจกต์

  const ProjectCard({
    super.key,
    required this.onTapAppointment,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    // 📊 คำนวณสถิติจากรายการโปรเจกต์
    final totalProjects = projects.length;
    final inProgressProjects = projects
        .where((p) => p.progress > 0 && p.progress < 100)
        .length;

    // ⏰ คำนวณ countdown (โปรเจกต์ที่มี deadline และยังไม่ครบกำหนด)
    int countdownProjects = 0;
    final now = DateTime.now();

    for (final project in projects) {
      if (project.deadline != null) {
        try {
          final deadlineDate = DateTime.parse(project.deadline!);
          final difference = deadlineDate.difference(now).inDays;
          if (difference >= 0) {
            countdownProjects++;
          }
        } catch (e) {
          // ถ้า parse วันที่ไม่ได้ ให้นับเป็น countdown
          countdownProjects++;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            totalProjects > 0
                ? 'My Projects ($totalProjects)'
                : 'Sample Project',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoBox(
                icon: Icons.calendar_today,
                title: 'Countdowns',
                value: countdownProjects.toString(),
              ),
              _buildInfoBox(
                icon: Icons.hourglass_bottom,
                title: 'In-Progress',
                value: '$inProgressProjects',
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

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(height: 6),
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// 🏠 หน้าแดชบอร์ดหลัก
/// แสดงโปรเจกต์ทั้งหมดและสถิติ
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 🗄️ Services สำหรับจัดการข้อมูล
  final ProjectRepository _projectRepo = ProjectRepository();
  final AuthService _authService = AuthService();

  // 📊 ข้อมูลที่แสดงในหน้า
  String userName = "Your Name"; // ชื่อผู้ใช้
  List<Project> projects = []; // รายการโปรเจกต์

  @override
  void initState() {
    super.initState();
    _loadUserData(); // โหลดข้อมูลผู้ใช้
    _loadProjects(); // โหลดรายการโปรเจกต์
  }

  /// 👤 โหลดข้อมูลผู้ใช้ที่เข้าสู่ระบบอยู่
  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          userName = user.username;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
    }
  }

  /// 📋 โหลดรายการโปรเจกต์จากฐานข้อมูล
  Future<void> _loadProjects() async {
    try {
      final projectsList = await _projectRepo.loadProjects();
      if (mounted) {
        setState(() {
          projects = projectsList;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading projects: $e');
    }
  }

  /// ✅ แสดงรายละเอียดโปรเจกต์ใน Dialog
  void _showProjectDetails(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.assignment, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                project.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label, color: Colors.amber),
                const SizedBox(width: 8),
                Text('Tag: ${project.tag}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Progress: ${project.progress}%'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, color: Colors.purple),
                const SizedBox(width: 8),
                Text('Members: ${project.members.join(', ')}'),
              ],
            ),
            if (project.deadline != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Deadline: ${project.deadline}'),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Created: ${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}',
                ),
              ],
            ),
          ],
        ),
        actions: [
          // 🗑️ ปุ่มลบโปรเจกต์
          IconButton(
            onPressed: () async {
              Navigator.pop(context); // ปิด Dialog ก่อน
              await _deleteProject(project);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'ลบโปรเจกต์',
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // ปิด Dialog ก่อน
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectCalendar(selectedProject: project),
                ),
              );
            },
            child: const Text('เปิดปฏิทิน'),
          ),
        ],
      ),
    );
  }

  /// 🗑️ ลบโปรเจกต์
  Future<void> _deleteProject(Project project) async {
    // แสดง confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบโปรเจกต์ "${project.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _projectRepo.deleteProjectByName(project.name);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ลบโปรเจกต์ "${project.name}" สำเร็จแล้ว'),
              backgroundColor: Colors.green,
            ),
          );

          // รีเฟรชรายการโปรเจกต์
          await _loadProjects();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3D6),
        elevation: 0,
        title: Text(
          "Welcome back,\n$userName", // ✅ แสดงชื่อผู้ใช้จริง
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarPage()),
            );
          },
        ),
        actions: [
          // ✅ ปุ่ม Logout
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
              child: projects.isEmpty
                  ? const Center(
                      child: Text(
                        "ยังไม่มีโปรเจกต์\nกดปุ่ม + เพื่อสร้างโปรเจกต์ใหม่",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return GestureDetector(
                          onTap: () => _showProjectDetails(project),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tag: ${project.tag}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Progress: ${project.progress}%',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: project.progress / 100,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      project.progress >= 100
                                          ? Colors.green
                                          : project.progress >= 50
                                          ? Colors.orange
                                          : Colors.blue,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (project.members.isNotEmpty)
                                    Text(
                                      'Members: ${project.members.length}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewProjectPage()),
          );

          // ✅ รีเฟรช projects หลังจากเพิ่มใหม่
          if (result == true) {
            await _loadProjects();
          }
        },
      ),
    );
  }
}
