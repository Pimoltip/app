import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/user.dart';

class UserRepository {
  final DatabaseService _dbService = DatabaseService();

  /// ✅ Load all users from SQLite
  Future<List<User>> loadUsers() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.usersTable,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  /// ✅ Add new user to SQLite
  Future<void> addUser(User user) async {
    final db = await _dbService.database;
    await db.insert(
      DatabaseService.usersTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ✅ Update user
  Future<void> updateUser(User user) async {
    final db = await _dbService.database;
    await db.update(
      DatabaseService.usersTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// ✅ Delete user
  Future<void> deleteUser(int id) async {
    final db = await _dbService.database;
    await db.delete(
      DatabaseService.usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ✅ Validate user login
  Future<bool> validateUser(String email, String password) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseService.usersTable,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }

  /// ✅ Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseService.usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  /// ✅ Get user by username
  Future<User?> getUserByUsername(String username) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseService.usersTable,
      where: 'name = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
}
