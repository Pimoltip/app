// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import 'dart:convert'; // สำหรับแปลง JSON data
import 'package:flutter/material.dart'; // Flutter UI framework หลัก
import 'package:flutter/services.dart'; // สำหรับเข้าถึง assets files
import 'package:table_calendar/table_calendar.dart'; // Library สำหรับแสดงปฏิทิน
import 'appoinment_page.dart'; // หน้านัดหมายรายวัน
import 'dashboard_page.dart'; // หน้าแดชบอร์ดหลัก
import '../models/important_day.dart'; // Model สำหรับวันสำคัญ
import '../models/event.dart'; // Model สำหรับกิจกรรม
import '../models/project.dart'; // Model สำหรับโปรเจกต์
import '../models/user.dart'; // Model สำหรับผู้ใช้
import '../repo/event_repository.dart'; // Repository สำหรับจัดการข้อมูลกิจกรรม
import '../repo/project_repository.dart'; // Repository สำหรับจัดการข้อมูลโปรเจกต์
import '../repo/user_repository.dart'; // Repository สำหรับจัดการข้อมูลผู้ใช้
import '../services/auth_service.dart'; // Service สำหรับจัดการการเข้าสู่ระบบ

/// =======================
/// 📋 PROJECT CARD WIDGET - การ์ดแสดงข้อมูลโปรเจกต์
/// =======================
/// 
/// Widget ที่แสดงข้อมูลสรุปของโปรเจกต์ พร้อมฟีเจอร์ต่างๆ:
/// 1. แสดงข้อมูลสถิติโปรเจกต์ (countdown, progress)
/// 2. คำนวณเปอร์เซ็นต์ความคืบหน้ารวม
/// 3. แสดงจำนวนวันเหลือใน countdown
/// 4. รองรับการแก้ไข progress ผ่าน dialog
/// 5. ปุ่มนำทางไปยังหน้านัดหมาย
/// 
/// ฟีเจอร์หลัก:
/// - InfoBox แสดงข้อมูลสถิติ
/// - Progress Dialog สำหรับแก้ไขสถานะ
/// - Countdown Calculation สำหรับ deadline
/// - Navigation ไปยัง Appointment Page
class ProjectCard extends StatelessWidget {
  /// Callback function ที่เรียกเมื่อแตะปุ่ม Appointment
  final VoidCallback onTapAppointment;
  
  /// รายการโปรเจกต์ที่จะแสดงใน card
  final List<Project> projects;
  
  /// Callback function สำหรับอัพเดท progress ของโปรเจกต์
  final Function(Project, int)? onProgressUpdate;

