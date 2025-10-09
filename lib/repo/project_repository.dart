import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/project.dart';

class ProjectRepository {
  final DatabaseService _dbService = DatabaseService();

  /// ✅ Load all projects from SQLite
  Future<List<Project>> loadProjects() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.projectsTable,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }

  /// ✅ Add new project to SQLite
  Future<void> addProject(Project project) async {
    final db = await _dbService.database;
    await db.insert(
      DatabaseService.projectsTable,
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ✅ Update project
  Future<void> updateProject(Project project) async {
    final db = await _dbService.database;
    await db.update(
      DatabaseService.projectsTable,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  /// ✅ Delete project by ID
  Future<void> deleteProject(int id) async {
    final db = await _dbService.database;
    await db.delete(
      DatabaseService.projectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ✅ Delete project by name
  Future<void> deleteProjectByName(String name) async {
    final db = await _dbService.database;
    await db.delete(
      DatabaseService.projectsTable,
      where: 'name = ?',
      whereArgs: [name],
    );
  }
}
