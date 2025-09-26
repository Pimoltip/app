import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'appointment/schedule_page.dart'; // ➕ import SchedulePage

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/schedule': (_) =>
            const SchedulePage(), // ➕ เพิ่ม Route ไปหน้าตารางนัดหมาย
      },
    );
  }
}
