import 'package:flutter/material.dart';
import 'name_project.dart';
import 'name_project_ui.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NameProjectUI(
        project: NameProject(
          title: "Name Project",
          countdowns: 45,
          progress: 100,
          appointment: DateTime(2025, 7, 22),
        ),
      ),
    ),
  );
}
