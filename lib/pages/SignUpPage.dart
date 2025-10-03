import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Path สำหรับเก็บไฟล์
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user_data.json');
  }

  // อ่านหลายผู้ใช้
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

  // เขียน/เพิ่มผู้ใช้ใหม่
  Future<void> addUser(Map<String, dynamic> newUser) async {
    List<Map<String, dynamic>> users = await readUsers();
    users.add(newUser);
    final file = await _localFile;
    await file.writeAsString(jsonEncode(users));
  }

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    Map<String, dynamic> userData = {
      "name": nameController.text,
      "email": emailController.text,
      "password": passwordController.text,
    };

    await addUser(userData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User data saved!")),
    );

    // Clear fields
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  // ตัวอย่างปุ่มดูผู้ใช้ทั้งหมด
  void showAllUsers() async {
    List<Map<String, dynamic>> users = await readUsers();
    print("All users:");
    for (var user in users) {
      print("Name: ${user['name']}, Email: ${user['email']}, Password: ${user['password']}");
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
                const SizedBox(height: 10),
                Container(
                  width: 230,
                  height: 30,
                  color: const Color(0xffb2bb1f),
                ),
                const SizedBox(height: 10),
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
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
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
                const SizedBox(height: 24),
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
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006866),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 150, vertical: 14),
                  ),
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 150, vertical: 14),
                  ),
                  child: const Text(
                    "SIGN IN",
                    style: TextStyle(fontSize: 15, color: Color(0xff006866)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: showAllUsers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 150, vertical: 14),
                  ),
                  child: const Text(
                    "DATA",
                    style: TextStyle(fontSize: 15, color: Colors.white),
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