  const ProjectCard({
    super.key,
    required this.onTapAppointment,
    required this.projects,
    this.onProgressUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // ========================================
    // 📊 คำนวณข้อมูลสถิติจากโปรเจกต์
    // ========================================
    
    // นับจำนวนโปรเจกต์ทั้งหมด
    final totalProjects = projects.length;
    
    // นับจำนวนโปรเจกต์ที่กำลังดำเนินการ (progress ระหว่าง 1-99%)
    final inProgressProjects = projects
        .where((p) => p.progress > 0 && p.progress < 100)
        .length;

    // คำนวณเปอร์เซ็นต์เฉลี่ยของโปรเจกต์ที่กำลังดำเนินการ
    double averageProgress = 0;
    if (inProgressProjects > 0) {
      final progressSum = projects
          .where((p) => p.progress > 0 && p.progress < 100)
          .fold(0, (sum, p) => sum + p.progress);
      averageProgress = progressSum / inProgressProjects;
    }

    // คำนวณ countdown (จำนวนโปรเจกต์ที่มี deadline และยังไม่ครบกำหนด)
    int countdownProjects = 0;
    int totalDaysLeft = 0;
    final now = DateTime.now();

    // วนลูปผ่านโปรเจกต์ทั้งหมดเพื่อคำนวณ countdown
    for (final project in projects) {
      if (project.deadline != null) {
        try {
          final deadlineDate = DateTime.parse(project.deadline!);
          final difference = deadlineDate.difference(now).inDays;
          if (difference >= 0) {
            countdownProjects++;
            totalDaysLeft += difference;
          }
        } catch (e) {
          // หากไม่สามารถ parse วันที่ได้ ให้นับเป็น countdown project
          countdownProjects++;
        }
      }
    }

    // ========================================
    // 🎨 สร้าง UI ของ ProjectCard
    // ========================================
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50, // สีพื้นหลังสีเหลืองอ่อน
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📝 แสดงชื่อโปรเจกต์ (ใช้ชื่อโปรเจกต์แรก หรือ "Sample Project")
          Text(
            totalProjects > 0 ? projects.first.name : 'Sample Project',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          
          // 📊 แถวแสดง InfoBox ต่างๆ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 📅 InfoBox แสดงจำนวนวัน countdown
              _buildInfoBox(
                icon: Icons.calendar_today,
                title: 'Countdowns',
                value: countdownProjects > 0 ? '$totalDaysLeft' : '0',
              ),
              
              // ⏳ InfoBox แสดงเปอร์เซ็นต์ความคืบหน้า (กดได้)
              GestureDetector(
                onTap: () => _showProgressDialog(context),
                child: _buildInfoBox(
                  icon: Icons.hourglass_bottom,
                  title: 'In-Progress',
                  value: inProgressProjects > 0
                      ? '${averageProgress.round()}%'
                      : '0%',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 📅 ส่วนปุ่ม Appointment
          const Text(
            'Appointment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // 🟢 ปุ่มเปิดหน้านัดหมาย
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

  // ========================================
  // 🛠️ Helper Methods - ฟังก์ชันช่วยเหลือ
  // ========================================
  
  /// แสดง Dialog สำหรับแก้ไข Progress ของโปรเจกต์
  /// อนุญาตให้ผู้ใช้เลือกสถานะใหม่จาก dropdown
  /// 
  /// @param context BuildContext สำหรับแสดง dialog
  Future<void> _showProgressDialog(BuildContext context) async {
    if (projects.isEmpty) return;

    // กำหนดตัวเลือกสถานะและค่า progress ที่สอดคล้องกัน
    final options = ["Plan", "Doing", "Review", "Done"];
    final values = {"Plan": 10, "Doing": 50, "Review": 80, "Done": 100};

    // หาโปรเจกต์ที่ progress มากที่สุด (เป็นตัวแทนสำหรับการแสดง)
    final representativeProject = projects.reduce(
      (a, b) => a.progress > b.progress ? a : b,
    );

    // หาสถานะปัจจุบันของโปรเจกต์ตัวแทน
    final current = options.firstWhere(
      (o) => values[o] == representativeProject.progress,
      orElse: () => "Plan",
    );

    // แสดง dialog ให้ผู้ใช้เลือกสถานะใหม่
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.hourglass_bottom, color: Colors.green),
            const SizedBox(width: 8),
            const Text("แก้ไข Progress"),
          ],
        ),
        content: DropdownButton<String>(
          value: current,
          isExpanded: true,
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text("$opt (${values[opt]}%)"),
            );
          }).toList(),
          onChanged: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );

    // อัปเดต progress ของโปรเจกต์ที่เกี่ยวข้อง
    if (selected != null && selected != current) {
      final newProgress = values[selected]!;
      
      // อัปเดตทุกโปรเจกต์ที่มี progress เดียวกันกับตัวแทน
      for (final project in projects) {
        if (project.progress == representativeProject.progress) {
          // เรียก callback เพื่ออัปเดตใน parent widget
          if (onProgressUpdate != null) {
            onProgressUpdate!(project, newProgress);
          }
        }
      }
    }
  }

  /// สร้าง InfoBox Widget สำหรับแสดงข้อมูลสถิติ
  /// ใช้สำหรับแสดงข้อมูล countdown และ progress
  /// 
  /// @param icon ไอคอนที่จะแสดง
  /// @param title ชื่อข้อมูล
  /// @param value ค่าที่แสดง
  /// @return Widget InfoBox
  
  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50, // สีพื้นหลังสีเขียวอ่อน
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green), // ไอคอนสีเขียว
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.green, // สีตัวอักษรเขียว
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green, // สีตัวเลขเขียว
            ),
          ),
        ],
      ),
    );
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------
/// =======================
/// 📅 PROJECT CALENDAR - ปฏิทินโปรเจกต์
/// =======================
/// 
/// StatefulWidget สำหรับแสดงปฏิทินโปรเจกต์และข้อมูลที่เกี่ยวข้อง
/// หน้าที่หลัก:
/// 1. แสดงปฏิทินรายเดือนพร้อม event markers
/// 2. แสดงรายการกิจกรรมของวันที่เลือก
/// 3. แสดง ProjectCard พร้อมข้อมูลสถิติ
/// 4. แสดงรายชื่อสมาชิกในโปรเจกต์
/// 5. รองรับการแก้ไข progress และลบกิจกรรม
/// 
/// ฟีเจอร์หลัก:
/// - ปฏิทินแสดงวันสำคัญจากหลายแหล่ง (assets + SQLite)
/// - การ์ดแสดงสถิติโปรเจกต์
/// - รายการกิจกรรมรายวัน
/// - จัดการสมาชิกในโปรเจกต์
/// - การแก้ไขและลบข้อมูล

