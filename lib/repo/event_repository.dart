// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import 'package:sqflite/sqflite.dart'; // SQLite database operations สำหรับ Flutter
import 'database_service.dart'; // Service สำหรับจัดการฐานข้อมูล
import '../models/event.dart'; // Model ข้อมูลกิจกรรม

/// =======================
/// 📅 EVENT REPOSITORY - จัดการข้อมูลกิจกรรม
/// =======================
/// 
/// Repository class สำหรับจัดการข้อมูลกิจกรรมในฐานข้อมูล SQLite
/// หน้าที่หลัก:
/// 1. โหลดข้อมูลกิจกรรมของผู้ใช้จากฐานข้อมูล
/// 2. บันทึกกิจกรรมใหม่ลงฐานข้อมูล
/// 3. อัปเดตข้อมูลกิจกรรมที่มีอยู่
/// 4. ลบกิจกรรมจากฐานข้อมูล
/// 5. รองรับการกรองข้อมูลตาม user_id
/// 
/// ฟีเจอร์หลัก:
/// - CRUD Operations (Create, Read, Update, Delete)
/// - User-specific data filtering
/// - Data validation และ error handling
/// - Backward compatibility สำหรับ legacy code
/// 
/// การทำงาน:
/// - ใช้ DatabaseService สำหรับการเชื่อมต่อฐานข้อมูล
/// - แปลงข้อมูลระหว่าง Event model และ database records
/// - รองรับการทำงานแบบ asynchronous
class EventRepository {
  /// Service สำหรับจัดการการเชื่อมต่อและ operations ของฐานข้อมูล SQLite
  final DatabaseService _dbService = DatabaseService();

  // ========================================
  // 📊 Data Retrieval Methods - ฟังก์ชันดึงข้อมูล
  // ========================================
  
