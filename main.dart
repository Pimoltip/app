import 'package:flutter/material.dart';

import 'package:plannerapp/pages/calendar_page.dart';
import 'package:plannerapp/pages/add_event_page.dart';
import 'package:plannerapp/pages/weekly_page.dart';
import 'package:plannerapp/pages/login_page.dart';
import 'package:plannerapp/pages/SignUpPage.dart';

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const Signuppage(),
        '/calendar': (context) => const CalendarPage(),
        '/weekly': (context) => WeeklyPage(
            selectedDay: DateTime.now(),
            events: const [],
          ),
          AddEventPage.routeName: (context) => const AddEventPage(),
      },
    );
  }
}