class ProjectCalendar extends StatefulWidget {
  /// โปรเจกต์ที่เลือกไว้ (ถ้ามี) สำหรับแสดงข้อมูลเฉพาะโปรเจกต์นั้น
  final Project? selectedProject;

  const ProjectCalendar({super.key, this.selectedProject});

  @override
  State<ProjectCalendar> createState() => _ProjectCalendarState();
}

/// 🏠 State Class สำหรับ ProjectCalendar
/// จัดการ state และข้อมูลทั้งหมดของหน้าปฏิทินโปรเจกต์
class _ProjectCalendarState extends State<ProjectCalendar> {
  // ========================================
  // 📅 Calendar State Variables - ตัวแปรสถานะปฏิทิน
  // ========================================
  
  /// วันที่กำลัง focus อยู่ในปฏิทิน
  DateTime _focusedDay = DateTime.now();
  
  /// วันที่ที่ผู้ใช้เลือก (อาจเป็น null)
  DateTime? _selectedDay;
  
  /// รายการวันสำคัญทั้งหมด (จาก assets + SQLite)
  List<ImportantDay> allDays = [];
  
  /// รายการกิจกรรมของผู้ใช้จาก SQLite
  List<Event> userEvents = [];
  
  /// รายการโปรเจกต์ของผู้ใช้จาก SQLite
  List<Project> userProjects = [];
  
  /// รายชื่อสมาชิกในโปรเจกต์
  List<User> projectMembers = [];

  // ========================================
  // 🔧 Repository & Service Instances - อินสแตนซ์ของ Service
  // ========================================
  
  /// Repository สำหรับจัดการข้อมูลกิจกรรมในฐานข้อมูล SQLite
  final EventRepository _eventRepo = EventRepository();
  
  /// Repository สำหรับจัดการข้อมูลโปรเจกต์ในฐานข้อมูล SQLite
  final ProjectRepository _projectRepo = ProjectRepository();
  
  /// Repository สำหรับจัดการข้อมูลผู้ใช้ในฐานข้อมูล SQLite
  final UserRepository _userRepo = UserRepository();
  
  /// Service สำหรับจัดการการยืนยันตัวตนและการเข้าสู่ระบบ
  final AuthService _authService = AuthService();

  // ========================================
  // 📊 Data Loading Methods - ฟังก์ชันโหลดข้อมูล
  // ========================================
  
