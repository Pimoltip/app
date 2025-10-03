import 'package:flutter/material.dart';

// ✅ import ของ HomePage / SchedulePage
import 'pages/home_page.dart';
import 'appointment/schedule_page.dart';

// ✅ import ของ Planner App
import 'package:plannerapp/pages/calendar_page.dart';
import 'package:plannerapp/pages/AddEventPage.dart';
import 'package:plannerapp/pages/dashboard_page.dart';
import 'package:plannerapp/pages/new_project_page.dart';
import 'package:plannerapp/pages/weekly_page.dart';
import 'package:plannerapp/pages/login_page.dart';
import 'package:plannerapp/pages/Signuppage.dart';

import 'package:plannerapp/appointment/day_selector.dart';
import 'package:plannerapp/pages/calendar_grid.dart';
import 'package:plannerapp/appointment/event_card.dart';
import 'package:plannerapp/appointment/time_line.dart';
import 'package:plannerapp/pages/info_box.dart';
import 'package:plannerapp/pages/project_card.dart';
import 'package:plannerapp/data/tab_tag.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planner App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),

      // ✅ ตั้งค่า initialRoute ตามที่คุณต้องการเริ่ม (เลือกได้)
      // เช่นถ้าอยากเริ่มที่หน้า login
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const Signuppage(),
        '/calendar': (context) => const CalendarPage(), // ✅ ไม่มี back button
        AddEventPage.routeName: (_) => const AddEventPage(),
        '/weekly': (context) => WeeklyPage(selectedDay: DateTime.now(), events: []),
        '/dashboard': (context) => const DashboardPage(),
        '/add': (context) => const AddEventPage(),
        '/new_project': (context) => const NewProjectPage(),
        '/schedule': (context) =>
            SchedulePage(selectedDay: DateTime.now()),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
