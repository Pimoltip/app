// Import Flutter framework สำหรับสร้าง UI
import 'package:flutter/material.dart';

// 📱 Import หน้าต่างๆ ที่เกี่ยวข้อง
import 'project_calendar.dart'; // หน้าปฏิทินโปรเจกต์
import 'new_project_page.dart'; // หน้าเพิ่มโปรเจกต์ใหม่
import 'calendar_page.dart'; // หน้าปฏิทินทั่วไป

// 🗄️ Import ข้อมูลและบริการ
import '../repo/project_repository.dart'; // จัดการข้อมูลโปรเจกต์
import '../models/project.dart'; // โครงสร้างข้อมูลโปรเจกต์
import '../services/auth_service.dart'; // บริการ authentication

/// 📋 การ์ดแสดงข้อมูลโปรเจกต์
///
/// StatelessWidget ที่แสดงสถิติโปรเจกต์และปุ่ม appointment
/// - แสดงจำนวนโปรเจกต์ทั้งหมด
/// - แสดงจำนวนโปรเจกต์ที่มี countdown (ใกล้ครบกำหนด)
/// - แสดงจำนวนโปรเจกต์ที่กำลังดำเนินการ
/// - มีปุ่มสำหรับไปหน้านัดหมาย
class ProjectCard extends StatelessWidget {
  // ฟังก์ชันที่จะเรียกเมื่อผู้ใช้กดปุ่ม appointment
  final VoidCallback onTapAppointment;

  // รายการโปรเจกต์ทั้งหมดที่ใช้คำนวณสถิติ
  final List<Project> projects;

  const ProjectCard({
    super.key,
    required this.onTapAppointment, // จำเป็นต้องส่งฟังก์ชันมา
    required this.projects, // จำเป็นต้องส่งรายการโปรเจกต์มา
  });