  /// โหลดข้อมูลทั้งหมดที่จำเป็นสำหรับแสดงในปฏิทิน
  /// รวมถึงข้อมูลจาก assets และ SQLite database
  /// 
  /// ขั้นตอนการโหลด:
  /// 1. โหลดข้อมูลจาก assets files (JSON)
  /// 2. ดึงข้อมูลผู้ใช้ปัจจุบัน
  /// 3. โหลดข้อมูลจาก SQLite database
  /// 4. รวมข้อมูลทั้งหมดและแปลงเป็น ImportantDay objects
  Future<void> _loadAllData() async {
    try {
      // ========================================
      // 📁 โหลดข้อมูลจาก Assets Files
      // ========================================
      
      // โหลดข้อมูลวันสำคัญจากไฟล์ JSON
      final impData = await rootBundle.loadString('assets/important_days.json');
      final kuData = await rootBundle.loadString('assets/ku_calendar.json');
      final evtData = await rootBundle.loadString('assets/events.json');

      // แปลง JSON string เป็น List objects
      final impJson = json.decode(impData) as List;
      final kuJson = json.decode(kuData) as List;
      final evtJson = json.decode(evtData) as List;

      // ========================================
      // 🔐 ดึงข้อมูลผู้ใช้ปัจจุบัน
      // ========================================
      
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return;
      }

      // ========================================
      // 💾 โหลดข้อมูลจาก SQLite Database
      // ========================================
      
      // โหลดกิจกรรมของผู้ใช้จาก SQLite
      final sqliteEvents = await _eventRepo.loadEvents(currentUser.id!);

      // โหลดโปรเจกต์ตามเงื่อนไข (เฉพาะโปรเจกต์ที่เลือก หรือทั้งหมด)
      List<Project> sqliteProjects;
      if (widget.selectedProject != null) {
        // โหลดเฉพาะโปรเจกต์ที่เลือก
        sqliteProjects = [widget.selectedProject!];
      } else {
        // โหลดทั้งหมดจาก SQLite ตามปกติ (กรองตาม user_id)
        sqliteProjects = await _projectRepo.loadProjects(currentUser.id!);
      }

      // ========================================
      // 🔄 แปลงข้อมูลเป็น ImportantDay Objects
      // ========================================
      
      // แปลงข้อมูลวันสำคัญทั่วไป (สีเหลือง)
      final impDays = impJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#FFEB3B', // สีเหลือง
        ),
      );

      // แปลงข้อมูลปฏิทิน KU (สีเขียว)
      final kuDays = kuJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#4CAF50', // สีเขียว
        ),
      );

      // แปลงข้อมูล system events (สีน้ำเงิน)
      final sysEvents = evtJson.map(
        (e) => ImportantDay(
          title: e['title'] ?? 'System Event',
          date: e['date'],
          description: e['note'] ?? '',
          color: '#42A5F5', // สีน้ำเงิน
        ),
      );

      // แปลงข้อมูลกิจกรรมผู้ใช้จาก SQLite (สีฟ้า)
      final userEventsFromSQLite = sqliteEvents.map(
        (e) => ImportantDay(
          title: e.title,
          date:
              "${e.date.year.toString().padLeft(4, '0')}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}",
          description: e.description,
          color: '#03A9F4', // สีฟ้า
        ),
      );

      // แปลงข้อมูลโปรเจกต์จาก SQLite (สีม่วง)
      final userProjectsFromSQLite = sqliteProjects.map((p) {
        // สร้างคำอธิบายโปรเจกต์
        String description =
            "Progress: ${p.progress}% | Members: ${p.members.join(', ')}";

        // เพิ่มข้อมูล deadline และ countdown
        if (p.deadline != null) {
          try {
            final deadlineDate = DateTime.parse(p.deadline!);
            final now = DateTime.now();
            final diff = deadlineDate.difference(now).inDays;
            if (diff > 0) {
              description += " | ⏰ $diff days left";
            } else if (diff == 0) {
              description += " | ⚠️ Due today!";
            } else {
              description += " | ❌ Overdue ${-diff} days";
            }
          } catch (_) {
            description += " | Deadline: ${p.deadline}";
          }
        }

        return ImportantDay(
          title: p.name,
          date:
              p.deadline ??
              "${p.createdAt.year}-${p.createdAt.month}-${p.createdAt.day}",
          description: description,
          color: '#9C27B0', // สีม่วง
        );
      });

      // ========================================
      // 👥 โหลดข้อมูลสมาชิกในโปรเจกต์
      // ========================================
      
      List<User> members = [];
      for (final project in sqliteProjects) {
        for (final memberName in project.members) {
          final member = await _userRepo.getUserByUsername(memberName);
          if (member != null && !members.any((m) => m.id == member.id)) {
            members.add(member);
          }
        }
      }

      // ========================================
      // 🔄 อัปเดต State
      // ========================================
      
      setState(() {
        // รวมข้อมูลวันสำคัญทั้งหมด
        allDays = [
          ...impDays,
          ...kuDays,
          ...sysEvents,
          ...userEventsFromSQLite,
          ...userProjectsFromSQLite,
        ];
        
        // อัปเดตข้อมูลผู้ใช้
        userEvents = sqliteEvents;
        userProjects = sqliteProjects;
        projectMembers = members;
      });
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
    }
  }

  // ========================================
  // 🛠️ Helper Methods - ฟังก์ชันช่วยเหลือ
  // ========================================
  
  /// ดึงรายการวันสำคัญสำหรับวันที่ที่กำหนด
  /// ใช้สำหรับแสดง events ในปฏิทิน
  /// 
  /// @param day วันที่ที่ต้องการดึงข้อมูล
  /// @return List<ImportantDay> รายการวันสำคัญของวันที่นั้น
  List<ImportantDay> _getDaysFor(DateTime day) {
    // แปลงวันที่เป็น string format (YYYY-MM-DD)
    final dateStr =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    
    // กรองหาวันสำคัญที่ตรงกับวันที่
    return allDays.where((e) => e.date == dateStr).toList();
  }

  /// ลบกิจกรรมหรือโปรเจกต์ของผู้ใช้
  /// รองรับการลบทั้ง user events และ user projects
  /// 
  /// @param day ImportantDay object ที่ต้องการลบ
  Future<void> _deleteUserEvent(ImportantDay day) async {
    try {
      // ตรวจสอบประเภทของข้อมูลตามสี
      if (day.color == '#03A9F4') {
        // 🟦 ลบ User Event (สีฟ้า)
        final eventToDelete = userEvents.firstWhere(
          (e) =>
              e.title == day.title &&
              e.description == day.description &&
              "${e.date.year}-${e.date.month}-${e.date.day}" == day.date,
        );
        if (eventToDelete.id != null) {
          await _eventRepo.deleteEvent(eventToDelete.id!);
        }
        setState(() {
          userEvents.removeWhere((e) => e.id == eventToDelete.id);
          allDays.remove(day);
        });
      } else if (day.color == '#9C27B0') {
        // 🟣 ลบ User Project (สีม่วง)
        final projectToDelete = userProjects.firstWhere(
          (p) => p.name == day.title,
        );
        if (projectToDelete.id != null) {
          await _projectRepo.deleteProject(projectToDelete.id!);
        }
        setState(() {
          userProjects.removeWhere((p) => p.id == projectToDelete.id);
          allDays.remove(day);
        });
      }
    } catch (err) {
      debugPrint('❌ Delete failed: $err');
    }
  }

  /// แก้ไข progress ของโปรเจกต์ผ่าน dialog
  /// อนุญาตให้ผู้ใช้เลือกสถานะใหม่จาก dropdown
  /// 
  /// @param project โปรเจกต์ที่ต้องการแก้ไข
  Future<void> _updateProjectProgress(Project project) async {
    // กำหนดตัวเลือกสถานะและค่า progress ที่สอดคล้องกัน
    final options = ["Plan", "Doing", "Review", "Done"];
    final values = {"Plan": 10, "Doing": 50, "Review": 80, "Done": 100};

    // หาสถานะปัจจุบันของโปรเจกต์
    final current = options.firstWhere(
      (o) => values[o] == project.progress,
      orElse: () => "Plan",
    );

    // แสดง dialog ให้ผู้ใช้เลือกสถานะใหม่
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("แก้ไข Progress: ${project.name}"),
        content: DropdownButton<String>(
          value: current,
          isExpanded: true,
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text("$opt (${values[opt]}%)"),
            );
          }).toList(),
          onChanged: (v) => Navigator.pop(context, v),
        ),
      ),
    );

    // อัปเดต progress หากมีการเปลี่ยนแปลง
    if (selected != null && selected != current) {
      final newProgress = values[selected]!;
      final updated = project.copyWith(progress: newProgress);
      await _projectRepo.updateProject(updated);
      await _loadAllData(); // โหลดข้อมูลใหม่
    }
  }

  // ========================================
  // 🚀 Lifecycle Methods - วงจรชีวิตของ Widget
  // ========================================
  
  /// ฟังก์ชันที่เรียกเมื่อ Widget ถูกสร้างขึ้น
  /// ใช้สำหรับการเตรียมข้อมูลเริ่มต้น
  @override
  void initState() {
    super.initState();
    _loadAllData(); // โหลดข้อมูลทั้งหมดเมื่อเริ่มต้น
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------
  // ========================================
  // 🎨 UI Build Methods - ฟังก์ชันสร้าง UI
  // ========================================
  
  /// สร้าง UI หลักของหน้าปฏิทินโปรเจกต์
  /// ประกอบด้วย:
  /// 1. AppBar พร้อมปุ่มกลับ
  /// 2. ปฏิทินแสดงวันสำคัญ
  /// 3. ProjectCard แสดงข้อมูลสถิติ
  /// 4. รายการกิจกรรมของวันที่เลือก
  /// 5. รายชื่อสมาชิกในโปรเจกต์
  @override
  Widget build(BuildContext context) {
    // ดึงรายการวันสำคัญสำหรับวันที่ที่เลือก (หรือวันที่ focus)
    final selectedList = _getDaysFor(_selectedDay ?? _focusedDay);

    return Scaffold(
      // กำหนดสีพื้นหลังสีครีม
      backgroundColor: const Color(0xFFF5F1E9),
      
      // 🧭 AppBar - แถบด้านบน
      appBar: AppBar(
        backgroundColor: Colors.green, // สีเขียว
        title: const Text('📅 Project Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          ),
        ),
      ),
      // 📱 Body - เนื้อหาหลัก
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ========================================
            // 📅 ปฏิทินแสดงวันสำคัญ
            // ========================================
            SizedBox(
              height: 400, // กำหนดความสูงคงที่
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1), // วันแรกที่แสดงได้
                lastDay: DateTime.utc(2035, 12, 31), // วันสุดท้ายที่แสดงได้
                focusedDay: _focusedDay, // วันที่กำลัง focus
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day), // วันที่ที่เลือก
                onDaySelected: (selected, focused) => setState(() {
                  _selectedDay = selected; // อัปเดตวันที่ที่เลือก
                  _focusedDay = focused; // อัปเดตวันที่ที่ focus
                }),
                eventLoader: _getDaysFor, // ฟังก์ชันโหลด events
                headerStyle: const HeaderStyle(titleCentered: true), // จัดกึ่งกลางหัวข้อ
                calendarBuilders: CalendarBuilders(
                  // สร้าง markers สำหรับแสดง events
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox.shrink();
                    final items = events.cast<ImportantDay>();
                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: items
                            .map(
                              (e) => Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // แปลงสี hex เป็น Color object
                                  color: Color(
                                    int.parse(
                                      e.color.replaceFirst('#', '0xff'),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ========================================
            // 📋 ProjectCard - การ์ดแสดงข้อมูลโปรเจกต์
            // ========================================
            Padding(
              padding: const EdgeInsets.all(12),
              child: ProjectCard(
                projects: userProjects, // รายการโปรเจกต์ของผู้ใช้
                onTapAppointment: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentPage(
                      selectedDate: _selectedDay ?? _focusedDay, // ส่งวันที่ที่เลือกไป
                    ),
                  ),
                ),
                // Callback สำหรับอัปเดต progress ของโปรเจกต์
                onProgressUpdate: (project, newProgress) async {
                  final updated = project.copyWith(progress: newProgress);
                  await _projectRepo.updateProject(updated);
                  await _loadAllData(); // โหลดข้อมูลใหม่
                },
              ),
            ),

            // ========================================
            // 📋 รายการกิจกรรมของวันที่เลือก
            // ========================================
            Container(
              height: 200, // กำหนดความสูงคงที่
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(12),
              ),
              child: selectedList.isEmpty
                  ? const Center(child: Text("ไม่มีเหตุการณ์วันนี้"))
                  : ListView.builder(
                      itemCount: selectedList.length,
                      itemBuilder: (_, i) {
                        final day = selectedList[i];
                        final isProject = day.color == '#9C27B0'; // ตรวจสอบว่าเป็นโปรเจกต์หรือไม่
                        Project? project;
                        
                        // หาข้อมูลโปรเจกต์หากเป็นโปรเจกต์
                        if (isProject) {
                          project = userProjects.firstWhere(
                            (p) => p.name == day.title,
                          );
                        }
                        
                        return Card(
                          // กำหนดสีตามประเภท (โปรเจกต์ = ม่วง, อื่นๆ = เขียว)
                          color: isProject
                              ? Colors.purple.shade50
                              : Colors.green.shade50,
                          child: ListTile(
                            leading: Icon(
                              isProject ? Icons.work : Icons.event,
                              color: isProject ? Colors.purple : Colors.green,
                            ),
                            title: Text(
                              day.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(day.description),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ปุ่มแก้ไข progress (เฉพาะโปรเจกต์)
                                if (isProject)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () =>
                                        _updateProjectProgress(project!),
                                  ),
                                // ปุ่มลบกิจกรรม
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteUserEvent(day),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // ========================================
            // 👥 รายชื่อสมาชิกในโปรเจกต์
            // ========================================
            if (projectMembers.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, // สีพื้นหลังสีน้ำเงินอ่อน
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // หัวข้อแสดงจำนวนสมาชิก
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'สมาชิกในโปรเจกต์ (${projectMembers.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // แสดงรายชื่อสมาชิกเป็น chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: projectMembers.map((member) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100, // สีพื้นหลังสีน้ำเงินอ่อน
                            borderRadius: BorderRadius.circular(20), // มุมโค้ง
                            border: Border.all(color: Colors.blue.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                member.username,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20), // เพิ่มระยะห่างด้านล่าง
          ],
        ),
      ),
    );
  }
}
