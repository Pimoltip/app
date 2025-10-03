import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user_data.json');
  }

  // อ่านผู้ใช้ทั้งหมด
  Future<List<Map<String, dynamic>>> readUsers() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];
      String jsonString = await file.readAsString();
      List<dynamic> users = jsonDecode(jsonString);
      return users.cast<Map<String, dynamic>>();
    } catch (e) {
      print("Error reading JSON: $e");
      return [];
    }
  }

  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    List<Map<String, dynamic>> users = await readUsers();

    bool found = users.any((user) =>
        user['email'] == email && user['password'] == password);

    if (found) {
      // ถ้าเจอผู้ใช้ตรงกัน
      Navigator.pushNamed(context, '/calendar');
    } else {
      // แสดงข้อความผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email or Password incorrect")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "KU",
                  style: TextStyle(
                    fontSize: 170,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff006866),
                    height: 0.9,
                  ),
                ),
                Container(
                  width: 230,
                  height: 30,
                  color: const Color(0xffb2bb1f),
                ),
                const Text(
                  "PLANER",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff006866),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Enter Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006866),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 150, vertical: 14),
                  ),
                  child: const Text(
                    "SIGN IN",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 253, 253),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 150, vertical: 14),
                  ),
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(fontSize: 15, color: Color(0xff006866)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
