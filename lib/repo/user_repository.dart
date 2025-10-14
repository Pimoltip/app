// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import 'package:sqflite/sqflite.dart'; // SQLite database operations สำหรับ Flutter
import 'database_service.dart'; // Service สำหรับจัดการฐานข้อมูล
import '../models/user.dart'; // Model ข้อมูลผู้ใช้

/// =======================
/// 👤 USER REPOSITORY - จัดการข้อมูลผู้ใช้
/// =======================
/// 
/// Repository class สำหรับจัดการข้อมูลผู้ใช้ในฐานข้อมูล SQLite
/// หน้าที่หลัก:
/// 1. โหลดข้อมูลผู้ใช้ทั้งหมดจากฐานข้อมูล
/// 2. บันทึกผู้ใช้ใหม่ลงฐานข้อมูล
/// 3. อัปเดตข้อมูลผู้ใช้ที่มีอยู่
/// 4. ลบผู้ใช้จากฐานข้อมูล
/// 5. ตรวจสอบการเข้าสู่ระบบ (authentication)
/// 6. ค้นหาผู้ใช้ตาม email และ username
/// 
/// ฟีเจอร์หลัก:
/// - CRUD Operations (Create, Read, Update, Delete)
/// - User Authentication & Validation
/// - User Search by Email/Username
/// - Data validation และ error handling
/// - User Management features
/// 
/// การทำงาน:
/// - ใช้ DatabaseService สำหรับการเชื่อมต่อฐานข้อมูล
/// - แปลงข้อมูลระหว่าง User model และ database records
/// - รองรับการทำงานแบบ asynchronous
/// - เรียงลำดับข้อมูลตามวันที่สร้าง (ใหม่สุดก่อน)
class UserRepository {
  /// Service สำหรับจัดการการเชื่อมต่อและ operations ของฐานข้อมูล SQLite
  final DatabaseService _dbService = DatabaseService();

  // ========================================
  // 📊 Data Retrieval Methods - ฟังก์ชันดึงข้อมูล
  // ========================================
  
