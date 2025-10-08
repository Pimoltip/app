import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // ✅ ใช้ AuthService

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _signUp() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรอกข้อมูลให้ครบทุกช่อง"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("รหัสผ่านไม่ตรงกัน"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.register(name, email, pass);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("สมัครสมาชิกสำเร็จ! 🎉"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("อีเมลนี้ถูกใช้แล้ว กรุณาใช้อีเมลอื่น"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
              Container(width: 230, height: 30, color: const Color(0xffb2bb1f)),
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
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Enter Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: passCtrl,
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
                controller: confirmCtrl,
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
                onPressed: _signUp, // ✅ ใช้ฟังก์ชัน SignUp จริง
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006866),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 150,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  "SIGN UP",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 150,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  "SIGN IN",
                  style: TextStyle(fontSize: 15, color: Color(0xff006866)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
