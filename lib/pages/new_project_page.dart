// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import 'package:flutter/material.dart'; // Flutter UI framework หลัก
import '../repo/project_repository.dart'; // Repository สำหรับจัดการข้อมูลโปรเจกต์
import '../repo/user_repository.dart'; // Repository สำหรับจัดการข้อมูลผู้ใช้
import '../models/project.dart'; // Model ข้อมูลโปรเจกต์
import '../models/user.dart'; // Model ข้อมูลผู้ใช้
import '../services/auth_service.dart'; // Service สำหรับจัดการการเข้าสู่ระบบ

/// 📋 New Project Page - หน้าสร้างโปรเจกต์ใหม่
///
/// StatefulWidget สำหรับสร้างโปรเจกต์ใหม่ในระบบ
/// หน้าที่หลัก:
/// 1. รับข้อมูลโปรเจกต์จากผู้ใช้ (ชื่อ, tag, process, progress)
/// 2. เลือกวันที่ deadline สำหรับโปรเจกต์
/// 3. เลือกสมาชิกในทีมจากรายชื่อผู้ใช้ในระบบ
/// 4. บันทึกข้อมูลโปรเจกต์ลงฐานข้อมูล SQLite
/// 5. แสดง loading indicator ขณะบันทึก
/// 
/// ฟีเจอร์หลัก:
/// - กรอกชื่อโปรเจกต์
/// - เลือกวันที่ deadline (optional)
/// - เลือกสถานะ process (Plan, Doing, Review, Done)
/// - คำนวณ progress อัตโนมัติตาม process
/// - เพิ่ม/ลบสมาชิกในทีม
/// - บันทึกข้อมูลลง SQLite Database
/// 
/// การทำงาน:
/// - รับข้อมูลจากฟอร์ม
/// - ตรวจสอบข้อมูลที่จำเป็น
/// - บันทึกลงฐานข้อมูล
/// - แสดงผลการดำเนินการ

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});
  
  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

/// 🏠 State Class สำหรับ NewProjectPage
/// จัดการ state และข้อมูลทั้งหมดของหน้าสร้างโปรเจกต์
class _NewProjectPageState extends State<NewProjectPage> {
  // ========================================
  // 📝 Form Controllers & Variables - ตัวควบคุมฟอร์ม
  // ========================================
  
  /// Controller สำหรับช่องกรอกชื่อโปรเจกต์
  final nameCtrl = TextEditingController();
  
  /// Tag ของโปรเจกต์ (เริ่มต้นเป็น "Recently")
  String tag = "Recently";
  
  /// สถานะ process ของโปรเจกต์ (Plan, Doing, Review, Done)
  String process = "Plan";
  
  /// เปอร์เซ็นต์ความคืบหน้าของโปรเจกต์ (คำนวณอัตโนมัติ)
  int progress = 10;
  
  /// รายชื่อสมาชิกในทีม (เก็บเป็น username strings)
  final members = <String>[];
  
  /// รายชื่อผู้ใช้ทั้งหมดในระบบ (สำหรับเลือกเป็นสมาชิก)
  List<User> allUsers = [];
  
  /// วันที่ deadline ที่เลือก (อาจเป็น null)
  DateTime? selectedDeadline;
  
  /// สถานะการโหลด (แสดง loading indicator ขณะบันทึก)
  bool _isLoading = false;

  // ========================================
  // 🔧 Repository & Service Instances - อินสแตนซ์ของ Service
  // ========================================
  
  /// Repository สำหรับจัดการข้อมูลโปรเจกต์ในฐานข้อมูล SQLite
  final ProjectRepository _projectRepo = ProjectRepository();
  
  /// Repository สำหรับจัดการข้อมูลผู้ใช้ในฐานข้อมูล SQLite
  final UserRepository _userRepo = UserRepository();
  
  /// Service สำหรับจัดการการยืนยันตัวตนและการเข้าสู่ระบบ
  final AuthService _authService = AuthService();

  // ========================================
  // 🚀 Lifecycle Methods - วงจรชีวิตของ Widget
  // ========================================
  
  /// ฟังก์ชันที่เรียกเมื่อ Widget ถูกสร้างขึ้น
  /// ใช้สำหรับการเตรียมข้อมูลเริ่มต้น
  @override
  void initState() {
    super.initState();
    // โหลดรายชื่อผู้ใช้เมื่อเริ่มต้นหน้า
    _loadUsers();
  }