  /// โหลดข้อมูลผู้ใช้ทั้งหมดจากฐานข้อมูล SQLite
  /// 
  /// @return Future<List<User>> รายการผู้ใช้ทั้งหมดเรียงตามวันที่สร้าง
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Query ข้อมูลจาก users table
  /// 3. เรียงลำดับข้อมูลตามวันที่สร้าง (ผู้ใช้ใหม่สุดก่อน)
  /// 4. แปลงข้อมูลจาก Map เป็น User objects
  /// 
  /// การใช้งาน:
  /// - แสดงรายการผู้ใช้ในระบบ (สำหรับ admin)
  /// - ใช้ในการเลือกสมาชิกในโปรเจกต์
  /// - สำหรับการจัดการผู้ใช้
  /// 
  /// ข้อควรระวัง:
  /// - ฟังก์ชันนี้จะดึงข้อมูลผู้ใช้ทั้งหมดในระบบ
  /// - ควรใช้เฉพาะเมื่อจำเป็นเท่านั้น
  /// - อาจส่งผลต่อ performance หากมีผู้ใช้จำนวนมาก
  Future<List<User>> loadUsers() async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // Query ข้อมูลผู้ใช้ทั้งหมด
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.usersTable, // ชื่อตาราง users
      orderBy: 'created_at DESC', // เรียงลำดับตามวันที่สร้าง (ใหม่สุดก่อน)
    );

    // แปลงข้อมูลจาก List<Map> เป็น List<User>
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // ========================================
  // 💾 Data Modification Methods - ฟังก์ชันแก้ไขข้อมูล
  // ========================================
  
  /// บันทึกผู้ใช้ใหม่ลงฐานข้อมูล SQLite
  /// 
  /// @param user User object ที่ต้องการบันทึก
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. แปลง User object เป็น Map format
  /// 3. Insert ข้อมูลลงใน users table
  /// 4. ใช้ ConflictAlgorithm.replace เพื่อจัดการกับ duplicate keys
  /// 
  /// ฟีเจอร์พิเศษ:
  /// - รองรับการบันทึกข้อมูลซ้ำ (replace existing record)
  /// - Automatic ID generation หากไม่ระบุ ID
  /// - Automatic timestamp สำหรับ created_at
  /// - รองรับการลงทะเบียนผู้ใช้ใหม่
  /// 
  /// การใช้งาน:
  /// - การลงทะเบียนผู้ใช้ใหม่
  /// - การสร้างผู้ใช้สำหรับการทดสอบ
  /// - การ import ข้อมูลผู้ใช้
  Future<void> addUser(User user) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // บันทึกข้อมูลผู้ใช้ใหม่
    await db.insert(
      DatabaseService.usersTable, // ชื่อตาราง users
      user.toMap(), // แปลง User object เป็น Map
      conflictAlgorithm: ConflictAlgorithm.replace, // แทนที่ข้อมูลเก่าหากมี key ซ้ำ
    );
  }

  /// อัปเดตข้อมูลผู้ใช้ที่มีอยู่แล้วในฐานข้อมูล
  /// 
  /// @param user User object ที่ต้องการอัปเดต (ต้องมี ID)
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. แปลง User object เป็น Map format
  /// 3. Update ข้อมูลใน users table โดยใช้ ID เป็นเงื่อนไข
  /// 
  /// การใช้งาน:
  /// - แก้ไขข้อมูลส่วนตัวของผู้ใช้
  /// - อัปเดตรหัสผ่าน
  /// - เปลี่ยนสถานะของผู้ใช้
  /// - อัปเดตข้อมูลโปรไฟล์
  /// 
  /// ข้อควรระวัง:
  /// - User object ต้องมี ID ที่ถูกต้อง
  /// - หากไม่พบ record ที่ตรงกับ ID จะไม่เกิด error แต่ไม่มีการอัปเดต
  /// - การอัปเดตจะเปลี่ยนทุกฟิลด์ใน record
  Future<void> updateUser(User user) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // อัปเดตข้อมูลผู้ใช้
    await db.update(
      DatabaseService.usersTable, // ชื่อตาราง users
      user.toMap(), // แปลง User object เป็น Map
      where: 'id = ?', // เงื่อนไขอัปเดตตาม ID
      whereArgs: [user.id], // ค่า ID ที่ใช้แทน ? ในเงื่อนไข where
    );
  }

  /// ลบผู้ใช้จากฐานข้อมูลตาม ID
  /// 
  /// @param id ID ของผู้ใช้ที่ต้องการลบ
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Delete ข้อมูลจาก users table โดยใช้ ID เป็นเงื่อนไข
  /// 
  /// การใช้งาน:
  /// - ลบบัญชีผู้ใช้ที่ไม่ได้ใช้งาน
  /// - ลบผู้ใช้ตามคำขอ
  /// - การจัดการข้อมูลที่ไม่จำเป็น
  /// 
  /// ข้อควรระวัง:
  /// - การลบข้อมูลจะถาวร ไม่สามารถกู้คืนได้
  /// - หากไม่พบ record ที่ตรงกับ ID จะไม่เกิด error แต่ไม่มีการลบ
  /// - ควรตรวจสอบการเชื่อมโยงกับข้อมูลอื่นก่อนลบ (projects, events)
  /// - ควรมีการยืนยันจากผู้ใช้ก่อนลบ
  /// - ควรพิจารณา soft delete แทน hard delete
  Future<void> deleteUser(int id) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // ลบข้อมูลผู้ใช้ตาม ID
    await db.delete(
      DatabaseService.usersTable, // ชื่อตาราง users
      where: 'id = ?', // เงื่อนไขลบตาม ID
      whereArgs: [id], // ค่า ID ที่ใช้แทน ? ในเงื่อนไข where
    );
  }

  // ========================================
  // 🔐 Authentication Methods - ฟังก์ชันยืนยันตัวตน
  // ========================================
  
  /// ตรวจสอบการเข้าสู่ระบบของผู้ใช้
  /// 
  /// @param email อีเมลของผู้ใช้
  /// @param password รหัสผ่านของผู้ใช้
  /// @return Future<bool> true หากข้อมูลถูกต้อง, false หากไม่ถูกต้อง
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Query หาผู้ใช้ที่มี email และ password ตรงกัน
  /// 3. ตรวจสอบว่าพบผู้ใช้หรือไม่
  /// 
  /// การใช้งาน:
  /// - การเข้าสู่ระบบ (login)
  /// - การตรวจสอบสิทธิ์การเข้าถึง
  /// - การยืนยันตัวตน
  /// 
  /// ข้อควรระวัง:
  /// - รหัสผ่านควรถูกเข้ารหัส (hash) ก่อนบันทึกลงฐานข้อมูล
  /// - ควรมี rate limiting เพื่อป้องกัน brute force attack
  /// - ควรใช้ HTTPS สำหรับการส่งข้อมูล
  /// - ควรพิจารณาใช้ JWT หรือ session management
  Future<bool> validateUser(String email, String password) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // ค้นหาผู้ใช้ที่มี email และ password ตรงกัน
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseService.usersTable, // ชื่อตาราง users
      where: 'email = ? AND password = ?', // เงื่อนไขตรวจสอบ email และ password
      whereArgs: [email, password], // ค่าที่ใช้แทน ? ในเงื่อนไข where
    );
    
    // คืนค่า true หากพบผู้ใช้, false หากไม่พบ
    return result.isNotEmpty;
  }

  // ========================================
  // 🔍 User Search Methods - ฟังก์ชันค้นหาผู้ใช้
  // ========================================
  
  /// ค้นหาผู้ใช้ตามอีเมล
  /// 
  /// @param email อีเมลที่ต้องการค้นหา
  /// @return Future<User?> User object หากพบ, null หากไม่พบ
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Query หาผู้ใช้ที่มี email ตรงกัน
  /// 3. แปลงข้อมูลเป็น User object หากพบ
  /// 4. คืนค่า null หากไม่พบ
  /// 
  /// การใช้งาน:
  /// - การค้นหาผู้ใช้สำหรับการส่งข้อมูล
  /// - การตรวจสอบว่าอีเมลมีอยู่ในระบบแล้วหรือไม่
  /// - การดึงข้อมูลผู้ใช้สำหรับการเข้าสู่ระบบ
  /// 
  /// ข้อควรระวัง:
  /// - อีเมลควรเป็น unique identifier
  /// - ควรมีการ validate format ของอีเมลก่อนเรียกใช้
  Future<User?> getUserByEmail(String email) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // ค้นหาผู้ใช้ตามอีเมล
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseService.usersTable, // ชื่อตาราง users
      where: 'email = ?', // เงื่อนไขค้นหาตาม email
      whereArgs: [email], // ค่าอีเมลที่ใช้แทน ? ในเงื่อนไข where
    );

    // แปลงข้อมูลเป็น User object หากพบ
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    
    // คืนค่า null หากไม่พบผู้ใช้
    return null;
  }

  /// ค้นหาผู้ใช้ตามชื่อผู้ใช้ (username)
  /// 
  /// @param username ชื่อผู้ใช้ที่ต้องการค้นหา
  /// @return Future<User?> User object หากพบ, null หากไม่พบ
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Query หาผู้ใช้ที่มี username ตรงกัน
  /// 3. แปลงข้อมูลเป็น User object หากพบ
  /// 4. คืนค่า null หากไม่พบ
  /// 
  /// การใช้งาน:
  /// - การค้นหาผู้ใช้สำหรับเพิ่มเป็นสมาชิกในโปรเจกต์
  /// - การแสดงข้อมูลโปรไฟล์ผู้ใช้
  /// - การตรวจสอบว่าชื่อผู้ใช้มีอยู่ในระบบแล้วหรือไม่
  /// 
  /// ข้อควรระวัง:
  /// - Username ควรเป็น unique identifier
  /// - ควรมีการ validate format ของ username ก่อนเรียกใช้
  /// - ชื่อฟิลด์ในฐานข้อมูลอาจเป็น 'name' แทน 'username'
  Future<User?> getUserByUsername(String username) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // ค้นหาผู้ใช้ตามชื่อผู้ใช้
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseService.usersTable, // ชื่อตาราง users
      where: 'name = ?', // เงื่อนไขค้นหาตาม username (ใช้ฟิลด์ 'name')
      whereArgs: [username], // ค่าชื่อผู้ใช้ที่ใช้แทน ? ในเงื่อนไข where
    );

    // แปลงข้อมูลเป็น User object หากพบ
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    
    // คืนค่า null หากไม่พบผู้ใช้
    return null;
  }
}
