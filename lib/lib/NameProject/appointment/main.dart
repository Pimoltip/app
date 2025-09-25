// main.dart
import 'package:flutter/material.dart';
import 'appointment.dart';
import 'appointment_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Appointment> appointments = [
      Appointment(
        code: "01371111-67",
        title: "สื่อสารมนุษย์และการเรียนรู้",
        location: "LH4-305",
        section: "Sec 800",
        startTime: DateTime(2025, 10, 8, 10, 0),
        endTime: DateTime(2025, 10, 8, 11, 0),
      ),
      Appointment(
        code: "01418212-65",
        title: "C Programming",
        location: "SC9-333",
        section: "Sec 800",
        startTime: DateTime(2025, 10, 8, 16, 0),
        endTime: DateTime(2025, 10, 8, 18, 0),
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Appointments"),
          backgroundColor: Colors.green,
        ),
        body: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return AppointmentCard(appointment: appointments[index]);
          },
        ),
      ),
    );
  }
}
