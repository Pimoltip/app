/// =======================
/// 👤 USER MODEL - โครงสร้างข้อมูลผู้ใช้
/// =======================
/// 
/// Data class ที่เก็บข้อมูลผู้ใช้ทั้งหมดในระบบ
/// หน้าที่หลัก:
/// 1. เก็บข้อมูลผู้ใช้พื้นฐาน (อีเมล, รหัสผ่าน, ชื่อผู้ใช้)
/// 2. จัดการข้อมูลการยืนยันตัวตน (authentication)
/// 3. รองรับการแปลงข้อมูลระหว่างรูปแบบต่างๆ
/// 4. จัดการข้อมูลการสร้างบัญชี
/// 5. รองรับการทำงานกับระบบฐานข้อมูล
/// 
/// ฟีเจอร์หลัก:
/// - User Data Storage
/// - Authentication Support
/// - Database Integration
/// - JSON Serialization
/// - Account Management
/// - Security Features
/// 
/// การทำงาน:
/// - ใช้เป็น Model สำหรับเก็บข้อมูลในฐานข้อมูล SQLite
/// - รองรับการยืนยันตัวตนและเข้าสู่ระบบ
/// - แปลงข้อมูลระหว่าง Dart object และ database/JSON
/// - จัดการข้อมูลผู้ใช้ในระบบ
/// 
/// ระบบความปลอดภัย:
/// - เก็บข้อมูลรหัสผ่านสำหรับการยืนยันตัวตน
/// - รองรับการเข้ารหัสรหัสผ่าน
/// - จัดการข้อมูลการเข้าสู่ระบบ
/// - รองรับการจัดการบัญชีผู้ใช้
class User {
  // ========================================
  // 📊 Basic User Properties - ข้อมูลผู้ใช้พื้นฐาน
  // ========================================
  
  /// ID ในฐานข้อมูล (nullable)
  /// - null: เมื่อสร้างผู้ใช้ใหม่ (ยังไม่ได้บันทึกลงฐานข้อมูล)
  /// - int: เมื่อดึงข้อมูลจากฐานข้อมูล
  /// - ใช้เป็น primary key ในฐานข้อมูล
  final int? id;
  
  /// อีเมลผู้ใช้ (จำเป็นต้องมี)
  /// - ใช้สำหรับการเข้าสู่ระบบ
  /// - ใช้เป็น unique identifier
  /// - ใช้สำหรับการส่งข้อมูลและการติดต่อ
  /// - ควรมีรูปแบบอีเมลที่ถูกต้อง
  final String email;
  
  /// รหัสผ่าน (จำเป็นต้องมี)
  /// - ใช้สำหรับการยืนยันตัวตน
  /// - ควรถูกเข้ารหัสก่อนเก็บในฐานข้อมูล
  /// - ใช้ในการเข้าสู่ระบบ
  /// - ควรมีความแข็งแรงเพียงพอ
  final String password;
  
  /// ชื่อผู้ใช้ (จำเป็นต้องมี)
  /// - ชื่อแสดงผลในระบบ
  /// - ใช้ในการแสดงผลใน UI
  /// - ใช้สำหรับการระบุตัวตนผู้ใช้
  /// - สามารถเปลี่ยนได้ตามต้องการ
  final String username;
  
  /// วันที่สร้างบัญชี
  /// - ใช้ในการติดตามเวลาที่สร้างบัญชี
  /// - ใช้ในการเรียงลำดับผู้ใช้
  /// - ใช้สำหรับการวิเคราะห์ข้อมูล
  final DateTime createdAt;

  // ========================================
  // 🔧 Constructor - ฟังก์ชันสร้าง User Object
  // ========================================
  
