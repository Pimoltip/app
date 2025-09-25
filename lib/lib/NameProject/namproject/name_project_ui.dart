import 'package:flutter/material.dart';
import 'name_project.dart';
import 'calendar_widget.dart';

class NameProjectUI extends StatelessWidget {
  final NameProject project;

  const NameProjectUI({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 239, 224),
      appBar: AppBar(
        title: const Text("October 2025"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 63, 165, 32),
      ),
      body: Column(
        children: [
          // ปฏิทิน
          const CalendarWidget(daysInMonth: 31),

          const SizedBox(height: 16),

          // Project Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 234, 221, 188),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // แถวข้อมูล
                  Row(
                    children: [
                      _infoCard(
                        icon: Icons.calendar_today,
                        label: "Countdowns",
                        value: "${project.countdowns}",
                      ),
                      const SizedBox(width: 12),
                      _infoCard(
                        icon: Icons.hourglass_bottom,
                        label: "In-Progress",
                        value: "${project.progress.toStringAsFixed(0)}%",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Appointment",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 120, 207, 123),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_dayOfWeek(project.appointment)} "
                      "${project.appointment.day} "
                      "${_monthName(project.appointment.month)} "
                      "${project.appointment.year}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // การ์ดย่อย
  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Colors.green),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }

  // Helper
  static String _dayOfWeek(DateTime date) {
    const days = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
    ];
    return days[date.weekday % 7];
  }

  static String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}
