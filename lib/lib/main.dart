import 'package:flutter/material.dart';

// ✅ import ของ HomePage / SchedulePage
import 'pages/home_page.dart';
import 'appointment/schedule_page.dart';

// ✅ import ของ Planner App
import 'package:plannerapp/pages/calendar_page.dart';
import 'package:plannerapp/pages/add_event_page.dart';
import 'package:plannerapp/pages/dashboard_page.dart';
import 'package:plannerapp/pages/new_project_page.dart';
import 'package:plannerapp/pages/weekly_page.dart';
import 'package:plannerapp/pages/login_page.dart';
import 'package:plannerapp/pages/sign_up_page.dart';

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
        // ✅ Route จาก main ตัวแรก
        '/': (context) => const HomePage(),
        '/schedule': (context) => const SchedulePage(),

        // ✅ Route จาก PlannerApp
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/calendar': (context) => const CalendarPage(),
        '/weekly': (context) => WeeklyPage(
              selectedDay: DateTime.now(),
              events: const [],
            ),
        '/dashboard': (context) => const DashboardPage(),
        '/new_project': (context) => const NewProjectPage(),
        AddEventPage.routeName: (context) => const AddEventPage(),
      },
    );
  }
}
