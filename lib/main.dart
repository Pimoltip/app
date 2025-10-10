// Import Flutter framework สำหรับสร้าง UI
import 'package:flutter/material.dart';

// 📱 Import หน้าต่างๆ ของแอป
import 'pages/login_page.dart'; // หน้าเข้าสู่ระบบ
import 'pages/signup_page.dart'; // หน้าสมัครสมาชิก
import 'pages/dashboard_page.dart'; // หน้าแดชบอร์ดหลัก
import 'pages/calendar_page.dart'; // หน้าปฏิทิน
import 'pages/project_calendar.dart'; // หน้าปฏิทินโปรเจกต์
import 'pages/add_event_page.dart'; // หน้าเพิ่มกิจกรรม
import 'pages/new_project_page.dart'; // หน้าเพิ่มโปรเจกต์
import 'pages/weekly_page.dart'; // หน้ามุมมองรายสัปดาห์
import 'pages/appoinment_page.dart'; // หน้านัดหมาย

/// 🚀 จุดเริ่มต้นของแอปพลิเคชัน
/// ฟังก์ชันนี้จะถูกเรียกใช้เมื่อเปิดแอปเป็นครั้งแรก
/// runApp() จะเริ่มต้นแอปและแสดง MyApp widget
void main() {
  runApp(const MyApp());
}

/// 🏠 Widget หลักของแอปพลิเคชัน
///
/// StatelessWidget = Widget ที่ไม่มี state เปลี่ยนแปลง
/// ใช้สำหรับกำหนดโครงสร้างหลักของแอป เช่น:
/// - ธีม (สี, ฟอนต์)
/// - เส้นทางการนำทาง (routes)
/// - หน้าเริ่มต้น
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ปิด debug banner สีแดงที่มุมขวาบน (Debug mode)
      // banner จะแสดง "DEBUG" เมื่อรันในโหมด debug
      debugShowCheckedModeBanner: false,

      // ชื่อแอปที่แสดงใน task manager และ notification
      title: 'Planner App',

      // กำหนดธีมสีของแอป
      // ColorScheme.fromSeed = สร้างสีชุดจากสีหลัก (seedColor)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),

      // กำหนดหน้าแรกที่จะแสดงเมื่อเปิดแอป
      // จะแสดง LoginPage ก่อนเสมอ
      initialRoute: '/login',

      // 🗺️ กำหนดเส้นทางการนำทาง (Routes)
      // Dictionary ที่เก็บ mapping ระหว่าง URL กับ Widget
      // Navigator.pushNamed() จะใช้ routes เหล่านี้
      routes: {
        // หน้าเข้าสู่ระบบ - หน้าแรกที่ผู้ใช้จะเห็น
        '/login': (context) => const LoginPage(),

        // หน้าสมัครสมาชิก - สำหรับผู้ใช้ใหม่
        '/signup': (context) => const SignupPage(),

        // หน้าแดชบอร์ดหลัก - หน้าแรกหลังเข้าสู่ระบบ
        '/dashboard': (context) => const DashboardPage(),

        // หน้าปฏิทิน - แสดงปฏิทินทั่วไป
        '/calendar': (context) => const CalendarPage(),

        // หน้าปฏิทินโปรเจกต์ - แสดงปฏิทินเฉพาะโปรเจกต์
        '/home': (context) => const ProjectCalendar(),

        // หน้าเพิ่มกิจกรรม
        '/add': (context) => const AddEventPage(),
        // หน้าเพิ่มโปรเจกต์ใหม่
        '/new_project': (context) => const NewProjectPage(),

        // หน้ามุมมองรายสัปดาห์ - แสดงกิจกรรมในสัปดาห์
        '/weekly': (context) =>
            WeeklyPage(selectedDay: DateTime.now(), events: []),

        // หน้านัดหมาย - แสดงรายการนัดหมาย
        '/appointment': (context) =>
            AppointmentPage(selectedDate: DateTime.now()),
      },
    );
  }
}
