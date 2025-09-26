import 'package:flutter/material.dart';
import 'calendar_grid.dart';
import 'project_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E9),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('October 2025'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CalendarGrid(),
            const SizedBox(height: 20),
            ProjectCard(
              // ➕ เพิ่ม callback เมื่อกด Appointment
              onTapAppointment: () {
                Navigator.pushNamed(context, '/schedule');
              },
            ),
          ],
        ),
      ),
    );
  }
}