  /// โหลดข้อมูลกิจกรรมทั้งหมดของผู้ใช้ที่ระบุจากฐานข้อมูล SQLite
  /// 
  /// @param userId ID ของผู้ใช้ที่ต้องการดึงข้อมูลกิจกรรม
  /// @return Future<List<Event>> รายการกิจกรรมของผู้ใช้เรียงตามวันที่
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Query ข้อมูลจาก events table โดยกรองตาม user_id
  /// 3. เรียงลำดับข้อมูลตามวันที่ (วันที่เก่าที่สุดก่อน)
  /// 4. แปลงข้อมูลจาก Map เป็น Event objects
  Future<List<Event>> loadEvents(int userId) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // Query ข้อมูลกิจกรรมของผู้ใช้ที่ระบุ
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.eventsTable, // ชื่อตาราง events
      where: 'user_id = ?', // เงื่อนไขกรองข้อมูลตาม user_id
      whereArgs: [userId], // ค่าที่ใช้แทน ? ในเงื่อนไข where
      orderBy: 'date ASC', // เรียงลำดับตามวันที่ (เก่าที่สุดก่อน)
    );

    // แปลงข้อมูลจาก List<Map> เป็น List<Event>
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  /// โหลดข้อมูลกิจกรรมทั้งหมดในระบบ (ไม่กรองตามผู้ใช้)
  /// 
  /// @return Future<List<Event>> รายการกิจกรรมทั้งหมดในระบบเรียงตามวันที่
  /// 
  /// การใช้งาน:
  /// - สำหรับการทดสอบระบบ
  /// - สำหรับการจัดการข้อมูลโดย admin
  /// - สำหรับการสำรองข้อมูล
  /// 
  /// ข้อควรระวัง:
  /// - ฟังก์ชันนี้จะดึงข้อมูลกิจกรรมของทุกคนในระบบ
  /// - ควรใช้เฉพาะเมื่อจำเป็นเท่านั้น
  Future<List<Event>> loadAllEvents() async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // Query ข้อมูลกิจกรรมทั้งหมดโดยไม่กรองตาม user_id
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.eventsTable, // ชื่อตาราง events
      orderBy: 'date ASC', // เรียงลำดับตามวันที่ (เก่าที่สุดก่อน)
    );

    // แปลงข้อมูลจาก List<Map> เป็น List<Event>
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  // ========================================
  // 💾 Data Modification Methods - ฟังก์ชันแก้ไขข้อมูล
  // ========================================
  
  /// บันทึกกิจกรรมใหม่ลงฐานข้อมูล SQLite
  /// 
  /// @param newEvent Event object ที่ต้องการบันทึก
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. แปลง Event object เป็น Map format
  /// 3. Insert ข้อมูลลงใน events table
  /// 4. ใช้ ConflictAlgorithm.replace เพื่อจัดการกับ duplicate keys
  /// 
  /// ฟีเจอร์พิเศษ:
  /// - รองรับการบันทึกข้อมูลซ้ำ (replace existing record)
  /// - Automatic ID generation หากไม่ระบุ ID
  Future<void> saveEvent(Event newEvent) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // บันทึกข้อมูลกิจกรรมใหม่
    await db.insert(
      DatabaseService.eventsTable, // ชื่อตาราง events
      newEvent.toMap(), // แปลง Event object เป็น Map
      conflictAlgorithm: ConflictAlgorithm.replace, // แทนที่ข้อมูลเก่าหากมี key ซ้ำ
    );
  }

  /// อัปเดตข้อมูลกิจกรรมที่มีอยู่แล้วในฐานข้อมูล
  /// 
  /// @param event Event object ที่ต้องการอัปเดต (ต้องมี ID)
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. แปลง Event object เป็น Map format
  /// 3. Update ข้อมูลใน events table โดยใช้ ID เป็นเงื่อนไข
  /// 
  /// ข้อควรระวัง:
  /// - Event object ต้องมี ID ที่ถูกต้อง
  /// - หากไม่พบ record ที่ตรงกับ ID จะไม่เกิด error แต่ไม่มีการอัปเดต
  Future<void> updateEvent(Event event) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // อัปเดตข้อมูลกิจกรรม
    await db.update(
      DatabaseService.eventsTable, // ชื่อตาราง events
      event.toMap(), // แปลง Event object เป็น Map
      where: 'id = ?', // เงื่อนไขอัปเดตตาม ID
      whereArgs: [event.id], // ค่า ID ที่ใช้แทน ? ในเงื่อนไข where
    );
  }

  /// ลบกิจกรรมจากฐานข้อมูลตาม ID
  /// 
  /// @param id ID ของกิจกรรมที่ต้องการลบ
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. เชื่อมต่อฐานข้อมูลผ่าน DatabaseService
  /// 2. Delete ข้อมูลจาก events table โดยใช้ ID เป็นเงื่อนไข
  /// 
  /// ข้อควรระวัง:
  /// - การลบข้อมูลจะถาวร ไม่สามารถกู้คืนได้
  /// - หากไม่พบ record ที่ตรงกับ ID จะไม่เกิด error แต่ไม่มีการลบ
  /// - ควรตรวจสอบการเชื่อมโยงกับข้อมูลอื่นก่อนลบ
  Future<void> deleteEvent(int id) async {
    // เชื่อมต่อฐานข้อมูล
    final db = await _dbService.database;
    
    // ลบข้อมูลกิจกรรม
    await db.delete(
      DatabaseService.eventsTable, // ชื่อตาราง events
      where: 'id = ?', // เงื่อนไขลบตาม ID
      whereArgs: [id], // ค่า ID ที่ใช้แทน ? ในเงื่อนไข where
    );
  }

  // ========================================
  // 🔄 Backward Compatibility Methods - ฟังก์ชันรองรับโค้ดเก่า
  // ========================================
  
  /// Alias method สำหรับ backward compatibility
  /// 
  /// @param newEvent Event object ที่ต้องการบันทึก
  /// @return Future<void> ไม่มี return value
  /// 
  /// วัตถุประสงค์:
  /// - รองรับโค้ดเก่าที่เรียกใช้ addEvent แทน saveEvent
  /// - ทำให้การอัปเกรดโค้ดทำได้ง่ายขึ้น
  /// - ป้องกัน breaking changes
  /// 
  /// การใช้งาน:
  /// - เรียกใช้เหมือน saveEvent ทุกประการ
  /// - แนะนำให้ใช้ saveEvent แทนในโค้ดใหม่
  Future<void> addEvent(Event newEvent) {
    return saveEvent(newEvent);
  }
}
