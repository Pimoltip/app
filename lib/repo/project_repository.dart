// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import 'package:sqflite/sqflite.dart'; // SQLite database operations สำหรับ Flutter
import 'database_service.dart'; // Service สำหรับจัดการฐานข้อมูล
import '../models/project.dart'; // Model ข้อมูลโปรเจกต์

/// =======================
/// 🚀 PROJECT REPOSITORY - จัดการข้อมูลโปรเจกต์
/// =======================
/// 
/// Repository class สำหรับจัดการข้อมูลโปรเจกต์ในฐานข้อมูล SQLite
/// หน้าที่หลัก:
/// 1. โหลดข้อมูลโปรเจกต์ของผู้ใช้จากฐานข้อมูล
/// 2. บันทึกโปรเจกต์ใหม่ลงฐานข้อมูล
/// 3. อัปเดตข้อมูลโปรเจกต์ที่มีอยู่
/// 4. ลบโปรเจกต์จากฐานข้อมูล (ทั้งแบบ ID และชื่อ)
/// 5. รองรับการกรองข้อมูลตาม user_id
/// 
/// ฟีเจอร์หลัก:
/// - CRUD Operations (Create, Read, Update, Delete)
/// - User-specific data filtering
/// - Multiple deletion methods (by ID and by name)
/// - Data validation และ error handling
/// - Project management features
/// 
/// การทำงาน:
/// - ใช้ DatabaseService สำหรับการเชื่อมต่อฐานข้อมูล
/// - แปลงข้อมูลระหว่าง Project model และ database records
/// - รองรับการทำงานแบบ asynchronous
/// - เรียงลำดับข้อมูลตามวันที่สร้าง (ใหม่สุดก่อน)
class ProjectRepository {
  /// Service สำหรับจัดการการเชื่อมต่อและ operations ของฐานข้อมูล SQLite
  final DatabaseService _dbService = DatabaseService();

  // ========================================
  // 📊 Data Retrieval Methods - ฟังก์ชันดึงข้อมูล
  // ========================================
  
