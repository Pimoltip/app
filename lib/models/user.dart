/// โครงสร้างข้อมูลผู้ใช้
///
/// Data class ที่เก็บข้อมูลผู้ใช้ทั้งหมด
/// ใช้เป็น Model สำหรับเก็บข้อมูลในฐานข้อมูลและแสดงใน UI
class User {
  final int? id; // ID ในฐานข้อมูล (nullable - อาจไม่มีตอนสร้างใหม่)
  final String email; // อีเมลผู้ใช้ (จำเป็นต้องมี)
  final String password; // รหัสผ่าน (จำเป็นต้องมี)
  final String username; // ชื่อผู้ใช้ (จำเป็นต้องมี)
  final DateTime createdAt; // วันที่สร้างบัญชี

  /// Constructor สำหรับสร้าง User object
  ///
  /// พารามิเตอร์:
  /// - id: ID ในฐานข้อมูล (nullable)
  /// - email: อีเมลผู้ใช้ (จำเป็น)
  /// - password: รหัสผ่าน (จำเป็น)
  /// - username: ชื่อผู้ใช้ (จำเป็น)
  /// - createdAt: วันที่สร้าง (ถ้าไม่ระบุ จะใช้เวลาปัจจุบัน)
  User({
    this.id,
    required this.email, // จำเป็นต้องส่งมา
    required this.password, // จำเป็นต้องส่งมา
    required this.username, // จำเป็นต้องส่งมา
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(); // ถ้าไม่ระบุ ใช้เวลาปัจจุบัน

  /// แปลง User object เป็น Map สำหรับบันทึกลงฐานข้อมูล SQLite
  ///
  /// ใช้เมื่อต้องการบันทึกข้อมูลผู้ใช้ลงฐานข้อมูล
  /// - createdAt จะถูกแปลงจาก DateTime เป็น String (ISO format)
  Map<String, dynamic> toMap() => {
    'id': id, // ID ในฐานข้อมูล
    'email': email, // อีเมล
    'password': password, // รหัสผ่าน
    'name': username, // ชื่อผู้ใช้ (ใช้ 'name' ในฐานข้อมูล)
    'created_at': createdAt.toIso8601String(), // แปลง DateTime เป็น String
  };

  /// สร้าง User object จาก Map ที่ได้จากฐานข้อมูล SQLite
  ///
  /// ใช้เมื่อต้องการแปลงข้อมูลจากฐานข้อมูลกลับเป็น User object
  /// - createdAt จะถูกแปลงจาก String กลับเป็น DateTime
  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'], // ID จากฐานข้อมูล
    email: map['email'], // อีเมล
    password: map['password'], // รหัสผ่าน
    username: map['name'], // ชื่อผู้ใช้ (อ่านจาก 'name' ในฐานข้อมูล)
    createdAt: DateTime.parse(map['created_at']), // แปลง String เป็น DateTime
  );

  /// แปลง User object เป็น JSON
  ///
  /// ใช้เมื่อต้องการแปลงข้อมูลผู้ใช้เป็น JSON format
  /// สำหรับบันทึกลงไฟล์หรือส่งผ่าน network
  Map<String, dynamic> toJson() => {
    "email": email, // อีเมล
    "password": password, // รหัสผ่าน
    "username": username, // ชื่อผู้ใช้
  };

  /// สร้าง User object จาก JSON
  ///
  /// ใช้เมื่อต้องการแปลงข้อมูลจาก JSON file กลับเป็น User object
  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json["email"], // อีเมล
    password: json["password"], // รหัสผ่าน
    username: json["username"], // ชื่อผู้ใช้
  );
}
