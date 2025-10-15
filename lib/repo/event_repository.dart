import 'package:sqflite/sqflite.dart'; // ทำให้สามารถบันทึก,อ่าน,จัดการข้อมูลในฐานข้อมูลSQLiteที่อยู่ภายในเครื่อง
import 'database_service.dart'; // Service สำหรับจัดการฐานข้อมูล
import '../models/event.dart'; // Model ข้อมูลกิจกรรม

/// =======================
/// 📅 EVENT REPOSITORY - จัดการข้อมูลกิจกรรม
/// =======================
/// Repository class สำหรับจัดการข้อมูลกิจกรรมในฐานข้อมูล SQLite
/// หน้าที่หลัก:
/// 1. โหลดข้อมูลกิจกรรมของผู้ใช้จากฐานข้อมูล 2. บันทึกกิจกรรมใหม่ลงฐานข้อมูล 3. อัปเดตข้อมูลกิจกรรมที่มีอยู่ 4. ลบกิจกรรมจากฐานข้อมูล 5. รองรับการกรองข้อมูลตาม user_id
class EventRepository {

  final DatabaseService _dbService = DatabaseService();  /// เชื่อมต่อและจัดการกับฐานข้อมูล SQLite สั่งงานผ่าน _dbService

  // 📊 Data Retrieval Methods - ฟังก์ชันดึงข้อมูล
  /// โหลดข้อมูลกิจกรรมทั้งหมดของผู้ใช้ที่ระบุจากฐานข้อมูล SQLite
  /// @param userId ID ของผู้ใช้ที่ต้องการดึงข้อมูลกิจกรรม
  /// @return Future<List<Event>> รายการกิจกรรมของผู้ใช้เรียงตามวันที่
  
  //ฟังก์ชันloadEvents  "พนักงานค้นหา" 
  Future<List<Event>> loadEvents(int userId) async { //ฟังก์ชันloadEvents = "พนักงานค้นหา"
    
    final db = await _dbService.database; // 🤝 การเปิดการเชื่อมต่อ กับDB 1. เชื่อมต่อdbลผ่านDatabaseService
    
    final List<Map<String, dynamic>> maps = await db.query( //❓การสั่งค้นหาอย่างเฉพาะเจาะจง 2.Queryข้อมูลจาก events table โดยกรองตาม user_id
      DatabaseService.eventsTable, // ชื่อตาราง events ระบุว่าให้ค้นหาในตารางที่เก็บข้อมูลกิจกรรม
      where: 'user_id = ?', // เงื่อนไขสำคัญ->"ต้องการข้อมูลที่คอลัมน์ user_id มีค่าตรงกับที่ฉันกำหนดเท่านั้น"ตาม user_id
      whereArgs: [userId], // ระบุค่า userIdแทน?เพื่อให้มั่นใจว่าดึงมาเฉพาะกิจกรรมของผู้ใช้คนนี้
      orderBy: 'date ASC', // เรียงลำดับตามวันที่ (เก่าที่สุดก่อน) 3. เรียงลำดับข้อมูลตามวันที่ (วันที่เก่าที่สุดก่อน)
    );

    // 🔄 แปลงข้อมูลจาก List<Map> เป็น List<Event> การแปลงข้อมูลให้พร้อมใช้ 4. แปลงข้อมูลจาก Map เป็น Event objects
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }//--------------------------------------------------------------------

  /// โหลดข้อมูลกิจกรรมทั้งหมดในระบบ (ไม่กรองตามผู้ใช้) 
  /// @return Future<List<Event>> รายการกิจกรรมทั้งหมดในระบบเรียงตามวันที่
  /// การใช้งาน:
  /// - สำหรับการทดสอบระบบ - สำหรับการจัดการข้อมูลโดย admin - สำหรับการสำรองข้อมูล
  
  //🔎 ฟังก์ชัน loadAllEvents = "ผู้ดูแลคลังข้อมูล" ที่ดึงกิจกรรม ทั้งหมด 
  Future<List<Event>> loadAllEvents() async {
    final db = await _dbService.database; //🤝 การเชื่อมต่อฐานข้อมูล
    final List<Map<String, dynamic>> maps = await db.query(  // ❓ การสั่งค้นหาข้อมูลทั้งหมด (Query) โดยไม่กรองตาม user_id
      DatabaseService.eventsTable, // ชื่อตาราง events
      orderBy: 'date ASC', // เรียงลำดับตามวันที่ (เก่าที่สุดก่อน)
    );

    // 🔄 การแปลงข้อมูลให้พร้อมใช้จาก List<Map> เป็น List<Event>
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }//-------------------------------------------------------------------------------------------
  
