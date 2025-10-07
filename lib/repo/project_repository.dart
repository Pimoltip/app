import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/project.dart';

class ProjectRepository {
  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/projects.json';
  }

  Future<List<Project>> loadProjects() async {
    final path = await _getFilePath();
    final file = File(path);
    if (!await file.exists()) return [];

    final data = json.decode(await file.readAsString()) as List;
    return data.map((e) => Project.fromJson(e)).toList();
  }

  Future<void> saveProject(Project newProject) async {
    final path = await _getFilePath();
    final file = File(path);
    List<Project> projects = [];

    if (await file.exists()) {
      final data = json.decode(await file.readAsString()) as List;
      projects = data.map((e) => Project.fromJson(e)).toList();
    }

    projects.add(newProject);
    await file.writeAsString(
      json.encode(projects.map((e) => e.toJson()).toList()),
    );
  }
}
