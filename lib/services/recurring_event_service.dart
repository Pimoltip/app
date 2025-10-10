// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import '../models/event.dart'; // Model สำหรับกิจกรรม
import '../repo/event_repository.dart'; // Repository สำหรับจัดการข้อมูลกิจกรรม

/// 🔄 RecurringEventService สำหรับจัดการกิจกรรมที่ทำซ้ำ
///
/// Service ที่จัดการการสร้างกิจกรรมที่ทำซ้ำตามวันในสัปดาห์
/// และการกรองกิจกรรมที่แสดงในหน้า appointment และ weekly
class RecurringEventService {
  final EventRepository _eventRepository = EventRepository();

  /// 📅 สร้างกิจกรรมที่ทำซ้ำตามวันในสัปดาห์
  ///
  /// รับกิจกรรมต้นแบบและสร้างกิจกรรมซ้ำตามวันในสัปดาห์ที่กำหนด
  /// ตั้งแต่วันที่เริ่มต้นจนถึงวันที่สิ้นสุด
  Future<List<Event>> generateRecurringEvents(
    Event baseEvent,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Event> recurringEvents = [];

    // ถ้าไม่ใช่กิจกรรมที่ทำซ้ำ ให้ส่งกลับกิจกรรมต้นแบบเท่านั้น
    if (!baseEvent.isRecurring || baseEvent.recurringWeekdays == null) {
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
          break;
        }

        // สร้างกิจกรรมใหม่สำหรับวันนี้
        final recurringEvent = Event(
          title: baseEvent.title,
          description: baseEvent.description,
          date: DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            baseEvent.date.hour,
            baseEvent.date.minute,
          ),
          userId: baseEvent.userId,
          isRecurring: false, // กิจกรรมที่สร้างแล้วไม่ทำซ้ำอีก
          createdAt: baseEvent.createdAt,
        );

        recurringEvents.add(recurringEvent);

        // ไปยังสัปดาห์ถัดไป
        currentDate = currentDate.add(const Duration(days: 7));
      }
    }

    return recurringEvents;
  }

  /// 📋 ดึงกิจกรรมทั้งหมดสำหรับวันที่เฉพาะ (รวมกิจกรรมที่ทำซ้ำ)
  ///
  /// รับ userId และวันที่ แล้วส่งกลับกิจกรรมทั้งหมดที่ควรแสดงในวันนั้น
  /// รวมทั้งกิจกรรมปกติและกิจกรรมที่ทำซ้ำ
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
              title: event.title,
              description: event.description,
              date: DateTime(
                date.year,
                date.month,
                date.day,
                event.date.hour,
                event.date.minute,
              ),
              userId: event.userId,
              isRecurring: false, // กิจกรรมที่แสดงแล้วไม่ทำซ้ำอีก
              createdAt: event.createdAt,
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

  /// 📅 ดึงกิจกรรมทั้งหมดสำหรับช่วงวันที่ (รวมกิจกรรมที่ทำซ้ำ)
  ///
  /// รับ userId และช่วงวันที่ แล้วส่งกลับกิจกรรมทั้งหมดที่ควรแสดงในช่วงนั้น
  Future<List<Event>> getEventsForDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Event> allEventsInRange = [];

    // วนลูปผ่านแต่ละวันในช่วงวันที่
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final eventsForDay = await getEventsForDate(userId, currentDate);
      allEventsInRange.addAll(eventsForDay);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return allEventsInRange;
  }

  /// 🗑️ ลบกิจกรรมที่ทำซ้ำทั้งหมด
  ///
  /// รับ baseEvent และลบกิจกรรมที่ทำซ้ำทั้งหมดที่เกี่ยวข้อง
  Future<void> deleteRecurringEvents(Event baseEvent) async {
    if (baseEvent.id != null) {
      await _eventRepository.deleteEvent(baseEvent.id!);
    }
  }

  /// ✏️ อัปเดตกิจกรรมที่ทำซ้ำทั้งหมด
  ///
  /// รับ baseEvent ใหม่และอัปเดตกิจกรรมที่ทำซ้ำทั้งหมดที่เกี่ยวข้อง
  Future<void> updateRecurringEvents(Event baseEvent) async {
    if (baseEvent.id != null) {
      await _eventRepository.updateEvent(baseEvent);
    }
  }
}
