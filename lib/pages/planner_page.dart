import 'package:flutter/material.dart';

class PlannerPage extends StatelessWidget {
  final DateTime selectedDay;

  const PlannerPage({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    // format วันที่ให้อ่านง่าย
    final formattedDate =
        "${selectedDay.day}-${selectedDay.month}-${selectedDay.year}";

    // mock data (ในอนาคตคุณจะดึงจาก Map<DateTime, List> _events)
    final tasks = [
      "Meeting with advisor",
      "Submit assignment",
      "Group project discussion"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Planner: $formattedDate"),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(tasks[index]),
          );
        },
      ),
    );
  }
}
