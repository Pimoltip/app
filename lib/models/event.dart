/// โครงสร้างข้อมูลกิจกรรม
///
/// Data class ที่เก็บข้อมูลกิจกรรมทั้งหมด
/// ใช้เป็น Model สำหรับเก็บข้อมูลในฐานข้อมูลและแสดงใน UI
class Event {
  final int? id; // ID ในฐานข้อมูล (nullable - อาจไม่มีตอนสร้างใหม่)
  final DateTime date; // วันที่ของกิจกรรม (จำเป็นต้องมี)
  final String title; // หัวข้อกิจกรรม (จำเป็นต้องมี)
  final String description; // คำอธิบายกิจกรรม (จำเป็นต้องมี)
  final int userId; // ID ของผู้ใช้เจ้าของกิจกรรม (จำเป็นต้องมี)
  final DateTime createdAt; // วันที่สร้างกิจกรรม

  /// Constructor สำหรับสร้าง Event object
  ///
  /// พารามิเตอร์:
  /// - id: ID ในฐานข้อมูล (nullable)
  /// - date: วันที่ของกิจกรรม (จำเป็น)
  /// - title: หัวข้อกิจกรรม (จำเป็น)
  /// - description: คำอธิบายกิจกรรม (จำเป็น)
  /// - userId: ID ของผู้ใช้เจ้าของกิจกรรม (จำเป็น)
  /// - createdAt: วันที่สร้าง (ถ้าไม่ระบุ จะใช้เวลาปัจจุบัน)
  Event({
    this.id,
    required this.date, // จำเป็นต้องส่งมา
    required this.title, // จำเป็นต้องส่งมา
    required this.description, // จำเป็นต้องส่งมา
    required this.userId, // จำเป็นต้องส่งมา
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(); // ถ้าไม่ระบุ ใช้เวลาปัจจุบัน

  /// แปลง Event object เป็น Map สำหรับบันทึกลงฐานข้อมูล SQLite
  ///
  /// ใช้เมื่อต้องการบันทึกข้อมูลกิจกรรมลงฐานข้อมูล
  /// - date และ createdAt จะถูกแปลงจาก DateTime เป็น String (ISO format)
  Map<String, dynamic> toMap() => {
    'id': id, // ID ในฐานข้อมูล
    'title': title, // หัวข้อกิจกรรม
    'description': description, // คำอธิบาย
    'date': date.toIso8601String(), // แปลง DateTime เป็น String
    'user_id': userId, // ID ของผู้ใช้เจ้าของกิจกรรม
    'created_at': createdAt.toIso8601String(), // แปลง DateTime เป็น String
  };

  /// สร้าง Event object จาก Map ที่ได้จากฐานข้อมูล SQLite
  ///
  /// ใช้เมื่อต้องการแปลงข้อมูลจากฐานข้อมูลกลับเป็น Event object
  /// - date และ createdAt จะถูกแปลงจาก String กลับเป็น DateTime
  factory Event.fromMap(Map<String, dynamic> map) => Event(
    id: map['id'], // ID จากฐานข้อมูล
    title: map['title'], // หัวข้อกิจกรรม
    description: map['description'], // คำอธิบาย
    date: DateTime.parse(map['date']), // แปลง String เป็น DateTime
    userId: map['user_id'], // ID ของผู้ใช้เจ้าของกิจกรรม
    createdAt: DateTime.parse(map['created_at']), // แปลง String เป็น DateTime
  );

  /// แปลง Event object เป็น JSON
  ///
  /// ใช้เมื่อต้องการแปลงข้อมูลกิจกรรมเป็น JSON format
  /// สำหรับบันทึกลงไฟล์หรือส่งผ่าน network
  Map<String, dynamic> toJson() => {
    "date": date.toIso8601String(), // แปลง DateTime เป็น String
    "title": title, // หัวข้อกิจกรรม
    "description": description, // คำอธิบาย
    "userId": userId, // ID ของผู้ใช้เจ้าของกิจกรรม
  };

  /// สร้าง Event object จาก JSON
  ///
  /// ใช้เมื่อต้องการแปลงข้อมูลจาก JSON file กลับเป็น Event object
  factory Event.fromJson(Map<String, dynamic> json) => Event(
    date: DateTime.parse(json["date"]), // แปลง String เป็น DateTime
    title: json["title"], // หัวข้อกิจกรรม
    description: json["description"], // คำอธิบาย
    userId: json["userId"] ?? 1, // ID ของผู้ใช้เจ้าของกิจกรรม (default = 1)
  );
}