  /// โหลดข้อมูลโปรเจกต์ทั้งหมดของผู้ใช้ที่ระบุจากฐานข้อมูล SQLite
  /// 
  /// @param userId ID ของผู้ใช้ที่ต้องการดึงข้อมูลโปรเจกต์
  /// @return Future<List<Project>> รายการโปรเจกต์ของผู้ใช้เรียงตามวันที่สร้าง
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Query ข้อมูลจาก projects table โดยกรองตาม user_id
  /// 3. เรียงลำดับข้อมูลตามวันที่สร้าง (โปรเจกต์ใหม่สุดก่อน)
  /// 4. แปลงข้อมูลจาก Map เป็น Project objects
  /// 
  /// การใช้งาน:
  /// - แสดงรายการโปรเจกต์ของผู้ใช้ในหน้า Dashboard
  /// - ใช้ในการกรองข้อมูลสำหรับการแสดงผล
  /// - รองรับการทำงานแบบ multi-user
  Future<List<Project>> loadProjects(int userId) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // Query ข้อมูลโปรเจกต์ของผู้ใช้ที่ระบุ
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.projectsTable, // ชื่อตาราง projects
      where: 'user_id = ?', // เงื่อนไขกรองข้อมูลตาม user_id
      whereArgs: [userId], // ค่าที่ใช้แทน ? ในเงื่อนไข where
      orderBy: 'created_at DESC', // เรียงลำดับตามวันที่สร้าง (ใหม่สุดก่อน)
    );

    // แปลงข้อมูลจาก List<Map> เป็น List<Project>
    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }

  /// โหลดข้อมูลโปรเจกต์ทั้งหมดในระบบ (ไม่กรองตามผู้ใช้)
  /// 
  /// @return Future<List<Project>> รายการโปรเจกต์ทั้งหมดในระบบเรียงตามวันที่สร้าง
  /// 
  /// การใช้งาน:
  /// - สำหรับการทดสอบระบบ
  /// - สำหรับการจัดการข้อมูลโดย admin
  /// - สำหรับการสำรองข้อมูล
  /// - สำหรับการวิเคราะห์ข้อมูลรวม
  /// 
  /// ข้อควรระวัง:
  /// - ฟังก์ชันนี้จะดึงข้อมูลโปรเจกต์ของทุกคนในระบบ
  /// - ควรใช้เฉพาะเมื่อจำเป็นเท่านั้น
  /// - อาจส่งผลต่อ performance หากมีข้อมูลจำนวนมาก
  /// - ควรใช้ร่วมกับ pagination ในอนาคต
  Future<List<Project>> loadAllProjects() async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // Query ข้อมูลโปรเจกต์ทั้งหมดโดยไม่กรองตาม user_id
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.projectsTable, // ชื่อตาราง projects
      orderBy: 'created_at DESC', // เรียงลำดับตามวันที่สร้าง (ใหม่สุดก่อน)
    );

    // แปลงข้อมูลจาก List<Map> เป็น List<Project>
    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }

  // ========================================
  // 💾 Data Modification Methods - ฟังก์ชันแก้ไขข้อมูล
  // ========================================
  
  /// บันทึกโปรเจกต์ใหม่ลงฐานข้อมูล SQLite
  /// 
  /// @param project Project object ที่ต้องการบันทึก
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. แปลง Project object เป็น Map format
  /// 3. Insert ข้อมูลลงใน projects table
  /// 4. ใช้ ConflictAlgorithm.replace เพื่อจัดการกับ duplicate keys
  /// 
  /// ฟีเจอร์พิเศษ:
  /// - รองรับการบันทึกข้อมูลซ้ำ (replace existing record)
  /// - Automatic ID generation หากไม่ระบุ ID
  /// - Automatic timestamp สำหรับ created_at
  /// - รองรับการบันทึกข้อมูลโปรเจกต์แบบ offline
  Future<void> addProject(Project project) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // บันทึกข้อมูลโปรเจกต์ใหม่
    await db.insert(
      DatabaseService.projectsTable, // ชื่อตาราง projects
      project.toMap(), // แปลง Project object เป็น Map
      conflictAlgorithm: ConflictAlgorithm.replace, // แทนที่ข้อมูลเก่าหากมี key ซ้ำ
    );
  }

  /// อัปเดตข้อมูลโปรเจกต์ที่มีอยู่แล้วในฐานข้อมูล
  /// 
  /// @param project Project object ที่ต้องการอัปเดต (ต้องมี ID)
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. แปลง Project object เป็น Map format
  /// 3. Update ข้อมูลใน projects table โดยใช้ ID เป็นเงื่อนไข
  /// 
  /// การใช้งาน:
  /// - อัปเดต progress ของโปรเจกต์
  /// - แก้ไขข้อมูลโปรเจกต์ (ชื่อ, deadline, members)
  /// - เปลี่ยนสถานะของโปรเจกต์
  /// 
  /// ข้อควรระวัง:
  /// - Project object ต้องมี ID ที่ถูกต้อง
  /// - หากไม่พบ record ที่ตรงกับ ID จะไม่เกิด error แต่ไม่มีการอัปเดต
  /// - การอัปเดตจะเปลี่ยนทุกฟิลด์ใน record
  Future<void> updateProject(Project project) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // อัปเดตข้อมูลโปรเจกต์
    await db.update(
      DatabaseService.projectsTable, // ชื่อตาราง projects
      project.toMap(), // แปลง Project object เป็น Map
      where: 'id = ?', // เงื่อนไขอัปเดตตาม ID
      whereArgs: [project.id], // ค่า ID ที่ใช้แทน ? ในเงื่อนไข where
    );
  }

  // ========================================
  // 🗑️ Data Deletion Methods - ฟังก์ชันลบข้อมูล
  // ========================================
  
  /// ลบโปรเจกต์จากฐานข้อมูลตาม ID
  /// 
  /// @param id ID ของโปรเจกต์ที่ต้องการลบ
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Delete ข้อมูลจาก projects table โดยใช้ ID เป็นเงื่อนไข
  /// 
  /// การใช้งาน:
  /// - ลบโปรเจกต์ที่เสร็จสิ้นแล้ว
  /// - ลบโปรเจกต์ที่ไม่ต้องการแล้ว
  /// - การจัดการข้อมูลที่ไม่จำเป็น
  /// 
  /// ข้อควรระวัง:
  /// - การลบข้อมูลจะถาวร ไม่สามารถกู้คืนได้
  /// - หากไม่พบ record ที่ตรงกับ ID จะไม่เกิด error แต่ไม่มีการลบ
  /// - ควรตรวจสอบการเชื่อมโยงกับข้อมูลอื่นก่อนลบ
  /// - ควรมีการยืนยันจากผู้ใช้ก่อนลบ
  Future<void> deleteProject(int id) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // ลบข้อมูลโปรเจกต์ตาม ID
    await db.delete(
      DatabaseService.projectsTable, // ชื่อตาราง projects
      where: 'id = ?', // เงื่อนไขลบตาม ID
      whereArgs: [id], // ค่า ID ที่ใช้แทน ? ในเงื่อนไข where
    );
  }

  /// ลบโปรเจกต์จากฐานข้อมูลตามชื่อ
  /// 
  /// @param name ชื่อของโปรเจกต์ที่ต้องการลบ
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Delete ข้อมูลจาก projects table โดยใช้ชื่อเป็นเงื่อนไข
  /// 
  /// การใช้งาน:
  /// - ลบโปรเจกต์โดยใช้ชื่อแทน ID
  /// - การลบแบบ batch ตามชื่อที่คล้ายกัน
  /// - การจัดการโปรเจกต์ที่ชื่อซ้ำ
  /// 
  /// ข้อควรระวัง:
  /// - การลบข้อมูลจะถาวร ไม่สามารถกู้คืนได้
  /// - หากมีโปรเจกต์หลายตัวที่มีชื่อเดียวกัน จะลบทั้งหมด
  /// - ชื่อโปรเจกต์ต้องตรงกับข้อมูลในฐานข้อมูลทุกตัวอักษร
  /// - ควรใช้ deleteProject(int id) แทนหากรู้ ID
  /// - ควรมีการยืนยันจากผู้ใช้ก่อนลบ
  Future<void> deleteProjectByName(String name) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // ลบข้อมูลโปรเจกต์ตามชื่อ
    await db.delete(
      DatabaseService.projectsTable, // ชื่อตาราง projects
      where: 'name = ?', // เงื่อนไขลบตามชื่อ
      whereArgs: [name], // ชื่อโปรเจกต์ที่ใช้แทน ? ในเงื่อนไข where
    );
  }
}
