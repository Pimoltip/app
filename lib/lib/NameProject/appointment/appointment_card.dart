// appointment_card.dart
import 'package:flutter/material.dart';
import 'appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({Key? key, required this.appointment})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.code,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(appointment.title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              "${appointment.location} | ${appointment.section}",
              style: const TextStyle(color: Color.fromARGB(255, 119, 172, 96)),
            ),
            const SizedBox(height: 6),
            Text(
              "${appointment.formatTime(appointment.startTime)} - "
              "${appointment.formatTime(appointment.endTime)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
