// Import Flutter framework สำหรับสร้าง UI
import 'package:flutter/material.dart';

// Import บริการ authentication
import '../services/auth_service.dart';

/// 📝 หน้าสมัครสมาชิก KU Planner
///
/// StatefulWidget สำหรับการสมัครสมาชิกใหม่
/// - แสดงธีม KU Planner พร้อมโลโก้
/// - รับข้อมูลชื่อ, อีเมล, รหัสผ่าน
/// - ตรวจสอบความถูกต้องของข้อมูล
/// - เรียก AuthService เพื่อสร้างบัญชีใหม่
/// - นำทางไปหน้าเข้าสู่ระบบเมื่อสำเร็จ
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers สำหรับจัดการข้อมูลในช่องกรอก
  final nameCtrl = TextEditingController(); // ตัวควบคุมช่องกรอกชื่อ
  final emailCtrl = TextEditingController(); // ตัวควบคุมช่องกรอกอีเมล
  final passCtrl = TextEditingController(); // ตัวควบคุมช่องกรอกรหัสผ่าน
  final confirmCtrl = TextEditingController(); // ตัวควบคุมช่องยืนยันรหัสผ่าน

  // Service สำหรับจัดการการสมัครสมาชิก
  final AuthService _authService = AuthService();

  // สถานะการโหลด (แสดง loading indicator)
  bool _isLoading = false;

  /// 📝 ฟังก์ชันสมัครสมาชิก
  ///
  /// รับข้อมูลจากผู้ใช้และตรวจสอบความถูกต้อง
  /// สร้างบัญชีใหม่ผ่าน AuthService
  void _signUp() async {
    // ดึงข้อมูลจากช่องกรอกและลบช่องว่าง
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    // ตรวจสอบว่ากรอกข้อมูลครบถ้วนหรือไม่
    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรอกข้อมูลให้ครบทุกช่อง"),
          backgroundColor: Colors.red,
        ),
      );
      return; // หยุดการทำงาน
    }

    // ตรวจสอบว่ารหัสผ่านตรงกันหรือไม่
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("รหัสผ่านไม่ตรงกัน"),
          backgroundColor: Colors.red,
        ),
      );
      return; // หยุดการทำงาน
    }

    // ตรวจสอบความยาวของรหัสผ่าน
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร"),
          backgroundColor: Colors.red,
        ),
      );
      return; // หยุดการทำงาน
    }

    // แสดง loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // เรียก service เพื่อสมัครสมาชิก
      final success = await _authService.register(name, email, pass);

      // ถ้าสำเร็จและ widget ยังคงอยู่ในหน้าจอ
      if (success) {
        if (mounted) {
          // แสดงข้อความสำเร็จ
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("สมัครสมาชิกสำเร็จ! 🎉"),
              backgroundColor: Colors.green,
            ),
          );
          // นำทางไปหน้าเข้าสู่ระบบ
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
      // ถ้าไม่สำเร็จและ widget ยังคงอยู่ในหน้าจอ
      else {
        if (mounted) {
          // แสดงข้อความผิดพลาด
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("อีเมลนี้ถูกใช้แล้ว กรุณาใช้อีเมลอื่น"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    // จัดการ error ที่อาจเกิดขึ้น
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // ทำความสะอาดเสมอ (ซ่อน loading indicator)
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// สร้าง UI ของหน้าสมัครสมาชิก KU Planner
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // สีพื้นหลังขาว
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // ระยะห่างจากขอบ 20 pixels
          child: Column(
            mainAxisSize: MainAxisSize.min, // ใช้พื้นที่น้อยที่สุด
            children: [
              // 🎨 โลโก้ KU - ตัวอักษรขนาดใหญ่
              const Text(
                "KU",
                style: TextStyle(
                  fontSize: 170, // ขนาดฟอนต์ 170
                  fontWeight: FontWeight.bold, // ตัวหนา
                  color: Color(0xff006866), // สีเขียวเข้ม KU
                  height: 0.9, // ความสูงของบรรทัด
                ),
              ),
              const SizedBox(height: 10), // ระยะห่าง 10 pixels
              // 📏 แถบสีเขียวอ่อน KU
              Container(
                width: 230, // กว้าง 230 pixels
                height: 30, // สูง 30 pixels
                color: const Color(0xffb2bb1f), // สีเขียวอ่อน KU
              ),
              const SizedBox(height: 10), // ระยะห่าง 10 pixels
              // 🏷️ ข้อความ "PLANER"
              const Text(
                "PLANER",
                style: TextStyle(
                  fontSize: 30, // ขนาดฟอนต์ 30
                  fontWeight: FontWeight.w900, // ตัวหนามาก
                  color: Color(0xff006866), // สีเขียวเข้ม KU
                ),
              ),
              const SizedBox(height: 24), // ระยะห่าง 24 pixels
              // 👤 ช่องกรอกชื่อ
              TextField(
                controller: nameCtrl, // ใช้ controller ที่สร้างไว้
                decoration: InputDecoration(
                  labelText: "Name", // ข้อความแสดงใน label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50), // มุมโค้งมน 50
                  ),
                ),
              ),
              const SizedBox(height: 24), // ระยะห่าง 24 pixels
              // 📧 ช่องกรอกอีเมล
              TextField(
                controller: emailCtrl, // ใช้ controller ที่สร้างไว้
                decoration: InputDecoration(
                  labelText: "Enter Email", // ข้อความแสดงใน label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50), // มุมโค้งมน 50
                  ),
                ),
              ),
              const SizedBox(height: 24), // ระยะห่าง 24 pixels
              // 🔒 ช่องกรอกรหัสผ่าน
              TextField(
                controller: passCtrl, // ใช้ controller ที่สร้างไว้
                obscureText: true, // ซ่อนข้อความ (แสดงเป็น dots)
                decoration: InputDecoration(
                  labelText: "Enter Password", // ข้อความแสดงใน label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50), // มุมโค้งมน 50
                  ),
                ),
              ),
              const SizedBox(height: 24), // ระยะห่าง 24 pixels
              // 🔐 ช่องยืนยันรหัสผ่าน
              TextField(
                controller: confirmCtrl, // ใช้ controller ที่สร้างไว้
                obscureText: true, // ซ่อนข้อความ (แสดงเป็น dots)
                decoration: InputDecoration(
                  labelText: "Confirm Password", // ข้อความแสดงใน label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50), // มุมโค้งมน 50
                  ),
                ),
              ),
              const SizedBox(height: 24), // ระยะห่าง 24 pixels
              // 📝 ปุ่มสมัครสมาชิก
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp, // ถ้ากำลังโหลด ห้ามกด
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006866), // สีเขียวเข้ม KU
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // มุมโค้งมน 50
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 150, // ระยะห่างซ้าย-ขวา 150 pixels
                    vertical: 14, // ระยะห่างบน-ล่าง 14 pixels
                  ),
                ),
                child: _isLoading
                    ? // แสดง loading indicator ขณะประมวลผล
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, // ความหนาของวงกลม 2
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white, // สีขาว
                              ),
                            ),
                          ),
                          SizedBox(width: 8), // ระยะห่าง 8 pixels
                          Text(
                            "กำลังสมัครสมาชิก...",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ],
                      )
                    : // แสดงข้อความปกติ
                      const Text(
                        "SIGN UP",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 24), // ระยะห่าง 24 pixels
              // 🔗 ปุ่มเข้าสู่ระบบ
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/login',
                  ); // ไปหน้าเข้าสู่ระบบ
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ), // สีขาว
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // มุมโค้งมน 50
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 150, // ระยะห่างซ้าย-ขวา 150 pixels
                    vertical: 14, // ระยะห่างบน-ล่าง 14 pixels
                  ),
                ),
                child: const Text(
                  "SIGN IN",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff006866),
                  ), // สีเขียวเข้ม KU
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
