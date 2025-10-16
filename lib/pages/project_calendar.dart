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
// 📋 ProjectCard ------------------------------
  @override
  Widget build(BuildContext context) { 
    // ========================================
    //📊 ส่วนที่ 1: การคำนวณข้อมูลสถิติจากโปรเจกต์
    // ========================================
    
    final totalProjects = projects.length; //เป็นการนับจำนวนโปรเจกต์ทั้งหมดในลิสต์ projects
    // นับจำนวนโปรเจกต์ที่กำลังดำเนินการ (progress ระหว่าง 1-99%)
    final inProgressProjects = projects
        .where((p) => p.progress > 0 && p.progress < 100) //เมธอด .where() เพื่อกรอง (Filter) โปรเจกต์ที่มีค่าความคืบหน้า (p.progress) อยู่ระหว่าง 1 ถึง 99 เท่านั้น
        .length; 

    // คำนวณเปอร์เซ็นต์ความคืบหน้าเฉลี่ย
    double averageProgress = 0;
    if (inProgressProjects > 0) { //โปรเจกต์ที่กำลังดำเนินการ
      final progressSum = projects
          .where((p) => p.progress > 0 && p.progress < 100)
          .fold(0, (sum, p) => sum + p.progress); //เมธอด .fold() เพื่อรวม (Sum) ค่า Progress ของทุกโปรเจกต์ที่กำลังดำเนินการ
      averageProgress = progressSum / inProgressProjects;
    }

    // ⏳ คำนวณ (Countdown) (จำนวนโปรเจกต์ที่มี deadline และยังไม่ครบกำหนด)
    int countdownProjects = 0;
    int totalDaysLeft = 0;
    final now = DateTime.now();

    // วนลูปผ่านโปรเจกต์ทั้งหมดเพื่อคำนวณ countdown
    for (final project in projects) {
      if (project.deadline != null) { //ตรวจสอบว่าโปรเจกต์นี้มีการกำหนดวันที่ส่งหรือไม่
        try {
          final deadlineDate = DateTime.parse(project.deadline!); //แปลงข้อความวันที่ (String) ของ Deadline ให้เป็นวัตถุวันที่ (DateTime) เพื่อนำมาคำนวณ
          final difference = deadlineDate.difference(now).inDays; // คำนวณ ความแตกต่าง ระหว่าง Deadline กับเวลาปัจจุบัน (now) แล้วแสดงผลเป็นจำนวนวัน (inDays)
          if (difference >= 0) { //ถ้าจำนวนวันเหลือเป็น 0 วันขึ้นไป 
            countdownProjects++; //นับเพิ่มใน countdownProjects
            totalDaysLeft += difference; //นำจำนวนวันไปรวมใน totalDaysLeft
          }
        } catch (e) {
          // หากไม่สามารถ parse วันที่ได้ ให้นับเป็น countdown project
          countdownProjects++;
        }
      }
    }//----------------จบส่วนการคำนวณข้อมูลสถิติจากโปรเจกต์----------
    ///เมื่อคำนวณข้อมูลสถิติเสร็จ(ตัวแปร totalProjects, averageProgress, totalDaysLeft ถูกกำหนดค่าแล้ว) 

    // ========================================
    // 🎨 สร้าง UI ของ ProjectCard
    // ========================================
    //🖼️ โครงสร้างและการออกแบบพื้นฐาน 
    return Container( // เป็นกล่องหลักที่บรรจุเนื้อหาทั้งหมดของ Card
      padding: const EdgeInsets.all(16), // เว้นระยะห่างด้านในกล่อง 16 หน่วยรอบทิศทาง
      decoration: BoxDecoration( //กำหนดสไตล์ให้กับกล่อง:
        color: Colors.amber.shade50, // สีพื้นหลังสีเหลืองอ่อน
        borderRadius: BorderRadius.circular(12), //มุมของกล่องมีความโค้งมน 12 หน่วย
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📝 แสดงชื่อโปรเจกต์ (ใช้ชื่อโปรเจกต์แรก หรือ "Sample Project")
          Text( // แสดงชื่อโปรเจกต์
            totalProjects > 0 ? projects.first.name : 'Sample Project',
            //หากมีโปรเจกต์ในรายการ(totalProjects > 0)ให้แสดงชื่อของโปรเจกต์แรกสุด (projects.first.name) แต่ถ้าไม่มีโปรเจกต์เลย ให้แสดงข้อความว่า 'Sample Project' แทน
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), //มีขนาดตัวอักษรเท่ากับ 15 แสดงผลเป็นตัวหนา
          ),
          const SizedBox(height: 5), // ใช้เว้นช่องว่างแนวตั้ง 5 หน่วยหลังชื่อโปรเจกต์
          
          // 📊 แถวแสดง InfoBox ต่างๆ
          Row( //ใช้จัดเรียง Widget ย่อย ๆ ให้อยู่ใน แนวนอน
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,//กระจายพื้นที่ว่างรอบ ๆ InfoBox ทั้งสองกล่องให้เท่ากัน
            children: [
              // 📅 InfoBox แสดงจำนวนวัน countdown
              _buildInfoBox( //เป็น Helper Function (ฟังก์ชันผู้ช่วย) ที่สร้างกล่องแสดงสถิติที่มีไอคอน, ชื่อ, และค่า
                // Countdowns
                icon: Icons.calendar_today,//แสดงไอคอนรูปปฏิทิน (📅)
                title: 'Countdowns', //ชื่อหัวข้อของกล่องข้อมูล
                value: countdownProjects > 0 ? '$totalDaysLeft' : '0', //แสดงค่า $totalDaysLeft (จำนวนวันเหลือรวมที่คำนวณไว้)
              ),
              
              // ⏳ InfoBox แสดงเปอร์เซ็นต์ความคืบหน้า (กดได้)
              GestureDetector( //สามารถตอบสนองต่อการสัมผัส/คลิกได้
                onTap: () => _showProgressDialog(context), //เมื่อผู้ใช้แตะที่กล่องนี้ จะเรียกฟังก์ชัน 
                child: _buildInfoBox(
                  icon: Icons.hourglass_bottom, //แสดงไอคอนรูปนาฬิกาทราย ⏳
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
          GestureDetector( //ใช้ห่อ Container ที่ทำหน้าที่เป็นปุ่ม
            onTap: onTapAppointment, // เมื่อผู้ใช้กดปุ่มนี้ จะเรียกใช้ Callback Function ที่ Widget แม่ (ProjectCalendar) ส่งมา ซึ่งฟังก์ชันนั้นจะทำหน้าที่นำทางผู้ใช้ไปยังหน้า AppointmentPage
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
  }//------------------------------จบส่วน ui  ProjectCard --------------------------------------------------

  // ========================================
  // 🛠️ Helper Methods - ฟังก์ชันช่วยเหลือ
  // ========================================
  /// แสดง Dialog สำหรับแก้ไข Progress ของโปรเจกต์
  /// @param context BuildContext สำหรับแสดง dialog

  //ฟังก์ชัน _showProgressDialog 🛠️
  Future<void> _showProgressDialog(BuildContext context) async {
    if (projects.isEmpty) return; //ตรวจสอบก่อนว่าถ้าไม่มีโปรเจกต์เลย (projects.isEmpty) ให้หยุดทำงานทันที

    // กำหนดตัวเลือกสถานะและค่า progress ที่สอดคล้องกัน
    final options = ["Plan", "Doing", "Review", "Done"];
    final values = {"Plan": 10, "Doing": 50, "Review": 80, "Done": 100};
//กำหนดตัวเลือกสถานะ (options) และค่าเปอร์เซ็นต์ความคืบหน้า (values) ที่สัมพันธ์กัน เช่น "Doing" เท่ากับ 50%.
    
    //2. หาโปรเจกต์ที่ progress มากที่สุด (เป็นตัวแทนสำหรับการแสดง)
    final representativeProject = projects.reduce( //.reduce(...): เป็นเมธอดที่ใช้หาค่าเดียวจากลิสต์ 
      (a, b) => a.progress > b.progress ? a : b, //เปรียบเทียบทีละคู่ (ในที่นี้คือหาโปรเจกต์ที่มี progress มากที่สุด)
    );

    // หาสถานะปัจจุบันของโปรเจกต์ตัวแทน
    final current = options.firstWhere( //.firstWhere(...): ใช้ค้นหา ชื่อสถานะ ("Plan", "Doing") 
      (o) => values[o] == representativeProject.progress,//ที่ตรงกับค่า Progress ของโปรเจกต์ตัวแทน เพื่อใช้เป็นค่าเริ่มต้นใน Dropdown
      orElse: () => "Plan",
    );//--------2------

    //3. แสดง dialog ให้ผู้ใช้เลือกสถานะใหม่
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
          onChanged: (v) => Navigator.pop(context, v),//เมื่อผู้ใช้เลือกค่าใหม่ (v) จะสั่งให้ Dialog ปิดลง และส่งค่า (v) ที่ผู้ใช้เลือกนั้นกลับไปให้ selected
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );//-------end--3--------------

    // 4. อัปเดต progress ของโปรเจกต์ที่เกี่ยวข้อง
    if (selected != null && selected != current) { //ตรวจสอบว่าผู้ใช้ เลือกสถานะใหม่และสถานะใหม่นั้น แตกต่าง จากสถานะเดิม
      final newProgress = values[selected]!; //แปลงชื่อสถานะที่เลือกกลับไปเป็นค่าเปอร์เซ็นต์ (int)
      
      // อัปเดตทุกโปรเจกต์ที่มี progress เดียวกันกับตัวแทน  วนลูปผ่าน ทุกโปรเจกต์ ในลิสต์
      for (final project in projects) {
        if (project.progress == representativeProject.progress) {//มี Progress เท่ากับ Progress เดิมของ โปรเจกต์ตัวแทน ก็จะถือว่าโปรเจกต์นั้นเป็นกลุ่มเดียวกันที่ต้องถูกอัปเดต
          // เรียก callback เพื่ออัปเดตใน parent widget
          if (onProgressUpdate != null) {
            onProgressUpdate!(project, newProgress); //ใช้ Callback Function ที่รับมาจาก Widget แม่ ส่งข้อมูล โปรเจกต์ และ Progress ใหม่ ไปให้
          }
        }
      }
    }//---------------end 4--------------------
  }//-------------end 🛠️ Helper Methods - ฟังก์ชันช่วยเหลือ----------------------------

  /// สร้าง InfoBox Widget สำหรับแสดงข้อมูลสถิติ
  /// ใช้สำหรับแสดงข้อมูล countdown และ progress
  /// 
  /// @param icon ไอคอนที่จะแสดง
  /// @param title ชื่อข้อมูล
  /// @param value ค่าที่แสดง
  /// @return Widget InfoBox
  // 🛠️ _buildInfoBox: ฟังก์ชันสร้างกล่องสถิติ
  
  Widget _buildInfoBox({//ค่า 3 อย่าง เพื่อกำหนดเนื้อหาของกล่องสถิติแต่ละกล่อง
    required IconData icon, //ไอคอนที่จะแสดงที่ด้านบนของกล่อง
    required String title, //ชื่อของสถิติ
    required String value, //ค่าตัวเลขหรือข้อความของสถิตินั้น
  }) {
    //🖼️ โครงสร้างและการออกแบบ (UI Structure)
    return Container( //A. Container (กล่องภายนอก)
      width: 110, //ความกว้างคงที่ 110 หน่วย
      padding: const EdgeInsets.all(12), // เว้นระยะห่าง 12 หน่วยภายในกล่อง
      decoration: BoxDecoration( //ตกแต่งรูปลักษณ์ภายนอก
        color: Colors.green.shade50, // สีพื้นหลังสีเขียวอ่อน
        borderRadius: BorderRadius.circular(12), //ทำให้มุมของกล่องโค้งมน
        boxShadow: const [ //เพิ่มเงาเล็กน้อยให้กับกล่อง ทำให้ดูมีมิติและลอยขึ้นมาจากพื้นหลัง
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),//---------------------end A----------------------------------------------------
      child: Column( //B. ใช้ Column เพื่อเรียงเนื้อหาในแนวตั้ง (จากบนลงล่าง):
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green), // ไอคอนสีเขียว
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,//ตัวหนาปานกลาง
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
      ),//--------------end B --------------------------
    );
  }
}
//--------------------------------------------end ProjectCard -------------------------------------------------------------------------------------------------
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
  DateTime _focusedDay = DateTime.now();  /// วันที่กำลัง focus อยู่ในปฏิทิน
  DateTime? _selectedDay; /// วันที่ที่ผู้ใช้เลือก (อาจเป็น null)
  List<ImportantDay> allDays = [];  /// รายการวันสำคัญทั้งหมด (จาก assets + SQLite)
  List<Event> userEvents = []; /// รายการกิจกรรมของผู้ใช้จาก SQLite
  List<Project> userProjects = [];   /// รายการโปรเจกต์ของผู้ใช้จาก SQLite
  List<User> projectMembers = []; /// รายชื่อสมาชิกในโปรเจกต์
//-------------------------------------------------------------------------------------
  
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
//--------------------------------------------------------------------
  
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
  //📊 _loadAllData(): กระบวนการโหลดและรวมข้อมูลทั้งหมด
  
  Future<void> _loadAllData() async {
    try {
      // 1..📁 โหลดข้อมูลจาก Assets Files
      // ========================================
      
      // โหลดข้อมูลวันสำคัญจากไฟล์ JSON
      final impData = await rootBundle.loadString('assets/important_days.json');
      final kuData = await rootBundle.loadString('assets/ku_calendar.json');
      final evtData = await rootBundle.loadString('assets/events.json');
//rootBundle.loadString(...): เป็นคำสั่งที่ใช้ในการ อ่านเนื้อหา ของไฟล์ที่อยู่ในโฟลเดอร์ assets ออกมาเป็นข้อความ (String)
///impData, kuData, evtData คือข้อความ JSON ที่ถูกโหลดมา
      // แปลง JSON string เป็น List objects
      final impJson = json.decode(impData) as List;
      final kuJson = json.decode(kuData) as List;
      final evtJson = json.decode(evtData) as List;
//json.decode(...) as List: ใช้ฟังก์ชัน json.decode จากไลบรารี dart:convert เพื่อ แปลงข้อความ JSON ให้กลายเป็นโครงสร้างข้อมูลของ Dart ที่ใช้งานได้
      // ------end  📁 โหลดข้อมูลจาก Assets Files-------

       // ========================================
      // 2.🔐 ดึงข้อมูลผู้ใช้ปัจจุบัน
      
      final currentUser = await _authService.getCurrentUser(); //_authService.getCurrentUser(): เรียกใช้ Service การยืนยันตัวตน เพื่อตรวจสอบว่า ผู้ใช้คนใดกำลังล็อกอินอยู่
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return; //ถ้าไม่มีผู้ใช้ล็อกอิน (currentUser == null) จะแสดงข้อความใน Console และหยุดฟังก์ชันนี้ทันที เพราะไม่สามารถโหลดข้อมูลส่วนตัวจากฐานข้อมูลได้
      }//-----------end 🔐 ดึงข้อมูลผู้ใช้ปัจจุบัน--------------------------

      // 3.💾 โหลดข้อมูลจาก SQLite Database
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
      } //------------------------------ end 3.💾 โหลดข้อมูลจาก SQLite Database-----------------------------

      // 🔄 แปลงข้อมูลเป็น ImportantDay Objects
      //A. ข้อมูลจาก JSON Assets impJson kuJson evtJson
      //B. ข้อมูลกิจกรรมผู้ใช้จาก SQLite
      
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
//----------------end B-------------------
      // C. แปลงข้อมูลโปรเจกต์จาก SQLite (สีม่วง) 
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
        );//-------------------end C ------------------------
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
  }//-----------------end------------------

  // ========================================
  // 🛠️ Helper Methods - ฟังก์ชันช่วยเหลือ
  // ========================================
  
  /// ดึงรายการวันสำคัญสำหรับวันที่ที่กำหนด
  /// ใช้สำหรับแสดง events ในปฏิทิน
  /// 
  /// @param day วันที่ที่ต้องการดึงข้อมูล
  /// @return List<ImportantDay> รายการวันสำคัญของวันที่นั้น
  
 // 📅 _getDaysFor(DateTime day)
  List<ImportantDay> _getDaysFor(DateTime day) {
    // แปลงวันที่เป็น string format (YYYY-MM-DD)
    final dateStr =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    
    // กรองหาวันสำคัญที่ตรงกับวันที่
    return allDays.where((e) => e.date == dateStr).toList();
  }//--------------------end 📅 _getDaysFor(DateTime day)----------------

  /// ลบกิจกรรมหรือโปรเจกต์ของผู้ใช้
  /// รองรับการลบทั้ง user events และ user projects
  /// 
  /// @param day ImportantDay object ที่ต้องการลบ
  
  //🗑️ _deleteUserEvent(ImportantDay day)
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
  }//---------end 🗑️ _deleteUserEvent(ImportantDay day)----------------------------------------

  /// แก้ไข progress ของโปรเจกต์ผ่าน dialog
  /// อนุญาตให้ผู้ใช้เลือกสถานะใหม่จาก dropdown
  /// 
  /// @param project โปรเจกต์ที่ต้องการแก้ไข
  
  // ✏️ _updateProjectProgress(Project project)
  Future<void> _updateProjectProgress(Project project) async {
    // กำหนดตัวเลือกสถานะและค่า progress ที่สอดคล้องกัน แสดง Dialog ให้เลือกสถานะใหม่ (Plan, Doing, Review, Done) ...
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
      final newProgress = values[selected]!; // 1. สร้าง Project object ใหม่ด้วย progress ที่แก้ไขแล้ว
      final updated = project.copyWith(progress: newProgress); // 2. บันทึกการเปลี่ยนแปลงลงฐานข้อมูล
      await _projectRepo.updateProject(updated); // 3. โหลดข้อมูลทั้งหมดซ้ำเพื่อให้ UI อัปเดต (รวมถึง ProjectCard)
      await _loadAllData(); // โหลดข้อมูลใหม่
    }
  }//----------------------end  ✏️ _updateProjectProgress(Project project)----------------

  // ========================================
  // 🚀 Lifecycle Methods - วงจรชีวิตของ Widget
  // ========================================
  
  /// ฟังก์ชันที่เรียกเมื่อ Widget ถูกสร้างขึ้น
  /// ใช้สำหรับการเตรียมข้อมูลเริ่มต้น
  @override
  void initState() { //1. วงจรชีวิต (initState)
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
            // A. 📅 ปฏิทินแสดงวันสำคัญ
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
                  },// ... สร้างจุดสี (markers) เล็กๆ ใต้วันที่ที่มี events ...
                ),
              ),
            ),//-----------------------end A. 📅 TableCalendar (ปฏิทิน)-----------------------------

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
                },// ... อัปเดต progress และเรียก _loadAllData() ...
              ),
            ),//-----------------end B. 📋 ProjectCard (การ์ดสถิติ)---------------------

            // ========================================
            // 📋 รายการกิจกรรมของวันที่เลือก
            // ========================================
            Container( // ... การตกแต่งกรอบ ...
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
                      itemBuilder: (_, i) { // ... สร้าง Card/ListTile สำหรับแต่ละกิจกรรม/โปรเจกต์ ...
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
                              children: [// ... มีปุ่มแก้ไข (เฉพาะโปรเจกต์) และปุ่มลบ (Event/Project) ...
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
            ),//---------------end C. 📋 รายการกิจกรรมของวันที่เลือก (Daily Event List)------------

            // ========================================
            // 👥 รายชื่อสมาชิกในโปรเจกต์
            // ========================================
            if (projectMembers.isNotEmpty) ...[
              Container( // ... การตกแต่งกรอบสีน้ำเงินอ่อน ...
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, // สีพื้นหลังสีน้ำเงินอ่อน
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(   // ... หัวข้อ "สมาชิกในโปรเจกต์" ...
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
                    Wrap(   // ... สร้าง Chip แสดงชื่อสมาชิก ...
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
