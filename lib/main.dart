import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/calendar_page.dart';
import 'pages/project_calendar.dart';
import 'pages/add_event_page.dart';
import 'pages/new_project_page.dart';
import 'pages/weekly_page.dart';
import 'pages/appoinment_page.dart';

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/calendar': (context) => const CalendarPage(),
        '/home': (context) => const ProjectCalendar(),
        '/add': (context) => const AddEventPage(),
        '/new_project': (context) => const NewProjectPage(),
        '/weekly': (context) => WeeklyPage(selectedDay: DateTime.now()),
        '/appointment': (context) => AppointmentPage(selectedDate: DateTime.now()),
      },
    );
  }
}
