/// โครงสร้างข้อมูลโปรเจกต์
///
/// Data class ที่เก็บข้อมูลโปรเจกต์ทั้งหมด
/// ใช้เป็น Model สำหรับเก็บข้อมูลในฐานข้อมูลและแสดงใน UI
class Project {
  final int? id; // ID ในฐานข้อมูล (nullable - อาจไม่มีตอนสร้างใหม่)
  final String name; // ชื่อโปรเจกต์ (จำเป็นต้องมี)
  final String tag; // ประเภทโปรเจกต์: Recently/Today/Upcoming/Later
  final int progress; // ความคืบหน้า 0-100% (จำเป็นต้องมี)
  final List<String> members; // รายชื่อสมาชิกในโปรเจกต์
  final String? deadline; // กำหนดส่งในรูปแบบ YYYY-MM-DD (nullable)
  final DateTime createdAt; // วันที่สร้างโปรเจกต์

  /// Constructor สำหรับสร้าง Project object
  ///
  /// พารามิเตอร์:
  /// - id: ID ในฐานข้อมูล (nullable)
  /// - name: ชื่อโปรเจกต์ (จำเป็น)
  /// - tag: ประเภทโปรเจกต์ (จำเป็น)
  /// - progress: ความคืบหน้า 0-100 (จำเป็น)
  /// - members: รายชื่อสมาชิก (จำเป็น)
  /// - deadline: กำหนดส่ง (nullable)
  /// - createdAt: วันที่สร้าง (ถ้าไม่ระบุ จะใช้เวลาปัจจุบัน)
  Project({
    this.id,
    required this.name, // จำเป็นต้องส่งมา
    required this.tag, // จำเป็นต้องส่งมา
    required this.progress, // จำเป็นต้องส่งมา
    required this.members, // จำเป็นต้องส่งมา
    this.deadline, // ไม่จำเป็น (nullable)
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(); // ถ้าไม่ระบุ ใช้เวลาปัจจุบัน

  /// แปลง Project object เป็น Map สำหรับบันทึกลงฐานข้อมูล SQLite
  ///
  /// ใช้เมื่อต้องการบันทึกข้อมูลโปรเจกต์ลงฐานข้อมูล
  /// - members จะถูกแปลงจาก List เป็น String คั่นด้วย comma
  /// - createdAt จะถูกแปลงจาก DateTime เป็น String (ISO format)
  Map<String, dynamic> toMap() => {
    'id': id, // ID ในฐานข้อมูล
    'name': name, // ชื่อโปรเจกต์
    'tag': tag, // ประเภทโปรเจกต์
    'progress': progress, // ความคืบหน้า
    'members': members.join(','), // แปลง List เป็น String คั่นด้วย comma
    'deadline': deadline, // กำหนดส่ง
    'created_at': createdAt.toIso8601String(), // แปลง DateTime เป็น String
  };

  /// สร้าง Project object จาก Map ที่ได้จากฐานข้อมูล SQLite
  ///
  /// ใช้เมื่อต้องการแปลงข้อมูลจากฐานข้อมูลกลับเป็น Project object
  /// - members จะถูกแปลงจาก String กลับเป็น List
  /// - createdAt จะถูกแปลงจาก String กลับเป็น DateTime
  factory Project.fromMap(Map<String, dynamic> map) => Project(
    id: map['id'], // ID จากฐานข้อมูล
    name: map['name'], // ชื่อโปรเจกต์
    tag: map['tag'], // ประเภทโปรเจกต์
    progress: map['progress'], // ความคืบหน้า
    members:
        (map['members'] as String) // แปลง String เป็น List
            .split(',') // แยกด้วย comma
            .where((e) => e.isNotEmpty) // ลบ empty strings
            .toList(), // แปลงเป็น List
    deadline: map['deadline'], // กำหนดส่ง
    createdAt: DateTime.parse(map['created_at']), // แปลง String เป็น DateTime
  );

  /// สร้าง Project object จาก JSON (สำหรับ backward compatibility)
  ///
  /// ใช้เมื่อต้องการแปลงข้อมูลจาก JSON file กลับเป็น Project object
  /// แตกต่างจาก fromMap() ตรงที่ members เก็บเป็น List ใน JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'] as String, // ชื่อโปรเจกต์
      tag: json['tag'] as String, // ประเภทโปรเจกต์
      progress: (json['progress'] as num).toInt(), // ความคืบหน้า (แปลงเป็น int)
      members:
          (json['members']
                  as List<dynamic>) // แปลง List<dynamic> เป็น List<String>
              .map((e) => e as String) // แปลงแต่ละ element เป็น String
              .toList(), // แปลงเป็น List
      deadline: json['deadline'] as String?, // กำหนดส่ง (nullable)
    );
  }

  /// แปลง Project object เป็น JSON
  ///
  /// ใช้เมื่อต้องการแปลงข้อมูลโปรเจกต์เป็น JSON format
  /// สำหรับบันทึกลงไฟล์หรือส่งผ่าน network
  Map<String, dynamic> toJson() {
    return {
      'name': name, // ชื่อโปรเจกต์
      'tag': tag, // ประเภทโปรเจกต์
      'progress': progress, // ความคืบหน้า
      'members': members, // รายชื่อสมาชิก (List)
      if (deadline != null) 'deadline': deadline, // กำหนดส่ง (ถ้ามี)
    };
  }

  /// สร้าง Project object ใหม่โดยแก้ไขบางฟิลด์
  ///
  /// ใช้เมื่อต้องการสร้าง Project object ใหม่โดยเปลี่ยนเฉพาะฟิลด์ที่ต้องการ
  /// ฟิลด์ที่ไม่ได้ระบุจะใช้ค่าเดิม
  ///
  /// ตัวอย่าง: project.copyWith(progress: 50) จะได้ Project ใหม่ที่มี progress = 50
  Project copyWith({
    int? id, // ID ใหม่
    String? name, // ชื่อใหม่
    String? tag, // ประเภทใหม่
    int? progress, // ความคืบหน้าใหม่
    List<String>? members, // รายชื่อสมาชิกใหม่
    String? deadline, // กำหนดส่งใหม่
    DateTime? createdAt, // วันที่สร้างใหม่
  }) {
    return Project(
      id: id ?? this.id, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      name: name ?? this.name, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      tag: tag ?? this.tag, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      progress: progress ?? this.progress, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      members: members ?? this.members, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      deadline: deadline ?? this.deadline, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
      createdAt: createdAt ?? this.createdAt, // ถ้าไม่ได้ระบุ ใช้ค่าเดิม
    );
  }
}
