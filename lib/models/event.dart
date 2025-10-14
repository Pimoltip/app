/// =======================
/// 📅 EVENT MODEL - โครงสร้างข้อมูลกิจกรรม
/// =======================
/// 
/// Data class ที่เก็บข้อมูลกิจกรรมทั้งหมดในระบบ
/// หน้าที่หลัก:
/// 1. เก็บข้อมูลกิจกรรมพื้นฐาน (ชื่อ, คำอธิบาย, วันที่)
/// 2. จัดการข้อมูลการทำซ้ำของกิจกรรม
/// 3. รองรับการแปลงข้อมูลระหว่างรูปแบบต่างๆ
/// 4. จัดการความสัมพันธ์กับผู้ใช้
/// 
/// ฟีเจอร์หลัก:
/// - Event Data Storage
/// - Recurring Event Support
/// - Database Integration
/// - JSON Serialization
/// - User Association
/// - Date/Time Management
/// 
/// การทำงาน:
/// - ใช้เป็น Model สำหรับเก็บข้อมูลในฐานข้อมูล SQLite
/// - รองรับการทำซ้ำตามวันในสัปดาห์
/// - แปลงข้อมูลระหว่าง Dart object และ database/JSON
/// - จัดการข้อมูลผู้ใช้เจ้าของกิจกรรม
/// 
/// ระบบการทำซ้ำ:
/// - รองรับการทำซ้ำหลายวันในสัปดาห์
/// - กำหนด deadline สำหรับการหยุดทำซ้ำ
/// - ใช้ weekday number (1=จันทร์, 7=อาทิตย์)
class Event {
  // ========================================
  // 📊 Basic Event Properties - ข้อมูลกิจกรรมพื้นฐาน
  // ========================================
  
  /// ID ในฐานข้อมูล (nullable)
  /// - null: เมื่อสร้างกิจกรรมใหม่ (ยังไม่ได้บันทึกลงฐานข้อมูล)
  /// - int: เมื่อดึงข้อมูลจากฐานข้อมูล
  final int? id;
  
  /// วันที่และเวลาของกิจกรรม (จำเป็นต้องมี)
  /// - ใช้สำหรับกำหนดเวลาที่กิจกรรมจะเกิดขึ้น
  /// - ใช้ในการเรียงลำดับและกรองกิจกรรม
  final DateTime date;
  
  /// หัวข้อกิจกรรม (จำเป็นต้องมี)
  /// - ชื่อหรือหัวข้อของกิจกรรม
  /// - ใช้ในการแสดงผลใน UI
  final String title;
  
  /// คำอธิบายกิจกรรม (จำเป็นต้องมี)
  /// - รายละเอียดเพิ่มเติมของกิจกรรม
  /// - ใช้ในการแสดงผลใน UI
  final String description;
  
  /// ID ของผู้ใช้เจ้าของกิจกรรม (จำเป็นต้องมี)
  /// - เชื่อมโยงกิจกรรมกับผู้ใช้
  /// - ใช้ในการกรองกิจกรรมตามผู้ใช้
  final int userId;
  
  /// วันที่สร้างกิจกรรม
  /// - ใช้ในการติดตามเวลาที่สร้างกิจกรรม
  /// - ใช้ในการเรียงลำดับกิจกรรม
  final DateTime createdAt;

  // ========================================
  // 🔄 Recurring Event Properties - ข้อมูลการทำซ้ำ
  // ========================================
  
  /// สถานะการทำซ้ำของกิจกรรม
  /// - true: กิจกรรมนี้ทำซ้ำตามวันในสัปดาห์
  /// - false: กิจกรรมนี้ทำครั้งเดียว
  final bool isRecurring;
  
  /// วันในสัปดาห์ที่ทำซ้ำ (nullable)
  /// - null: หากไม่ใช่กิจกรรมที่ทำซ้ำ
  /// - List&lt;int&gt;: รายการวันในสัปดาห์ (1=จันทร์, 2=อังคาร, ..., 7=อาทิตย์)
  /// - ตัวอย่าง: [1, 3, 5] = ทำซ้ำทุกวันจันทร์, พุธ, ศุกร์
  final List<int>? recurringWeekdays;
  
