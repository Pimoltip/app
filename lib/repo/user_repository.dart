import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class UserRepository {
  Future<File> _getUserFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/users.json");
  }

  /// โหลดผู้ใช้ทั้งหมด
  Future<List<User>> loadUsers() async {
    final file = await _getUserFile();
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    final data = jsonDecode(content) as List;
    return data.map((e) => User.fromJson(e)).toList();
  }

  /// บันทึกผู้ใช้ใหม่
  Future<void> addUser(User user) async {
    final users = await loadUsers();
    users.add(user);
    final file = await _getUserFile();
    await file.writeAsString(
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  /// ตรวจสอบ Login
  Future<bool> validateUser(String email, String password) async {
    final users = await loadUsers();
    return users.any((u) => u.email == email && u.password == password);
  }
}
