// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import '../models/event.dart'; // Model สำหรับกิจกรรม
import '../repo/event_repository.dart'; // Repository สำหรับจัดการข้อมูลกิจกรรม

/// =======================
/// 🔄 RECURRING EVENT SERVICE - จัดการกิจกรรมที่ทำซ้ำ
/// =======================
/// 
/// Service class สำหรับจัดการกิจกรรมที่ทำซ้ำตามวันในสัปดาห์
/// หน้าที่หลัก:
/// 1. สร้างกิจกรรมที่ทำซ้ำตามวันในสัปดาห์ที่กำหนด
/// 2. ดึงข้อมูลกิจกรรมสำหรับวันที่เฉพาะ (รวมกิจกรรมที่ทำซ้ำ)
/// 3. ดึงข้อมูลกิจกรรมสำหรับช่วงวันที่ (รวมกิจกรรมที่ทำซ้ำ)
/// 4. จัดการการลบและอัปเดตกิจกรรมที่ทำซ้ำ
/// 5. ตรวจสอบการหมดอายุของกิจกรรมที่ทำซ้ำ
/// 
/// ฟีเจอร์หลัก:
/// - Recurring Event Generation
/// - Weekly Pattern Management
/// - Date Range Filtering
/// - Deadline Handling
/// - Event CRUD Operations
/// - Performance Optimization
/// 
/// การทำงาน:
/// - ใช้ EventRepository สำหรับจัดการข้อมูลกิจกรรม
/// - รองรับการทำงานแบบ asynchronous
/// - จัดการการทำซ้ำตามวันในสัปดาห์ (1=จันทร์, 7=อาทิตย์)
/// - รองรับการกำหนด deadline สำหรับกิจกรรมที่ทำซ้ำ
/// 
/// ระบบการทำซ้ำ:
/// - รองรับการทำซ้ำหลายวันในสัปดาห์
/// - เริ่มต้นจากวันที่กำหนดจนถึงวันที่สิ้นสุด
/// - ตรวจสอบ deadline เพื่อหยุดการทำซ้ำ
/// - สร้างกิจกรรมแยกสำหรับแต่ละวัน
class RecurringEventService {
  // ========================================
  // 🔧 Repository Instance - อินสแตนซ์ของ Repository
  // ========================================
  
  /// Repository สำหรับจัดการข้อมูลกิจกรรมในฐานข้อมูล SQLite
  final EventRepository _eventRepository = EventRepository();

  // ========================================
  // 🔄 Event Generation Methods - ฟังก์ชันสร้างกิจกรรม
  // ========================================
  