  // ========================================
  // 📊 Data Loading Methods - ฟังก์ชันโหลดข้อมูล
  // ========================================
  
  /// โหลดรายชื่อผู้ใช้ทั้งหมดจากฐานข้อมูล
  /// ใช้สำหรับแสดงในรายการเลือกสมาชิก
  Future<void> _loadUsers() async {
    try {
      // ดึงรายชื่อผู้ใช้ทั้งหมดจากฐานข้อมูล
      final users = await _userRepo.loadUsers();
      setState(() {
        allUsers = users;
      });
    } catch (e) {
      // ถ้าเกิดข้อผิดพลาด ให้ใช้รายชื่อว่าง
      setState(() {
        allUsers = [];
      });
    }
  }

  // ========================================
  // 🛠️ Helper Methods - ฟังก์ชันช่วยเหลือ
  // ========================================
  
  /// คำนวณเปอร์เซ็นต์ความคืบหน้าตามสถานะ process
  /// Plan = 10%, Doing = 50%, Review = 80%, Done = 100%
  void _recalc() {
    progress =
        {"Plan": 10, "Doing": 50, "Review": 80, "Done": 100}[process] ?? 0;
    setState(() {});
  }

  /// แสดงปฏิทินให้ผู้ใช้เลือกวันที่ deadline
  /// จำกัดช่วงวันที่ที่เลือกได้ระหว่างวันนี้ถึง 1 ปีข้างหน้า
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      // วันที่เริ่มต้น (ถ้าไม่ได้เลือกไว้ ใช้ 7 วันข้างหน้า)
      initialDate:
          selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(), // ไม่สามารถเลือกวันที่ในอดีต
      lastDate: DateTime.now().add(const Duration(days: 365)), // ไม่เกิน 1 ปี
    );
    
    // ถ้าผู้ใช้เลือกวันที่แล้ว (ไม่กด cancel)
    if (picked != null) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }

  // ========================================
  // 🎨 UI Build Methods - ฟังก์ชันสร้าง UI
  // ========================================
  
  /// สร้าง UI หลักของหน้าสร้างโปรเจกต์
  /// ประกอบด้วย:
  /// 1. AppBar พร้อมปุ่มปิด
  /// 2. ฟอร์มกรอกข้อมูลโปรเจกต์
  /// 3. ส่วนเลือก deadline
  /// 4. ส่วนเลือก process และแสดง progress
  /// 5. ส่วนจัดการสมาชิกในทีม
  /// 6. ปุ่มบันทึกข้อมูล
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // กำหนดสีพื้นหลังเป็นสีเขียวอ่อน
      backgroundColor: const Color(0xFFB7E5A2),
      
      // 🧭 AppBar - แถบด้านบน
      appBar: AppBar(
        backgroundColor: Colors.transparent, // โปร่งใส
        elevation: 0, // ไม่มีเงา
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context), // กลับไปหน้าก่อนหน้า
        ),
        title: const Text("New Project", style: TextStyle(color: Colors.black)),
      ),
      
      // 📱 Body - เนื้อหาหลัก
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF3D6), // สีครีมอ่อน
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 📝 ส่วนกรอกชื่อโปรเจกต์
            const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: _filled("Enter Project Name"),
            ),
            
            const SizedBox(height: 16),
            
            // 📅 ส่วนเลือกวันที่ deadline
            const Text(
              "Deadline",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDeadline, // เรียกฟังก์ชันเลือกวันที่
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    // แสดงวันที่ที่เลือก หรือข้อความแนะนำ
                    Text(
                      selectedDeadline != null
                          ? "${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}"
                          : "เลือกวันที่ deadline",
                      style: TextStyle(
                        color: selectedDeadline != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    // ปุ่มลบวันที่ที่เลือก (แสดงเฉพาะเมื่อมีวันที่เลือก)
                    if (selectedDeadline != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () =>
                            setState(() => selectedDeadline = null),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 📊 ส่วนเลือก process และแสดง progress
            DropdownButtonFormField<String>(
              initialValue: process,
              decoration: _filled("Process List"),
              items: const [
                "Plan",
                "Doing",
                "Review",
                "Done",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                process = v ?? "Plan";
                _recalc(); // คำนวณ progress ใหม่
              },
            ),
            const SizedBox(height: 6),
            Text("Progress: $progress%"), // แสดงเปอร์เซ็นต์ความคืบหน้า
            
            const SizedBox(height: 12),
            
            // 👥 ส่วนจัดการสมาชิกในทีม
            const Text("Member", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                // แสดงรายชื่อสมาชิกที่มีอยู่
                for (final m in members)
                  Chip(
                    label: Text(m),
                    onDeleted: () => setState(() => members.remove(m)), // ลบสมาชิก
                  ),
                // ปุ่มเพิ่มสมาชิกใหม่
                ActionChip(
                  avatar: const Icon(Icons.add),
                  label: const Text("Add"),
                  onPressed: () async {
                    final pick = await _pickFriend(context, allUsers);
                    if (pick != null && !members.contains(pick)) {
                      setState(() => members.add(pick));
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 💾 ปุ่มบันทึกข้อมูล - จัดชิดขวา
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC04D), // สีส้ม
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // ถ้ากำลังโหลด ปุ่มจะกดไม่ได้
                onPressed: _isLoading
                    ? null
                    : () async {
                        // 🔍 ตรวจสอบข้อมูลที่จำเป็นก่อนบันทึก
                        if (nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("กรอกชื่อโปรเจกต์ก่อนนะ"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // ⏳ เริ่มแสดง loading indicator
                        setState(() {
                          _isLoading = true;
                        });

                        // 📱 เก็บ context references ก่อน async operation
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        try {
                          // 🔐 ขั้นตอนที่ 1: ดึงข้อมูลผู้ใช้ปัจจุบัน
                          final currentUser = await _authService
                              .getCurrentUser();
                          if (currentUser == null) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text("กรุณาเข้าสู่ระบบก่อน"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // 🆕 ขั้นตอนที่ 2: สร้าง Project object
                          final project = Project(
                            name: nameCtrl.text.trim(),
                            tag: tag,
                            progress: progress,
                            members: members,
                            deadline: selectedDeadline != null
                                ? "${selectedDeadline!.year.toString().padLeft(4, '0')}-${selectedDeadline!.month.toString().padLeft(2, '0')}-${selectedDeadline!.day.toString().padLeft(2, '0')}"
                                : null,
                            userId: currentUser.id!, // ID ของผู้ใช้ปัจจุบัน
                          );

                          // 💾 ขั้นตอนที่ 3: บันทึกลง SQLite Database
                          await _projectRepo.addProject(project);

                          // ✅ ขั้นตอนที่ 4: แสดงข้อความสำเร็จและปิดหน้า
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text("สร้างโปรเจกต์สำเร็จแล้ว! 🎉"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            navigator.pop(
                              true,
                            ); // ส่ง true กลับไปเพื่อบอกว่าเพิ่มสำเร็จ
                          }
                        } catch (e) {
                          // ❌ จัดการ error ที่อาจเกิดขึ้นขณะบันทึก
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text("เกิดข้อผิดพลาด: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          // 🔄 ซ่อน loading indicator เสมอ
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                // แสดงข้อความในปุ่มตามสถานะ loading
                child: _isLoading
                    ? // 🔄 แสดง loading indicator ขณะบันทึก
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text("กำลังบันทึก..."),
                        ],
                      )
                    : // 💾 แสดงข้อความปกติเมื่อไม่กำลังโหลด
                      const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // 🎨 UI Helper Methods - ฟังก์ชันช่วยเหลือ UI
  // ========================================
  
  /// สร้าง InputDecoration สำหรับช่องกรอกข้อมูล
  /// มีสีพื้นหลังขาวและไม่มีขอบ
  /// 
  /// @param hint ข้อความแนะนำ (placeholder)
  /// @return InputDecoration object
  InputDecoration _filled(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none, // ไม่แสดงขอบ
    ),
  );

  /// แสดง dialog ให้ผู้ใช้เลือกสมาชิกจากรายชื่อผู้ใช้ในระบบ
  /// 
  /// @param context BuildContext สำหรับแสดง dialog
  /// @param users รายชื่อผู้ใช้ทั้งหมดในระบบ
  /// @return Future<String?> username ที่เลือก หรือ null ถ้าไม่เลือก
  Future<String?> _pickFriend(BuildContext context, List<User> users) {
    return showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("เลือกสมาชิก"),
        children: users
            .map(
              (user) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, user.username),
                child: Text(user.username),
              ),
            )
            .toList(),
      ),
    );
  }
}