  /// วันที่สิ้นสุดการทำซ้ำ (nullable)
  /// - null: ไม่มีการกำหนด deadline
  /// - DateTime: วันที่ที่กิจกรรมจะหยุดทำซ้ำ
  /// - ใช้เพื่อจำกัดการทำซ้ำของกิจกรรม
  final DateTime? deadlineDate;

  // ========================================
  // 🔧 Constructor - ฟังก์ชันสร้าง Event Object
  // ========================================
  
  /// Constructor สำหรับสร้าง Event object
  /// 
  /// @param id ID ในฐานข้อมูล (nullable) - null สำหรับกิจกรรมใหม่
  /// @param date วันที่ของกิจกรรม (จำเป็น) - วันที่และเวลาที่กิจกรรมจะเกิดขึ้น
  /// @param title หัวข้อกิจกรรม (จำเป็น) - ชื่อหรือหัวข้อของกิจกรรม
  /// @param description คำอธิบายกิจกรรม (จำเป็น) - รายละเอียดของกิจกรรม
  /// @param userId ID ของผู้ใช้เจ้าของกิจกรรม (จำเป็น) - เชื่อมโยงกับผู้ใช้
  /// @param createdAt วันที่สร้าง (optional) - ถ้าไม่ระบุ จะใช้เวลาปัจจุบัน
  /// @param isRecurring สถานะการทำซ้ำ (default = false) - true หากกิจกรรมทำซ้ำ
  /// @param recurringWeekdays วันในสัปดาห์ที่ทำซ้ำ (nullable) - รายการวันในสัปดาห์
  /// @param deadlineDate วันที่สิ้นสุดการทำซ้ำ (nullable) - วันที่หยุดทำซ้ำ
  /// 
  /// การใช้งาน:
  /// - สร้างกิจกรรมใหม่: Event(title: "Meeting", date: DateTime.now(), ...)
  /// - สร้างกิจกรรมที่ทำซ้ำ: Event(title: "Class", isRecurring: true, recurringWeekdays: [1, 3, 5], ...)
  /// - สร้างกิจกรรมจากฐานข้อมูล: Event.fromMap(mapData)
  /// 
  /// ข้อควรระวัง:
  /// - ข้อมูลที่จำเป็นต้องส่งมา: date, title, description, userId
  /// - createdAt จะถูกตั้งค่าอัตโนมัติหากไม่ระบุ
  /// - isRecurring ต้องเป็น true หากต้องการใช้ recurringWeekdays
  /// - deadlineDate ควรอยู่หลัง date เสมอ
  Event({
    this.id,
    required this.date, // จำเป็นต้องส่งมา - วันที่และเวลาของกิจกรรม
    required this.title, // จำเป็นต้องส่งมา - หัวข้อของกิจกรรม
    required this.description, // จำเป็นต้องส่งมา - คำอธิบายของกิจกรรม
    required this.userId, // จำเป็นต้องส่งมา - ID ของผู้ใช้เจ้าของกิจกรรม
    DateTime? createdAt,
    this.isRecurring = false, // ค่าเริ่มต้น = false - ไม่ทำซ้ำ
    this.recurringWeekdays, // nullable - วันในสัปดาห์ที่ทำซ้ำ
    this.deadlineDate, // nullable - วันที่สิ้นสุดการทำซ้ำ
  }) : createdAt = createdAt ?? DateTime.now(); // ถ้าไม่ระบุ ใช้เวลาปัจจุบัน

  // ========================================
  // 🗄️ Database Methods - ฟังก์ชันจัดการฐานข้อมูล
  // ========================================
  
