import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // ✅ ใช้ AuthService

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  /// ✅ ตรวจสอบ auto-login เมื่อเปิดแอป
  Future<void> _checkAutoLogin() async {
    final isLoggedIn = await _authService.isSessionValid();
    if (isLoggedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/calendar');
    }
  }

  void _login() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกอีเมลและรหัสผ่าน"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.login(email, pass);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("เข้าสู่ระบบสำเร็จ! 🎉"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/calendar');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("อีเมลหรือรหัสผ่านไม่ถูกต้อง"),
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
              Container(width: 230, height: 30, color: const Color(0xffb2bb1f)),
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
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Enter Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
              ElevatedButton(
                onPressed: _isLoading ? null : _login, // ✅ ใช้ฟังก์ชัน login
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
                child: _isLoading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "กำลังเข้าสู่ระบบ...",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ],
                      )
                    : const Text(
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
                    horizontal: 150,
                    vertical: 14,
                  ),
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
    );
  }
}