  // 💾 Data Modification Methods - ฟังก์ชันแก้ไขข้อมูล
  /// บันทึกกิจกรรมใหม่ลงฐานข้อมูล SQLite
  /// @param newEvent Event object ที่ต้องการบันทึก
  /// @return Future<void> ไม่มี return value
  /// ฟีเจอร์พิเศษ:
  /// - รองรับการบันทึกข้อมูลซ้ำ (replace existing record) - Automatic ID generation หากไม่ระบุ ID
  
  //💾 ฟังก์ชัน saveEvent เป็น "พนักงานบันทึก" ใช้พิ่มกิจกรรมใหม่หรืออัปเดตกิจลงในฐานข้อมูล SQLite
  Future<void> saveEvent(Event newEvent) async {
    final db = await _dbService.database; //🤝 1. การเชื่อมต่อฐานข้อมูลผ่าน DatabaseService
    
    // 📝 การเตรียมและบันทึกข้อมูล
    await db.insert( //คำสั่ง db.insert() ที่ใช้ในการบันทึกข้อมูล
      DatabaseService.eventsTable, // ชื่อตาราง events 1. ตารางที่ต้องการบันทึก
      newEvent.toMap(), // แปลง Event object เป็น Map format
      conflictAlgorithm: ConflictAlgorithm.replace, // แทนที่ข้อมูลเก่าหากมี key ซ้ำ  3. Insert ข้อมูลลงใน events table & ใช้ ConflictAlgorithm.replace เพื่อจัดการกับ duplicate keys
    );
  }//--------------------------------------------------------------------------

  /// อัปเดตข้อมูลกิจกรรมที่มีอยู่แล้วในฐานข้อมูล
  /// @param event Event object ที่ต้องการอัปเดต (ต้องมี ID)
  /// @return Future<void> ไม่มี return value
  /// ข้อควรระวัง:
  /// - Event object ต้องมี ID ที่ถูกต้อง  - หากไม่พบ record ที่ตรงกับ ID จะไม่เกิด error แต่ไม่มีการอัปเดต

  //✏️ ฟังก์ชัน updateEvent() -> "พนักงานแก้ไข"
  Future<void> updateEvent(Event event) async {
    final db = await _dbService.database; //🤝 การเชื่อมต่อฐานข้อมูลผ่าน DatabaseService
    await db.update( //📝 การสั่งแก้ไขข้อมูล (Update)
      DatabaseService.eventsTable, // ชื่อตาราง events ตารางที่ต้องการแก้ไข
      event.toMap(), // แปลง Event object เป็น Map ข้อมูลใหม่ที่ต้องการบันทึก
      where: 'id = ?', // อัปเดตตาม ID เงื่อนไข: ให้หาแถวที่ id ตรงกับค่า
      whereArgs: [event.id], // ค่า ID ที่ใช้แทน ? ในเงื่อนไข where  ค่า ID ที่ใช้ค้นหา
    );
  }//----------------------------------------------------------------------------------

  /// ลบกิจกรรมจากฐานข้อมูลตาม ID
  /// @param id ID ของกิจกรรมที่ต้องการลบ
  /// @return Future<void> ไม่มี return value 
  /// ข้อควรระวัง:
  /// - การลบข้อมูลจะถาวร ไม่สามารถกู้คืนได้ - หากไม่พบ record ที่ตรงกับ ID จะไม่เกิด error แต่ไม่มีการลบ - ควรตรวจสอบการเชื่อมโยงกับข้อมูลอื่นก่อนลบ

  //🗑️ ฟังก์ชัน deleteEvent() "พนักงานทำลายข้อมูล" ที่ใช้สำหรับ ลบกิจกรรม
  Future<void> deleteEvent(int id) async {
    final db = await _dbService.database; //🤝 การเชื่อมต่อฐานข้อมูล
    await db.delete( //💣 การสั่งลบข้อมูล (Delete)
      DatabaseService.eventsTable, // ชื่อตาราง events ตารางที่ต้องการลบ
      where: 'id = ?', // เงื่อนไขลบตาม ID เงื่อนไข: ให้หาแถวที่ id ตรงกับค่า
      whereArgs: [id], // ค่า ID ที่ใช้แทน ? ในเงื่อนไข where ค่า ID ที่ใช้ค้นหา
    );
  }//---------------------------------------------------------------------------------
}


