/// =======================
/// 📋 PROJECT MODEL - โครงสร้างข้อมูลโปรเจกต์
/// =======================
/// 
/// Data class ที่เก็บข้อมูลโปรเจกต์ทั้งหมดในระบบ
/// หน้าที่หลัก:
/// 1. เก็บข้อมูลโปรเจกต์พื้นฐาน (ชื่อ, ประเภท, ความคืบหน้า)
/// 2. จัดการข้อมูลสมาชิกและกำหนดส่ง
/// 3. รองรับการแปลงข้อมูลระหว่างรูปแบบต่างๆ
/// 4. จัดการความสัมพันธ์กับผู้ใช้
/// 5. รองรับการอัปเดตข้อมูลแบบ selective
/// 
/// ฟีเจอร์หลัก:
/// - Project Data Storage
/// - Progress Tracking
/// - Team Management
/// - Deadline Management
/// - Database Integration
/// - Selective Updates
/// 
/// การทำงาน:
/// - ใช้เป็น Model สำหรับเก็บข้อมูลในฐานข้อมูล SQLite
/// - รองรับการติดตามความคืบหน้า (0-100%)
/// - จัดการข้อมูลสมาชิกในโปรเจกต์
/// - รองรับการกำหนด deadline
/// - แปลงข้อมูลระหว่าง Dart object และ database
/// 
/// ระบบการจัดการ:
/// - การติดตามความคืบหน้า
/// - การจัดการสมาชิก
/// - การกำหนด deadline
/// - การจัดหมวดหมู่โปรเจกต์
class Project {
  // ========================================
  // 📊 Basic Project Properties - ข้อมูลโปรเจกต์พื้นฐาน
  // ========================================
  
  /// ID ในฐานข้อมูล (nullable)
  /// - null: เมื่อสร้างโปรเจกต์ใหม่ (ยังไม่ได้บันทึกลงฐานข้อมูล)
  /// - int: เมื่อดึงข้อมูลจากฐานข้อมูล
  final int? id;
  
  /// ชื่อโปรเจกต์ (จำเป็นต้องมี)
  /// - ชื่อหรือหัวข้อของโปรเจกต์
  /// - ใช้ในการแสดงผลใน UI
  /// - ใช้ในการระบุโปรเจกต์
  final String name;
  
  /// ประเภทโปรเจกต์ (จำเป็นต้องมี)
  /// - ใช้สำหรับจัดหมวดหมู่โปรเจกต์
  /// - ค่าที่เป็นไปได้: "Recently", "Today", "Upcoming", "Later"
  /// - ใช้ในการกรองและจัดเรียงโปรเจกต์
  final String tag;
  
  /// ความคืบหน้าของโปรเจกต์ (จำเป็นต้องมี)
  /// - ค่าตั้งแต่ 0-100 (เปอร์เซ็นต์)
  /// - 0 = ยังไม่เริ่ม, 100 = เสร็จสมบูรณ์
  /// - ใช้ในการแสดงผล progress bar
  final int progress;
  
  /// รายชื่อสมาชิกในโปรเจกต์ (จำเป็นต้องมี)
  /// - รายการชื่อสมาชิกที่ทำงานในโปรเจกต์
  /// - ใช้ในการแสดงผลและจัดการทีม
  /// - รองรับสมาชิกหลายคน
  final List<String> members;
  
  /// กำหนดส่งโปรเจกต์ (nullable)
  /// - รูปแบบ: "YYYY-MM-DD"
  /// - null: ไม่มีการกำหนด deadline
  /// - ใช้ในการแจ้งเตือนและติดตาม
  final String? deadline;
  
  /// ID ของผู้ใช้เจ้าของโปรเจกต์ (จำเป็นต้องมี)
  /// - เชื่อมโยงโปรเจกต์กับผู้ใช้
  /// - ใช้ในการกรองโปรเจกต์ตามผู้ใช้
  final int userId;
  
  /// วันที่สร้างโปรเจกต์
  /// - ใช้ในการติดตามเวลาที่สร้างโปรเจกต์
  /// - ใช้ในการเรียงลำดับโปรเจกต์
  final DateTime createdAt;

  // ========================================
  // 🔧 Constructor - ฟังก์ชันสร้าง Project Object
  // ========================================
  