  /// Constructor สำหรับสร้าง User object
  /// 
  /// @param id ID ในฐานข้อมูล (nullable) - null สำหรับผู้ใช้ใหม่
  /// @param email อีเมลผู้ใช้ (จำเป็น) - ใช้สำหรับการเข้าสู่ระบบ
  /// @param password รหัสผ่าน (จำเป็น) - ใช้สำหรับการยืนยันตัวตน
  /// @param username ชื่อผู้ใช้ (จำเป็น) - ชื่อแสดงผลในระบบ
  /// @param createdAt วันที่สร้าง (optional) - ถ้าไม่ระบุ จะใช้เวลาปัจจุบัน
  /// 
  /// การใช้งาน:
  /// - สร้างผู้ใช้ใหม่: User(email: "user@example.com", password: "password", username: "John")
  /// - สร้างจากฐานข้อมูล: User.fromMap(mapData)
  /// - สร้างจาก JSON: User.fromJson(jsonData)
  /// 
  /// ข้อควรระวัง:
  /// - ข้อมูลที่จำเป็นต้องส่งมา: email, password, username
  /// - createdAt จะถูกตั้งค่าอัตโนมัติหากไม่ระบุ
  /// - email ควรมีรูปแบบที่ถูกต้อง
  /// - password ควรมีความแข็งแรงเพียงพอ
  /// - username ควรไม่ซ้ำกับผู้ใช้อื่น
  User({
    this.id,
    required this.email, // จำเป็นต้องส่งมา - อีเมลผู้ใช้
    required this.password, // จำเป็นต้องส่งมา - รหัสผ่าน
    required this.username, // จำเป็นต้องส่งมา - ชื่อผู้ใช้
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(); // ถ้าไม่ระบุ ใช้เวลาปัจจุบัน

  // ========================================
  // 🗄️ Database Methods - ฟังก์ชันจัดการฐานข้อมูล
  // ========================================
  
  /// แปลง User object เป็น Map สำหรับบันทึกลงฐานข้อมูล SQLite
  /// 
  /// @return Map<String, dynamic> ข้อมูลที่พร้อมบันทึกลงฐานข้อมูล
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. แปลง DateTime เป็น String (ISO format)
  /// 2. จัดรูปแบบข้อมูลให้ตรงกับโครงสร้างตารางในฐานข้อมูล
  /// 3. ใช้ 'name' เป็น key สำหรับ username ในฐานข้อมูล
  /// 
  /// การใช้งาน:
  /// - บันทึกผู้ใช้ใหม่ลงฐานข้อมูล
  /// - อัปเดตข้อมูลผู้ใช้ที่มีอยู่
  /// - ส่งข้อมูลไปยัง UserRepository
  /// 
  /// ข้อควรระวัง:
  /// - DateTime จะถูกแปลงเป็น ISO string format
  /// - username จะถูกเก็บเป็น 'name' ในฐานข้อมูล
  /// - password จะถูกเก็บเป็น plain text (ควรเข้ารหัสก่อน)
  /// - ข้อมูลจะถูกจัดรูปแบบให้ตรงกับ database schema
  Map<String, dynamic> toMap() => {
    'id': id, // ID ในฐานข้อมูล (nullable)
    'email': email, // อีเมลผู้ใช้
    'password': password, // รหัสผ่าน (ควรเข้ารหัสก่อน)
    'name': username, // ชื่อผู้ใช้ (ใช้ 'name' ในฐานข้อมูล)
    'created_at': createdAt.toIso8601String(), // แปลง DateTime เป็น String (ISO format)
  };

  /// สร้าง User object จาก Map ที่ได้จากฐานข้อมูล SQLite
  /// 
  /// @param map Map ที่ได้จากฐานข้อมูล SQLite
  /// @return User object ที่สร้างจากข้อมูลในฐานข้อมูล
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. แปลง String กลับเป็น DateTime
  /// 2. อ่านข้อมูลจาก database columns
  /// 3. สร้าง User object ด้วยข้อมูลที่แปลงแล้ว
  /// 
  /// การใช้งาน:
  /// - ดึงข้อมูลผู้ใช้จากฐานข้อมูล
  /// - แปลงข้อมูลจาก SQLite query results
  /// - สร้าง User objects จาก database rows
  /// 
  /// ข้อควรระวัง:
  /// - ต้องตรวจสอบว่า map มีข้อมูลครบถ้วน
  /// - DateTime parsing อาจ error หาก format ไม่ถูกต้อง
  /// - username จะถูกอ่านจาก 'name' column
  /// - ควรมี error handling สำหรับข้อมูลที่ไม่ถูกต้อง
  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'], // ID จากฐานข้อมูล (nullable)
    email: map['email'], // อีเมลผู้ใช้
    password: map['password'], // รหัสผ่าน
    username: map['name'], // ชื่อผู้ใช้ (อ่านจาก 'name' ในฐานข้อมูล)
    createdAt: DateTime.parse(map['created_at']), // แปลง String เป็น DateTime
  );

  // ========================================
  // 📄 JSON Methods - ฟังก์ชันจัดการ JSON
  // ========================================
  
  /// แปลง User object เป็น JSON
  /// 
  /// @return Map<String, dynamic> ข้อมูลในรูปแบบ JSON
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. สร้าง Map จาก properties ที่จำเป็น
  /// 2. เก็บข้อมูลในรูปแบบ JSON
  /// 3. รองรับการส่งผ่าน network หรือบันทึกลงไฟล์
  /// 
  /// การใช้งาน:
  /// - ส่งข้อมูลผ่าน API หรือ network
  /// - บันทึกข้อมูลลงไฟล์ JSON
  /// - แชร์ข้อมูลผู้ใช้ระหว่างแอปพลิเคชัน
  /// - Backup ข้อมูลผู้ใช้
  /// - Export ข้อมูลผู้ใช้
  /// 
  /// ข้อควรระวัง:
  /// - ไม่รวม id และ createdAt (ใช้สำหรับ database เท่านั้น)
  /// - password จะถูกส่งเป็น plain text (ควรเข้ารหัสก่อน)
  /// - รองรับการทำงานกับ external systems
  /// - ควรตรวจสอบ JSON format ก่อนใช้งาน
  Map<String, dynamic> toJson() => {
    "email": email, // อีเมลผู้ใช้
    "password": password, // รหัสผ่าน (ควรเข้ารหัสก่อน)
    "username": username, // ชื่อผู้ใช้
  };

  /// สร้าง User object จาก JSON
  /// 
  /// @param json Map ที่ได้จาก JSON data
  /// @return User object ที่สร้างจากข้อมูล JSON
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. อ่านข้อมูลจาก JSON map
  /// 2. สร้าง User object ด้วยข้อมูลที่แปลงแล้ว
  /// 3. ตั้งค่า createdAt เป็นเวลาปัจจุบัน
  /// 
  /// การใช้งาน:
  /// - อ่านข้อมูลจากไฟล์ JSON
  /// - รับข้อมูลจาก API หรือ network
  /// - Import ข้อมูลผู้ใช้จาก external sources
  /// - Restore ข้อมูลจาก backup
  /// 
  /// ข้อควรระวัง:
  /// - ต้องตรวจสอบว่า JSON มีข้อมูลครบถ้วน
  /// - password อาจเป็น plain text (ควรเข้ารหัส)
  /// - id และ createdAt จะถูกตั้งค่าอัตโนมัติ
  /// - ควรมี error handling สำหรับข้อมูลที่ไม่ถูกต้อง
  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json["email"], // อีเมลผู้ใช้
    password: json["password"], // รหัสผ่าน
    username: json["username"], // ชื่อผู้ใช้
  );
}