  /// สร้างกิจกรรมที่ทำซ้ำตามวันในสัปดาห์
  /// 
  /// @param baseEvent กิจกรรมต้นแบบที่จะใช้สร้างกิจกรรมซ้ำ
  /// @param startDate วันที่เริ่มต้นการสร้างกิจกรรมซ้ำ
  /// @param endDate วันที่สิ้นสุดการสร้างกิจกรรมซ้ำ
  /// @return Future<List<Event>> รายการกิจกรรมที่สร้างขึ้น (รวมกิจกรรมต้นแบบ)
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. ตรวจสอบว่าเป็นกิจกรรมที่ทำซ้ำหรือไม่
  /// 2. วนลูปผ่านแต่ละวันในสัปดาห์ที่กำหนด
  /// 3. หาวันแรกของสัปดาห์ที่ตรงกับวันในสัปดาห์ที่ต้องการ
  /// 4. สร้างกิจกรรมซ้ำในแต่ละสัปดาห์จนถึงวันที่สิ้นสุด
  /// 5. ตรวจสอบ deadline เพื่อหยุดการสร้างกิจกรรม
  /// 
  /// ระบบการทำซ้ำ:
  /// - รองรับการทำซ้ำหลายวันในสัปดาห์ (เช่น จันทร์, พุธ, ศุกร์)
  /// - เริ่มต้นจากวันที่กำหนดและไปทีละสัปดาห์
  /// - หยุดเมื่อถึงวันที่สิ้นสุดหรือ deadline
  /// - สร้างกิจกรรมแยกสำหรับแต่ละวัน (ไม่ทำซ้ำอีก)
  /// 
  /// การใช้งาน:
  /// - สร้างกิจกรรมรายสัปดาห์ (เช่น คลาสเรียน, การประชุม)
  /// - สร้างกิจกรรมที่ต้องทำเป็นประจำ
  /// - จัดการกิจกรรมที่มีรูปแบบการทำซ้ำที่ซับซ้อน
  /// 
  /// ข้อควรระวัง:
  /// - กิจกรรมที่สร้างแล้วจะไม่ทำซ้ำอีก (isRecurring = false)
  /// - เวลาของกิจกรรมจะใช้จากกิจกรรมต้นแบบ
  /// - ควรตรวจสอบ deadline เพื่อป้องกันการสร้างกิจกรรมมากเกินไป
  Future<List<Event>> generateRecurringEvents(
    Event baseEvent,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Event> recurringEvents = [];

    // ตรวจสอบว่าเป็นกิจกรรมที่ทำซ้ำหรือไม่
    if (!baseEvent.isRecurring || baseEvent.recurringWeekdays == null) {
      // หากไม่ใช่กิจกรรมที่ทำซ้ำ ให้ส่งกลับกิจกรรมต้นแบบเท่านั้น
      return [baseEvent];
    }

    // สร้างกิจกรรมซ้ำสำหรับแต่ละวันในสัปดาห์ที่กำหนด
    for (final weekday in baseEvent.recurringWeekdays!) {
      DateTime currentDate = startDate;
      
      // หาวันแรกของสัปดาห์ที่ตรงกับ weekday ที่ต้องการ
      while (currentDate.weekday != weekday) {
        currentDate = currentDate.add(const Duration(days: 1));
      }

      // สร้างกิจกรรมซ้ำในแต่ละสัปดาห์จนถึงวันที่สิ้นสุด
      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        // ตรวจสอบว่ายังไม่เกิน deadline (ถ้ามี)
        if (baseEvent.deadlineDate != null && currentDate.isAfter(baseEvent.deadlineDate!)) {
          break; // หยุดการสร้างกิจกรรมหากเกิน deadline
        }

        // สร้างกิจกรรมใหม่สำหรับวันนี้
        final recurringEvent = Event(
          title: baseEvent.title, // ใช้ชื่อจากกิจกรรมต้นแบบ
          description: baseEvent.description, // ใช้คำอธิบายจากกิจกรรมต้นแบบ
          date: DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            baseEvent.date.hour, // ใช้เวลาจากกิจกรรมต้นแบบ
            baseEvent.date.minute, // ใช้เวลาจากกิจกรรมต้นแบบ
          ),
          userId: baseEvent.userId, // ใช้ user ID จากกิจกรรมต้นแบบ
          isRecurring: false, // กิจกรรมที่สร้างแล้วไม่ทำซ้ำอีก
          createdAt: baseEvent.createdAt, // ใช้เวลาสร้างจากกิจกรรมต้นแบบ
        );

        recurringEvents.add(recurringEvent);

        // ไปยังสัปดาห์ถัดไป
        currentDate = currentDate.add(const Duration(days: 7));
      }
    }

    return recurringEvents;
  }

  // ========================================
  // 📊 Event Retrieval Methods - ฟังก์ชันดึงข้อมูลกิจกรรม
  // ========================================
  
  /// ดึงกิจกรรมทั้งหมดสำหรับวันที่เฉพาะ (รวมกิจกรรมที่ทำซ้ำ)
  /// 
  /// @param userId ID ของผู้ใช้
  /// @param date วันที่ที่ต้องการดึงข้อมูลกิจกรรม
  /// @return Future<List<Event>> รายการกิจกรรมทั้งหมดที่ควรแสดงในวันนั้น
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. ดึงกิจกรรมทั้งหมดของผู้ใช้จากฐานข้อมูล
  /// 2. วนลูปผ่านกิจกรรมทั้งหมด
  /// 3. สำหรับกิจกรรมที่ทำซ้ำ: ตรวจสอบว่าวันนี้อยู่ในรายการวันที่ทำซ้ำหรือไม่
  /// 4. สำหรับกิจกรรมปกติ: ตรวจสอบว่าตรงกับวันที่หรือไม่
  /// 5. สร้างกิจกรรมใหม่สำหรับกิจกรรมที่ทำซ้ำ
  /// 6. ตรวจสอบ deadline เพื่อกรองกิจกรรมที่หมดอายุ
  /// 
  /// ระบบการกรอง:
  /// - กิจกรรมปกติ: ตรวจสอบวันที่ตรงกัน
  /// - กิจกรรมที่ทำซ้ำ: ตรวจสอบวันในสัปดาห์และ deadline
  /// - สร้างกิจกรรมใหม่สำหรับกิจกรรมที่ทำซ้ำ (ไม่แก้ไขต้นฉบับ)
  /// 
  /// การใช้งาน:
  /// - แสดงกิจกรรมในหน้า appointment
  /// - แสดงกิจกรรมในปฏิทิน
  /// - ดึงข้อมูลกิจกรรมสำหรับวันที่เฉพาะ
  /// 
  /// ข้อควรระวัง:
  /// - กิจกรรมที่ทำซ้ำจะสร้างใหม่ทุกครั้ง (ไม่แก้ไขต้นฉบับ)
  /// - ควรตรวจสอบ deadline เพื่อไม่แสดงกิจกรรมที่หมดอายุ
  /// - Performance อาจช้าลงหากมีกิจกรรมจำนวนมาก
  Future<List<Event>> getEventsForDate(int userId, DateTime date) async {
    // ดึงกิจกรรมทั้งหมดของผู้ใช้
    final allEvents = await _eventRepository.loadEvents(userId);
    final List<Event> eventsForDate = [];

    // กรองกิจกรรมที่ตรงกับวันที่
    for (final event in allEvents) {
      if (event.isRecurring && event.recurringWeekdays != null) {
        // ตรวจสอบว่าวันนี้อยู่ในรายการวันที่ทำซ้ำหรือไม่
        if (event.recurringWeekdays!.contains(date.weekday)) {
          // ตรวจสอบว่ายังไม่เกิน deadline (ถ้ามี)
          if (event.deadlineDate == null || !date.isAfter(event.deadlineDate!)) {
            // สร้างกิจกรรมสำหรับวันนี้
            final recurringEvent = Event(
              title: event.title, // ใช้ชื่อจากกิจกรรมต้นแบบ
              description: event.description, // ใช้คำอธิบายจากกิจกรรมต้นแบบ
              date: DateTime(
                date.year, // ใช้ปีจากวันที่ที่ต้องการ
                date.month, // ใช้เดือนจากวันที่ที่ต้องการ
                date.day, // ใช้วันจากวันที่ที่ต้องการ
                event.date.hour, // ใช้เวลาจากกิจกรรมต้นแบบ
                event.date.minute, // ใช้เวลาจากกิจกรรมต้นแบบ
              ),
              userId: event.userId, // ใช้ user ID จากกิจกรรมต้นแบบ
              isRecurring: false, // กิจกรรมที่แสดงแล้วไม่ทำซ้ำอีก
              createdAt: event.createdAt, // ใช้เวลาสร้างจากกิจกรรมต้นแบบ
            );
            eventsForDate.add(recurringEvent);
          }
        }
      } else {
        // กิจกรรมปกติ - ตรวจสอบว่าตรงกับวันที่หรือไม่
        if (event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day) {
          eventsForDate.add(event);
        }
      }
    }

    return eventsForDate;
  }

  /// ดึงกิจกรรมทั้งหมดสำหรับช่วงวันที่ (รวมกิจกรรมที่ทำซ้ำ)
  /// 
  /// @param userId ID ของผู้ใช้
  /// @param startDate วันที่เริ่มต้น
  /// @param endDate วันที่สิ้นสุด
  /// @return Future<List<Event>> รายการกิจกรรมทั้งหมดในช่วงวันที่ที่กำหนด
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. วนลูปผ่านแต่ละวันในช่วงวันที่
  /// 2. เรียกใช้ getEventsForDate สำหรับแต่ละวัน
  /// 3. รวมกิจกรรมทั้งหมดจากทุกวัน
  /// 4. ส่งกลับรายการกิจกรรมที่รวมแล้ว
  /// 
  /// การใช้งาน:
  /// - แสดงกิจกรรมในหน้า weekly view
  /// - ดึงข้อมูลกิจกรรมสำหรับช่วงเวลาที่กำหนด
  /// - สร้างรายงานกิจกรรมรายสัปดาห์หรือรายเดือน
  /// 
  /// ข้อควรระวัง:
  /// - Performance อาจช้าลงหากช่วงเวลายาวมาก
  /// - ควรจำกัดช่วงเวลาเพื่อป้องกันการดึงข้อมูลมากเกินไป
  /// - กิจกรรมที่ทำซ้ำจะถูกสร้างใหม่สำหรับแต่ละวัน
  Future<List<Event>> getEventsForDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Event> allEventsInRange = [];

    // วนลูปผ่านแต่ละวันในช่วงวันที่
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // ดึงกิจกรรมสำหรับวันนี้
      final eventsForDay = await getEventsForDate(userId, currentDate);
      allEventsInRange.addAll(eventsForDay);
      
      // ไปยังวันถัดไป
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return allEventsInRange;
  }

  // ========================================
  // 🔧 Event Management Methods - ฟังก์ชันจัดการกิจกรรม
  // ========================================
  
  /// ลบกิจกรรมที่ทำซ้ำทั้งหมด
  /// 
  /// @param baseEvent กิจกรรมต้นแบบที่จะลบ
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. ตรวจสอบว่า baseEvent มี ID หรือไม่
  /// 2. เรียกใช้ EventRepository.deleteEvent เพื่อลบกิจกรรม
  /// 
  /// การใช้งาน:
  /// - ลบกิจกรรมที่ทำซ้ำทั้งหมดที่เกี่ยวข้องกับกิจกรรมต้นแบบ
  /// - ใช้เมื่อผู้ใช้ต้องการยกเลิกกิจกรรมที่ทำซ้ำ
  /// 
  /// ข้อควรระวัง:
  /// - การลบจะเป็นการลบกิจกรรมต้นแบบเท่านั้น
  /// - กิจกรรมที่สร้างแล้วจะไม่ถูกลบอัตโนมัติ
  /// - ควรมีการยืนยันจากผู้ใช้ก่อนลบ
  /// - ควรมีการ backup ข้อมูลก่อนลบ
  Future<void> deleteRecurringEvents(Event baseEvent) async {
    if (baseEvent.id != null) {
      await _eventRepository.deleteEvent(baseEvent.id!);
    }
  }

  /// อัปเดตกิจกรรมที่ทำซ้ำทั้งหมด
  /// 
  /// @param baseEvent กิจกรรมต้นแบบที่อัปเดตแล้ว
  /// @return Future<void> ไม่มี return value
  /// 
  /// ขั้นตอนการทำงาน:
  /// 1. ตรวจสอบว่า baseEvent มี ID หรือไม่
  /// 2. เรียกใช้ EventRepository.updateEvent เพื่ออัปเดตกิจกรรม
  /// 
  /// การใช้งาน:
  /// - อัปเดตกิจกรรมที่ทำซ้ำทั้งหมดที่เกี่ยวข้องกับกิจกรรมต้นแบบ
  /// - ใช้เมื่อผู้ใช้แก้ไขข้อมูลกิจกรรมที่ทำซ้ำ
  /// 
  /// ข้อควรระวัง:
  /// - การอัปเดตจะเป็นการอัปเดตกิจกรรมต้นแบบเท่านั้น
  /// - กิจกรรมที่สร้างแล้วจะไม่ถูกอัปเดตอัตโนมัติ
  /// - ควรมีการแจ้งเตือนผู้ใช้เกี่ยวกับการเปลี่ยนแปลง
  /// - ควรมีการตรวจสอบความถูกต้องของข้อมูลก่อนอัปเดต
  Future<void> updateRecurringEvents(Event baseEvent) async {
    if (baseEvent.id != null) {
      await _eventRepository.updateEvent(baseEvent);
    }
  }
}