  /// Constructor สำหรับสร้าง Project object
  /// 
  /// @param id ID ในฐานข้อมูล (nullable) - null สำหรับโปรเจกต์ใหม่
  /// @param name ชื่อโปรเจกต์ (จำเป็น) - ชื่อหรือหัวข้อของโปรเจกต์
  /// @param tag ประเภทโปรเจกต์ (จำเป็น) - หมวดหมู่ของโปรเจกต์
  /// @param progress ความคืบหน้า 0-100 (จำเป็น) - เปอร์เซ็นต์ความคืบหน้า
  /// @param members รายชื่อสมาชิก (จำเป็น) - รายการสมาชิกในโปรเจกต์
  /// @param deadline กำหนดส่ง (nullable) - วันที่ส่งในรูปแบบ YYYY-MM-DD
  /// @param userId ID ของผู้ใช้เจ้าของโปรเจกต์ (จำเป็น) - เชื่อมโยงกับผู้ใช้
  /// @param createdAt วันที่สร้าง (optional) - ถ้าไม่ระบุ จะใช้เวลาปัจจุบัน
  /// 
  /// การใช้งาน:
  /// - สร้างโปรเจกต์ใหม่: Project(name: "My Project", tag: "Today", progress: 0, ...)
  /// - สร้างโปรเจกต์จากฐานข้อมูล: Project.fromMap(mapData)
  /// - อัปเดตโปรเจกต์: project.copyWith(progress: 50)
  /// 
  /// ข้อควรระวัง:
  /// - ข้อมูลที่จำเป็นต้องส่งมา: name, tag, progress, members, userId
  /// - createdAt จะถูกตั้งค่าอัตโนมัติหากไม่ระบุ
  /// - progress ควรอยู่ระหว่าง 0-100
  /// - deadline ควรเป็นรูปแบบ YYYY-MM-DD
  Project({
    this.id,
    required this.name, // จำเป็นต้องส่งมา - ชื่อโปรเจกต์
    required this.tag, // จำเป็นต้องส่งมา - ประเภทโปรเจกต์
    required this.progress, // จำเป็นต้องส่งมา - ความคืบหน้า (0-100)
    required this.members, // จำเป็นต้องส่งมา - รายชื่อสมาชิก
    this.deadline, // ไม่จำเป็น (nullable) - กำหนดส่ง
    required this.userId, // จำเป็นต้องส่งมา - ID ของผู้ใช้เจ้าของโปรเจกต์
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(); // ถ้าไม่ระบุ ใช้เวลาปัจจุบัน

  // ========================================
  // 🗄️ Database Methods - ฟังก์ชันจัดการฐานข้อมูล
  // ========================================
  
  /// แปลง Project object เป็น Map สำหรับบันทึกลงฐานข้อมูล SQLite
  /// 
  /// @return Map<String, dynamic> ข้อมูลที่พร้อมบันทึกลงฐานข้อมูล
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. แปลง List<String> เป็น String คั่นด้วย comma
  /// 2. แปลง DateTime เป็น String (ISO format)
  /// 3. จัดรูปแบบข้อมูลให้ตรงกับโครงสร้างตารางในฐานข้อมูล
  /// 
  /// การใช้งาน:
  /// - บันทึกโปรเจกต์ใหม่ลงฐานข้อมูล
  /// - อัปเดตข้อมูลโปรเจกต์ที่มีอยู่
  /// - ส่งข้อมูลไปยัง ProjectRepository
  /// 
  /// ข้อควรระวัง:
  /// - List<String> จะถูกแปลงเป็น string คั่นด้วย comma
  /// - DateTime จะถูกแปลงเป็น ISO string format
  /// - null values จะถูกเก็บเป็น null
  /// - ข้อมูลจะถูกจัดรูปแบบให้ตรงกับ database schema
  Map<String, dynamic> toMap() => {
    'id': id, // ID ในฐานข้อมูล (nullable)
    'name': name, // ชื่อโปรเจกต์
    'tag': tag, // ประเภทโปรเจกต์
    'progress': progress, // ความคืบหน้า (0-100)
    'members': members.join(','), // แปลง List<String> เป็น String คั่นด้วย comma
    'deadline': deadline, // กำหนดส่ง (nullable)
    'user_id': userId, // ID ของผู้ใช้เจ้าของโปรเจกต์
    'created_at': createdAt.toIso8601String(), // แปลง DateTime เป็น String (ISO format)
  };

  /// สร้าง Project object จาก Map ที่ได้จากฐานข้อมูล SQLite
  /// 
  /// @param map Map ที่ได้จากฐานข้อมูล SQLite
  /// @return Project object ที่สร้างจากข้อมูลในฐานข้อมูล
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. แปลง String กลับเป็น List<String>
  /// 2. แปลง String กลับเป็น DateTime
  /// 3. กรอง empty strings ออกจาก members list
  /// 4. สร้าง Project object ด้วยข้อมูลที่แปลงแล้ว
  /// 
  /// การใช้งาน:
  /// - ดึงข้อมูลโปรเจกต์จากฐานข้อมูล
  /// - แปลงข้อมูลจาก SQLite query results
  /// - สร้าง Project objects จาก database rows
  /// 
  /// ข้อควรระวัง:
  /// - ต้องตรวจสอบว่า map มีข้อมูลครบถ้วน
  /// - DateTime parsing อาจ error หาก format ไม่ถูกต้อง
  /// - List parsing จะกรอง empty strings ออก
  /// - ควรมี error handling สำหรับข้อมูลที่ไม่ถูกต้อง
  factory Project.fromMap(Map<String, dynamic> map) => Project(
    id: map['id'], // ID จากฐานข้อมูล (nullable)
    name: map['name'], // ชื่อโปรเจกต์
    tag: map['tag'], // ประเภทโปรเจกต์
    progress: map['progress'], // ความคืบหน้า (0-100)
    members: (map['members'] as String) // แปลง String เป็น List
        .split(',') // แยกด้วย comma
        .where((e) => e.isNotEmpty) // ลบ empty strings ออก
        .toList(), // แปลงเป็น List<String>
    deadline: map['deadline'], // กำหนดส่ง (nullable)
    userId: map['user_id'], // ID ของผู้ใช้เจ้าของโปรเจกต์
    createdAt: DateTime.parse(map['created_at']), // แปลง String เป็น DateTime
  );

  // ========================================
  // 🔄 Utility Methods - ฟังก์ชันเสริม
  // ========================================
  
  /// สร้าง Project object ใหม่โดยแก้ไขบางฟิลด์
  /// 
  /// @param id ID ใหม่ (optional)
  /// @param name ชื่อใหม่ (optional)
  /// @param tag ประเภทใหม่ (optional)
  /// @param progress ความคืบหน้าใหม่ (optional)
  /// @param members รายชื่อสมาชิกใหม่ (optional)
  /// @param deadline กำหนดส่งใหม่ (optional)
  /// @param userId ID ของผู้ใช้ใหม่ (optional)
  /// @param createdAt วันที่สร้างใหม่ (optional)
  /// @return Project object ใหม่ที่มีการเปลี่ยนแปลงตามที่ระบุ
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. รับพารามิเตอร์ที่ต้องการเปลี่ยนแปลง
  /// 2. ใช้ค่าเดิมสำหรับฟิลด์ที่ไม่ได้ระบุ
  /// 3. สร้าง Project object ใหม่ด้วยข้อมูลที่อัปเดต
  /// 
  /// การใช้งาน:
  /// - อัปเดตความคืบหน้า: project.copyWith(progress: 50)
  /// - เปลี่ยนชื่อ: project.copyWith(name: "New Name")
  /// - เพิ่มสมาชิก: project.copyWith(members: [...project.members, "New Member"])
  /// - เปลี่ยนประเภท: project.copyWith(tag: "Upcoming")
  /// 
  /// ข้อดี:
  /// - ไม่แก้ไข object เดิม (immutable)
  /// - รองรับการเปลี่ยนแปลงแบบ selective
  /// - ใช้ค่าเดิมสำหรับฟิลด์ที่ไม่ได้ระบุ
  /// - เหมาะสำหรับการอัปเดตข้อมูลใน UI
  /// 
  /// ข้อควรระวัง:
  /// - ฟิลด์ที่ไม่ได้ระบุจะใช้ค่าเดิม
  /// - null values จะใช้ค่าเดิม (ไม่ใช่ null)
  /// - ควรตรวจสอบค่าที่ส่งเข้ามาก่อนใช้งาน
  Project copyWith({
    int? id, // ID ใหม่ (optional)
    String? name, // ชื่อใหม่ (optional)
    String? tag, // ประเภทใหม่ (optional)
    int? progress, // ความคืบหน้าใหม่ (optional)
    List<String>? members, // รายชื่อสมาชิกใหม่ (optional)
    String? deadline, // กำหนดส่งใหม่ (optional)
    int? userId, // ID ของผู้ใช้ใหม่ (optional)
    DateTime? createdAt, // วันที่สร้างใหม่ (optional)
  }) {
    return Project(
      id: id ?? this.id, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      name: name ?? this.name, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      tag: tag ?? this.tag, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      progress: progress ?? this.progress, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      members: members ?? this.members, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      deadline: deadline ?? this.deadline, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      userId: userId ?? this.userId, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      createdAt: createdAt ?? this.createdAt, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
    );
  }
}
