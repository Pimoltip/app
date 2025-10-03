import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class UserRepository {
  Future<File> _getUserFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<List<User>> loadUsers() async {
    final file = await _getUserFile();
    if (!(await file.exists())) {
      await file.writeAsString(jsonEncode([])); // ถ้าไม่มีไฟล์ -> สร้างใหม่
    }
    final content = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    return jsonList.map((e) => User.fromJson(e)).toList();
  }

  Future<void> saveUsers(List<User> users) async {
    final file = await _getUserFile();
    final jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<void> addUser(User newUser) async {
    final users = await loadUsers();
    users.add(newUser);
    await saveUsers(users);
  }

  Future<User?> login(String username, String password) async {
    final users = await loadUsers();
    try {
      return users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }
}