  @override
  Widget build(BuildContext context) {
    // 📊 คำนวณสถิติจากรายการโปรเจกต์

    // จำนวนโปรเจกต์ทั้งหมด = จำนวนรายการใน List
    final totalProjects = projects.length;

    // จำนวนโปรเจกต์ที่กำลังดำเนินการ (ความคืบหน้า 0 < progress < 100)
    // where() = กรองเฉพาะโปรเจกต์ที่ตรงเงื่อนไข
    final inProgressProjects = projects
        .where((p) => p.progress > 0 && p.progress < 100)
        .length;

    // ⏰ คำนวณ countdown (โปรเจกต์ที่มี deadline และยังไม่ครบกำหนด)
    int countdownProjects = 0;
    final now = DateTime.now(); // เวลาปัจจุบัน

    // วนลูปผ่านทุกโปรเจกต์เพื่อตรวจสอบ deadline
    for (final project in projects) {
      // ตรวจสอบว่าโปรเจกต์มี deadline หรือไม่
      if (project.deadline != null) {
        try {
          // แปลง String deadline เป็น DateTime
          final deadlineDate = DateTime.parse(project.deadline!);

          // คำนวณจำนวนวันที่เหลือ (deadline - วันนี้)
          final difference = deadlineDate.difference(now).inDays;

          // ถ้ายังไม่ครบกำหนด (จำนวนวัน >= 0) นับเป็น countdown
          if (difference >= 0) {
            countdownProjects++;
          }
        } catch (e) {
          // ถ้า parse วันที่ไม่ได้ (รูปแบบผิด) ให้นับเป็น countdown
          countdownProjects++;
        }
      }
    }

    return Container(
      // กำหนด padding (ระยะห่างภายใน) ทุกด้าน 16 pixels
      padding: const EdgeInsets.all(16),

      // กำหนดการตกแต่ง (สี, มุมโค้ง)
      decoration: BoxDecoration(
        color: Colors.amber.shade50, // สีพื้นหลังสีเหลืองอ่อน
        borderRadius: BorderRadius.circular(12), // มุมโค้ง 12 pixels
      ),

      child: Column(
        // จัดตำแหน่ง children ไปทางซ้าย
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดงหัวข้อการ์ด
          Text(
            // ถ้ามีโปรเจกต์ แสดงจำนวน, ถ้าไม่มี แสดง "Sample Project"
            totalProjects > 0
                ? 'My Projects ($totalProjects)'
                : 'Sample Project',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),

          // ระยะห่าง 5 pixels
          const SizedBox(height: 5),

          // แสดงสถิติในรูปแบบแถว (2 กล่อง)
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // กระจายพื้นที่เท่ากัน
            children: [
              // กล่องแสดงจำนวน countdown
              _buildInfoBox(
                icon: Icons.calendar_today, // ไอคอนปฏิทิน
                title: 'Countdowns', // หัวข้อ
                value: countdownProjects.toString(), // ค่า (จำนวน)
              ),

              // กล่องแสดงจำนวน in-progress
              _buildInfoBox(
                icon: Icons.hourglass_bottom, // ไอคอนนาฬิกาทราย
                title: 'In-Progress', // หัวข้อ
                value: '$inProgressProjects', // ค่า (จำนวน)
              ),
            ],
          ),

          // ระยะห่าง 24 pixels
          const SizedBox(height: 24),

          // หัวข้อปุ่ม appointment
          const Text(
            'Appointment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          // ระยะห่าง 20 pixels
          const SizedBox(height: 20),

          // ปุ่ม appointment ที่สามารถกดได้
          GestureDetector(
            onTap: onTapAppointment, // เรียกฟังก์ชันที่ส่งมาเมื่อกด
            child: Container(
              // กำหนด padding ภายในปุ่ม
              padding: const EdgeInsets.all(12),

              // กำหนดการตกแต่งปุ่ม
              decoration: BoxDecoration(
                color: Colors.green, // สีพื้นหลังเขียว
                borderRadius: BorderRadius.circular(8), // มุมโค้ง 8 pixels
              ),

              // ข้อความในปุ่ม
              child: const Text('Open', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  /// สร้างกล่องแสดงข้อมูลสถิติ
  ///
  /// รับพารามิเตอร์:
  /// - icon: ไอคอนที่จะแสดง
  /// - title: หัวข้อของข้อมูล
  /// - value: ค่าของข้อมูล (ตัวเลข)
  Widget _buildInfoBox({
    required IconData icon, // ไอคอน (จำเป็น)
    required String title, // หัวข้อ (จำเป็น)
    required String value, // ค่า (จำเป็น)
  }) {
    return Container(
      width: 120, // ความกว้างคงที่ 120 pixels
      padding: const EdgeInsets.all(12), // padding ภายใน 12 pixels
      // การตกแต่งกล่อง
      decoration: BoxDecoration(
        color: Colors.white, // สีพื้นหลังขาว
        borderRadius: BorderRadius.circular(12), // มุมโค้ง 12 pixels
        boxShadow: const [
          BoxShadow(
            // เงา
            color: Colors.black12, // สีเงา (ดำโปร่งใส 12%)
            blurRadius: 4, // ความเบลอ 4 pixels
          ),
        ],
      ),

      child: Column(
        children: [
          // ไอคอนสีเขียว
          Icon(icon, color: Colors.green),

          // ระยะห่าง 6 pixels
          const SizedBox(height: 6),

          // หัวข้อ
          Text(title),

          // ค่าตัวเลข (ตัวหนา)
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
-----------------------------------------------------------------------------------------------
/// 🏠 หน้าแดชบอร์ดหลัก
///
/// StatefulWidget ที่แสดงโปรเจกต์ทั้งหมดและสถิติ
/// - แสดงการ์ดสถิติโปรเจกต์
/// - แสดงรายการโปรเจกต์ในรูปแบบกริด
/// - มีฟังก์ชันค้นหา, เพิ่ม, ลบ, แก้ไขโปรเจกต์
/// - มีการนำทางไปหน้าอื่นๆ
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 🗄️ Services สำหรับจัดการข้อมูล
  final ProjectRepository _projectRepo =
      ProjectRepository(); // จัดการข้อมูลโปรเจกต์
  final AuthService _authService = AuthService(); // จัดการการเข้าสู่ระบบ

  // 📊 State variables - ข้อมูลที่เปลี่ยนแปลงได้
  String userName = "Your Name"; // ชื่อผู้ใช้ที่เข้าสู่ระบบ
  List<Project> projects = []; // รายการโปรเจกต์ทั้งหมด
  List<Project> filteredProjects = []; // รายการโปรเจกต์ที่กรองแล้ว
  String searchQuery = ""; // คำค้นหา

  /// ฟังก์ชันที่เรียกเมื่อ widget ถูกสร้าง
  /// จะโหลดข้อมูลเริ่มต้นสำหรับหน้าแดชบอร์ด
  @override
  void initState() {
    super.initState();
    _loadUserData(); // โหลดข้อมูลผู้ใช้ที่เข้าสู่ระบบ
    _loadProjects(); // โหลดรายการโปรเจกต์ทั้งหมด
  }

  /// 👤 โหลดข้อมูลผู้ใช้ที่เข้าสู่ระบบอยู่
  ///
  /// เรียก AuthService เพื่อดึงข้อมูลผู้ใช้ปัจจุบัน
  /// และอัปเดต userName เพื่อแสดงใน UI
  Future<void> _loadUserData() async {
    try {
      // เรียก service เพื่อดึงข้อมูลผู้ใช้
      final user = await _authService.getCurrentUser();

      // ตรวจสอบว่าได้ข้อมูลผู้ใช้และ widget ยังคงอยู่ในหน้าจอ
      if (user != null && mounted) {
        setState(() {
          userName = user.username; // อัปเดตชื่อผู้ใช้
        });
      }
    } catch (e) {
      // แสดง error ใน debug console
      debugPrint('❌ Error loading user data: $e');
    }
  }

  /// 📋 โหลดรายการโปรเจกต์จากฐานข้อมูล
  ///
  /// เรียก ProjectRepository เพื่อดึงโปรเจกต์ทั้งหมดของผู้ใช้ปัจจุบัน
  /// และอัปเดต projects list เพื่อแสดงใน UI
  Future<void> _loadProjects() async {
    try {
      // 🔐 ดึงข้อมูลผู้ใช้ปัจจุบัน
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return;
      }

      // เรียก repository เพื่อดึงรายการโปรเจกต์ (กรองตาม user_id)
      final projectsList = await _projectRepo.loadProjects(currentUser.id!);

      // ตรวจสอบว่า widget ยังคงอยู่ในหน้าจอ
      if (mounted) {
        setState(() {
          projects = projectsList; // อัปเดตรายการโปรเจกต์
          _filterProjects(); // กรองโปรเจกต์ตามคำค้นหา
        });
      }
    } catch (e) {
      // แสดง error ใน debug console
      debugPrint('❌ Error loading projects: $e');
    }
  }

  /// 🔍 กรองโปรเจกต์ตามคำค้นหา
  ///
  /// ค้นหาโปรเจกต์ที่ชื่อตรงกับคำค้นหา (case-insensitive)
  /// และอัปเดต filteredProjects list
  void _filterProjects() {
    if (searchQuery.isEmpty) {
      // ถ้าไม่มีคำค้นหา แสดงโปรเจกต์ทั้งหมด
      filteredProjects = List.from(projects);
    } else {
      // กรองโปรเจกต์ที่ชื่อมีคำค้นหา
      filteredProjects = projects
          .where(
            (project) =>
                project.name.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }
  }

  /// 🔍 ค้นหาโปรเจกต์
  ///
  /// เรียกเมื่อผู้ใช้พิมพ์คำค้นหา
  /// อัปเดต searchQuery และกรองโปรเจกต์ใหม่
  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _filterProjects();
    });
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
              onChanged: _onSearchChanged, // ✅ เพิ่มฟังก์ชันค้นหา
              decoration: InputDecoration(
                hintText: "ค้นหาโปรเจกต์...",
                prefixIcon: const Icon(Icons.search),
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
                  : filteredProjects.isEmpty && searchQuery.isNotEmpty
                  ? const Center(
                      child: Text(
                        "ไม่พบโปรเจกต์ที่ค้นหา\nลองใช้คำค้นหาอื่น",
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
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
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