  /// แปลง Event object เป็น Map สำหรับบันทึกลงฐานข้อมูล SQLite
  /// 
  /// @return Map&lt;String, dynamic&gt; ข้อมูลที่พร้อมบันทึกลงฐานข้อมูล
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. แปลง DateTime objects เป็น String (ISO format)
  /// 2. แปลง bool เป็น int (0/1)
  /// 3. แปลง List&lt;int&gt; เป็น String คั่นด้วยจุลภาค
  /// 4. จัดรูปแบบข้อมูลให้ตรงกับโครงสร้างตารางในฐานข้อมูล
  /// 
  /// การใช้งาน:
  /// - บันทึกกิจกรรมใหม่ลงฐานข้อมูล
  /// - อัปเดตข้อมูลกิจกรรมที่มีอยู่
  /// - ส่งข้อมูลไปยัง EventRepository
  /// 
  /// ข้อควรระวัง:
  /// - DateTime จะถูกแปลงเป็น ISO string format
  /// - bool จะถูกแปลงเป็น int (true=1, false=0)
  /// - List จะถูกแปลงเป็น string คั่นด้วยจุลภาค
  /// - null values จะถูกเก็บเป็น null
  Map<String, dynamic> toMap() => {
    'id': id, // ID ในฐานข้อมูล (nullable)
    'title': title, // หัวข้อกิจกรรม
    'description': description, // คำอธิบาย
    'date': date.toIso8601String(), // แปลง DateTime เป็น String (ISO format)
    'user_id': userId, // ID ของผู้ใช้เจ้าของกิจกรรม
    'created_at': createdAt.toIso8601String(), // แปลง DateTime เป็น String (ISO format)
    'is_recurring': isRecurring ? 1 : 0, // แปลง bool เป็น int (true=1, false=0)
    'recurring_weekdays': recurringWeekdays?.join(','), // แปลง List&lt;int&gt; เป็น String คั่นด้วยจุลภาค หรือ null
    'deadline_date': deadlineDate
        ?.toIso8601String(), // แปลง DateTime เป็น String (ISO format) หรือ null
  };

  /// สร้าง Event object จาก Map ที่ได้จากฐานข้อมูล SQLite
  /// 
  /// @param map Map ที่ได้จากฐานข้อมูล SQLite
  /// @return Event object ที่สร้างจากข้อมูลในฐานข้อมูล
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. แปลง String กลับเป็น DateTime objects
  /// 2. แปลง int กลับเป็น bool
  /// 3. แปลง String กลับเป็น List<int>
  /// 4. สร้าง Event object ด้วยข้อมูลที่แปลงแล้ว
  /// 
  /// การใช้งาน:
  /// - ดึงข้อมูลกิจกรรมจากฐานข้อมูล
  /// - แปลงข้อมูลจาก SQLite query results
  /// - สร้าง Event objects จาก database rows
  /// 
  /// ข้อควรระวัง:
  /// - ต้องตรวจสอบว่า map มีข้อมูลครบถ้วน
  /// - DateTime parsing อาจ error หาก format ไม่ถูกต้อง
  /// - List parsing อาจ error หาก format ไม่ถูกต้อง
  /// - ควรมี error handling สำหรับข้อมูลที่ไม่ถูกต้อง
  factory Event.fromMap(Map<String, dynamic> map) => Event(
    id: map['id'], // ID จากฐานข้อมูล (nullable)
    title: map['title'], // หัวข้อกิจกรรม
    description: map['description'], // คำอธิบาย
    date: DateTime.parse(map['date']), // แปลง String เป็น DateTime
    userId: map['user_id'], // ID ของผู้ใช้เจ้าของกิจกรรม
    createdAt: DateTime.parse(map['created_at']), // แปลง String เป็น DateTime
    isRecurring: (map['is_recurring'] ?? 0) == 1, // แปลง int เป็น bool (1=true, 0=false)
    recurringWeekdays: map['recurring_weekdays'] != null
        ? (map['recurring_weekdays'] as String)
              .split(',') // แยก string ด้วยจุลภาค
              .map((e) => int.parse(e)) // แปลงแต่ละส่วนเป็น int
              .toList() // แปลงเป็น List<int>
        : null, // null หากไม่ใช่กิจกรรมที่ทำซ้ำ
    deadlineDate: map['deadline_date'] != null
        ? DateTime.parse(map['deadline_date']) // แปลง String เป็น DateTime
        : null, // null หากไม่มี deadline
  );

