import 'package:flutter/material.dart';

// 📱 Pages - หน้าต่างๆ ของแอป
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/calendar_page.dart';
import 'pages/project_calendar.dart';
import 'pages/add_event_page.dart';
import 'pages/new_project_page.dart';
import 'pages/weekly_page.dart';
import 'pages/appoinment_page.dart';

/// 🚀 จุดเริ่มต้นของแอปพลิเคชัน
/// เรียกใช้เมื่อเปิดแอป
void main() {
  runApp(const MyApp());
}

/// 🏠 Widget หลักของแอปพลิเคชัน
/// กำหนด theme, routes และการนำทาง
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ปิด debug banner ที่มุมขวาบน
      debugShowCheckedModeBanner: false,

      // ชื่อแอป
      title: 'Planner App',

      // ธีมสีเขียว
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),

      // เริ่มต้นที่หน้า login
      initialRoute: '/login',

      // 🗺️ กำหนดเส้นทางการนำทาง
      routes: {
        // หน้าเข้าสู่ระบบ
        '/login': (context) => const LoginPage(),

        // หน้าสมัครสมาชิก
        '/signup': (context) => const SignupPage(),

        // หน้าแดชบอร์ดหลัก
        '/dashboard': (context) => const DashboardPage(),

        // หน้าปฏิทิน
        '/calendar': (context) => const CalendarPage(),

        // หน้าปฏิทินโปรเจกต์
        '/home': (context) => const ProjectCalendar(),

        // หน้าเพิ่มกิจกรรม
        AddEventPage.routeName: (_) => const AddEventPage(),
        '/add': (context) => const AddEventPage(),

        // หน้าเพิ่มโปรเจกต์
        '/new_project': (context) => const NewProjectPage(),

        // หน้ามุมมองรายสัปดาห์
        '/weekly': (context) =>
            WeeklyPage(selectedDay: DateTime.now(), events: []),

        // หน้านัดหมาย
        '/schedule': (context) => AppointmentPage(selectedDate: DateTime.now()),
      },
    );
  }
}
