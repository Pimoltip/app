import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'appoinment_page.dart';
import 'dashboard_page.dart';
import '../models/important_day.dart';
import '../models/event.dart';
import '../models/project.dart';
import '../repo/event_repository.dart';
import '../repo/project_repository.dart';

/// =======================
/// 📋 PROJECT CARD WIDGET (รวม InfoBox)
/// =======================
class ProjectCard extends StatelessWidget {
  final VoidCallback onTapAppointment;
  final List<Project> projects;
  final Function(Project, int)? onProgressUpdate;

  const ProjectCard({
    super.key,
    required this.onTapAppointment,
    required this.projects,
    this.onProgressUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // คำนวณข้อมูลจาก projects
    final totalProjects = projects.length;
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

    // คำนวณ countdown (จำนวน projects ที่มี deadline และยังไม่ครบกำหนด)
    int countdownProjects = 0;
    int totalDaysLeft = 0;
    final now = DateTime.now();

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
            totalProjects > 0 ? projects.first.name : 'Sample Project',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoBox(
                icon: Icons.calendar_today,
                title: 'Countdowns',
                value: countdownProjects > 0 ? '$totalDaysLeft' : '0',
              ),
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

  // ✅ แสดง Dialog สำหรับแก้ไข Progress
  Future<void> _showProgressDialog(BuildContext context) async {
    if (projects.isEmpty) return;

    final options = ["Plan", "Doing", "Review", "Done"];
    final values = {"Plan": 10, "Doing": 50, "Review": 80, "Done": 100};

    // หาโปรเจกต์ที่ progress มากที่สุด (เป็นตัวแทน)
    final representativeProject = projects.reduce(
      (a, b) => a.progress > b.progress ? a : b,
    );

    final current = options.firstWhere(
      (o) => values[o] == representativeProject.progress,
      orElse: () => "Plan",
    );

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

    if (selected != null && selected != current) {
      // อัปเดตทุกโปรเจกต์ที่มี progress เดียวกัน
      final newProgress = values[selected]!;
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

  // ✅ InfoBox widget ที่รวมเข้าใน ProjectCard
  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50, // 💚 สีพื้นแบบ process card
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green), // 💚 ไอคอนสีเขียว
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.green, // 💚 สีตัวอักษรเข้มกว่าพื้นเล็กน้อย
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green, // 💚 สีเลขให้ตรงกับไอคอน
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 📅 PROJECT CALENDAR
/// =======================
class ProjectCalendar extends StatefulWidget {
  final Project? selectedProject; // ✅ รับ selectedProject

  const ProjectCalendar({super.key, this.selectedProject});

  @override
  State<ProjectCalendar> createState() => _ProjectCalendarState();
}

class _ProjectCalendarState extends State<ProjectCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ImportantDay> allDays = [];
  List<Event> userEvents = [];
  List<Project> userProjects = [];
  final EventRepository _eventRepo = EventRepository();
  final ProjectRepository _projectRepo = ProjectRepository();

  Future<void> _loadAllData() async {
    try {
      final impData = await rootBundle.loadString('assets/important_days.json');
      final kuData = await rootBundle.loadString('assets/ku_calendar.json');
      final evtData = await rootBundle.loadString('assets/events.json');

      final impJson = json.decode(impData) as List;
      final kuJson = json.decode(kuData) as List;
      final evtJson = json.decode(evtData) as List;

      final sqliteEvents = await _eventRepo.loadEvents();

      // ✅ โหลดโปรเจกต์ตามเงื่อนไข
      List<Project> sqliteProjects;
      if (widget.selectedProject != null) {
        // โหลดเฉพาะโปรเจกต์ที่เลือก
        sqliteProjects = [widget.selectedProject!];
      } else {
        // โหลดทั้งหมดจาก SQLite ตามปกติ
        sqliteProjects = await _projectRepo.loadProjects();
      }

      final impDays = impJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#FFA726',
        ),
      );

      final kuDays = kuJson.map(
        (e) => ImportantDay(
          title: e['title'],
          date: e['date'],
          description: e['description'] ?? '',
          color: '#4CAF50',
        ),
      );

      // ✅ system events จาก assets/events.json
      final sysEvents = evtJson.map(
        (e) => ImportantDay(
          title: e['title'] ?? 'System Event',
          date: e['date'],
          description: e['note'] ?? '',
          color: '#42A5F5',
        ),
      );

      final userEventsFromSQLite = sqliteEvents.map(
        (e) => ImportantDay(
          title: e.title,
          date:
              "${e.date.year.toString().padLeft(4, '0')}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}",
          description: e.description,
          color: '#03A9F4',
        ),
      );

      final userProjectsFromSQLite = sqliteProjects.map((p) {
        String description =
            "Progress: ${p.progress}% | Members: ${p.members.join(', ')}";

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
          color: '#9C27B0',
        );
      });

      setState(() {
        allDays = [
          ...impDays,
          ...kuDays,
          ...sysEvents,
          ...userEventsFromSQLite,
          ...userProjectsFromSQLite,
        ];
        userEvents = sqliteEvents;
        userProjects = sqliteProjects;
      });
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
    }
  }

  List<ImportantDay> _getDaysFor(DateTime day) {
    final dateStr =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return allDays.where((e) => e.date == dateStr).toList();
  }

  Future<void> _deleteUserEvent(ImportantDay day) async {
    try {
      if (day.color == '#03A9F4') {
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

  Future<void> _updateProjectProgress(Project project) async {
    final options = ["Plan", "Doing", "Review", "Done"];
    final values = {"Plan": 10, "Doing": 50, "Review": 80, "Done": 100};

    final current = options.firstWhere(
      (o) => values[o] == project.progress,
      orElse: () => "Plan",
    );

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

    if (selected != null && selected != current) {
      final newProgress = values[selected]!;
      final updated = project.copyWith(progress: newProgress);
      await _projectRepo.updateProject(updated);
      await _loadAllData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    final selectedList = _getDaysFor(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E9),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('📅 Project Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ===== ปฏิทิน =====
            SizedBox(
              height: 400, // ✅ กำหนดความสูงคงที่
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) => setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                }),
                eventLoader: _getDaysFor,
                headerStyle: const HeaderStyle(titleCentered: true),
                calendarBuilders: CalendarBuilders(
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

            // ===== ProjectCard =====
            Padding(
              padding: const EdgeInsets.all(12),
              child: ProjectCard(
                projects: userProjects,
                onTapAppointment: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentPage(
                      selectedDate: _selectedDay ?? _focusedDay,
                    ),
                  ),
                ),
                onProgressUpdate: (project, newProgress) async {
                  final updated = project.copyWith(progress: newProgress);
                  await _projectRepo.updateProject(updated);
                  await _loadAllData();
                },
              ),
            ),

            // ===== รายการของวันที่เลือก =====
            Container(
              height: 200, // ✅ กำหนดความสูงคงที่
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
                        final isProject = day.color == '#9C27B0';
                        Project? project;
                        if (isProject) {
                          project = userProjects.firstWhere(
                            (p) => p.name == day.title,
                          );
                        }
                        return Card(
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
                                if (isProject)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () =>
                                        _updateProjectProgress(project!),
                                  ),
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
            const SizedBox(height: 20), // ✅ เพิ่มระยะห่างด้านล่าง
          ],
        ),
      ),
    );
  }
}