  // ========================================
  // 📄 JSON Methods - ฟังก์ชันจัดการ JSON
  // ========================================
  
  /// แปลง Event object เป็น JSON
  /// 
  /// @return Map<String, dynamic> ข้อมูลในรูปแบบ JSON
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. แปลง DateTime objects เป็น String (ISO format)
  /// 2. เก็บข้อมูลทั้งหมดในรูปแบบ JSON
  /// 3. รองรับการส่งผ่าน network หรือบันทึกลงไฟล์
  /// 
  /// การใช้งาน:
  /// - ส่งข้อมูลผ่าน API หรือ network
  /// - บันทึกข้อมูลลงไฟล์ JSON
  /// - แชร์ข้อมูลกิจกรรมระหว่างแอปพลิเคชัน
  /// - Backup ข้อมูลกิจกรรม
  /// 
  /// ข้อควรระวัง:
  /// - DateTime จะถูกแปลงเป็น ISO string format
  /// - ไม่รวม id และ createdAt (ใช้สำหรับ database เท่านั้น)
  /// - รองรับการทำงานกับ external systems
  /// - ควรตรวจสอบ JSON format ก่อนใช้งาน
  Map<String, dynamic> toJson() => {
    "date": date.toIso8601String(), // แปลง DateTime เป็น String (ISO format)
    "title": title, // หัวข้อกิจกรรม
    "description": description, // คำอธิบาย
    "userId": userId, // ID ของผู้ใช้เจ้าของกิจกรรม
    "isRecurring": isRecurring, // สถานะการทำซ้ำ (bool)
    "recurringWeekdays": recurringWeekdays, // วันในสัปดาห์ที่ทำซ้ำ (List<int>)
    "deadlineDate": deadlineDate?.toIso8601String(), // วันที่สิ้นสุดการทำซ้ำ (ISO string)
  };

  /// สร้าง Event object จาก JSON
  /// 
  /// @param json Map ที่ได้จาก JSON data
  /// @return Event object ที่สร้างจากข้อมูล JSON
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. แปลง String กลับเป็น DateTime objects
  /// 2. ตั้งค่า default values สำหรับข้อมูลที่ขาดหาย
  /// 3. สร้าง Event object ด้วยข้อมูลที่แปลงแล้ว
  /// 
  /// การใช้งาน:
  /// - อ่านข้อมูลจากไฟล์ JSON
  /// - รับข้อมูลจาก API หรือ network
  /// - Import ข้อมูลกิจกรรมจาก external sources
  /// - Restore ข้อมูลจาก backup
  /// 
  /// ข้อควรระวัง:
  /// - ต้องตรวจสอบว่า JSON มีข้อมูลครบถ้วน
  /// - DateTime parsing อาจ error หาก format ไม่ถูกต้อง
  /// - userId จะใช้ค่า default = 1 หากไม่ระบุ
  /// - isRecurring จะใช้ค่า default = false หากไม่ระบุ
  /// - ควรมี error handling สำหรับข้อมูลที่ไม่ถูกต้อง
  factory Event.fromJson(Map<String, dynamic> json) => Event(
    date: DateTime.parse(json["date"]), // แปลง String เป็น DateTime
    title: json["title"], // หัวข้อกิจกรรม
    description: json["description"], // คำอธิบาย
    userId: json["userId"] ?? 1, // ID ของผู้ใช้เจ้าของกิจกรรม (default = 1)
    isRecurring: json["isRecurring"] ?? false, // สถานะการทำซ้ำ (default = false)
    recurringWeekdays: json["recurringWeekdays"] != null
        ? List<int>.from(json["recurringWeekdays"]) // แปลงเป็น List<int>
        : null, // null หากไม่ใช่กิจกรรมที่ทำซ้ำ
    deadlineDate: json["deadlineDate"] != null
        ? DateTime.parse(json["deadlineDate"]) // แปลง String เป็น DateTime
        : null, // null หากไม่มี deadline
  );
}
