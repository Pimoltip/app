import 'package:flutter/material.dart'; // framework สำหรับสร้าง UI
import '../services/auth_service.dart'; // บริการ authentication ตัวจัดการการlogin ออกจากระบบ ถานะของผู้ใช้ในแอป

/// 🔐 หน้าเข้าสู่ระบบ KU Planner
/// StatefulWidget สำหรับการเข้าสู่ระบบ
/// - แสดงธีม KU Planner พร้อมโลโก้
/// - ตรวจสอบ auto-login เมื่อเปิดแอป
/// - รับข้อมูลอีเมลและรหัสผ่าน
/// - เรียก AuthService เพื่อยืนยันตัวตน
/// - นำทางไปหน้าปฏิทินเมื่อเข้าสู่ระบบสำเร็จ

// เหมือนหน้า SignupPage ----------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
} 

class _LoginPageState extends State<LoginPage> {
  // Controllers สำหรับจัดการข้อมูลในช่องกรอก
  final emailCtrl = TextEditingController(); // ตัวควบคุมช่องกรอกอีเมล
  final passCtrl = TextEditingController(); // ตัวควบคุมช่องกรอกรหัสผ่าน
  final AuthService _authService = AuthService(); // Service สำหรับจัดการการเข้าสู่ระบบ
  bool _isLoading = false; 
  // ^ เหมือนหน้า SignupPage -------------
  
  /// ฟังก์ชันที่เรียกเมื่อ widget ถูกสร้าง ตรวจสอบการเข้าสู่ระบบอัตโนมัติ
  @override
  void initState() { //"ขั้นตอนการเตรียมความพร้อม"
    super.initState();
    _checkAutoLogin(); // ตรวจสอบ auto-login ก่อนที่จะแสดงหน้าจอ Login ให้ผู้ใช้เห็น
  } //-------------

  /// 🔄 ตรวจสอบ auto-login เมื่อเปิดแอป ตรวจสอบความถูกต้องของ Session และการตัดสินใจนำทาง
  Future<void> _checkAutoLogin() async {
    final isLoggedIn = await _authService.isSessionValid(); // ตรวจสอบว่ามี session ที่ถูกต้องหรือไม่
    
    if (isLoggedIn && mounted) { // ถ้าเข้าสู่ระบบแล้วและ widget ยังคงอยู่ในหน้าจอ
      Navigator.pushReplacementNamed(context, '/calendar'); // นำทางไปหน้าปฏิทิน (แทนที่หน้า login)
    }
  } //-----------------------------

  /// 🔐 ฟังก์ชัน _login รับข้อมูลอีเมลและรหัสผ่านจากผู้ใช้ ตรวจสอบความถูกต้องครบถ้วน และเข้าสู่ระบบ
  void _login() async {
    // ดึงข้อมูลจากช่องกรอกและลบช่องว่าง
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    
    if (email.isEmpty || pass.isEmpty) { // 📝 ดึงและตรวจสอบข้อมูลเบื้องต้นครบถ้วนหรือไม่
      // แสดงข้อความแจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกอีเมลและรหัสผ่าน"),
          backgroundColor: Colors.red,
        ),
      );
      return; // หยุดการทำงาน
    }

    setState(() { // 🚦 แสดงสถานะการโหลด loading indicator
      _isLoading = true;
    });

    try { //🔍 ยืนยันตัวตนกับระบบ (Try-Catch Block)
      // เรียก service เพื่อเข้าสู่ระบบ
      final success = await _authService.login(email, pass); //สั่งงานไปAuthServiceให้ตรวจสอบอีเมลและรหัสผ่านกับฐานข้อมูลโค้ดawait รอผลลัพธ์

      //🎉 จัดการผลลัพธ์และนำทาง ถ้าสำเร็จและ widget ยังคงอยู่ในหน้าจอ
      if (success) {
        if (mounted) {
          // แสดงข้อความสำเร็จ
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("เข้าสู่ระบบสำเร็จ! 🎉"),
              backgroundColor: Colors.green,
            ),
          );
          // นำทางไปหน้าปฏิทิน
          Navigator.pushReplacementNamed(context, '/calendar');
        }
      }
      // ถ้าไม่สำเร็จและ widget ยังคงอยู่ในหน้าจอ
      else {
        if (mounted) {
          // แสดงข้อความผิดพลาด
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("อีเมลหรือรหัสผ่านไม่ถูกต้อง"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    // 🚨 จัดการข้อผิดพลาดและทำความสะอาด จัดการ error ที่อาจเกิดขึ้น
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
  }//------------------------------------------------------

  /// สร้าง UI ของหน้าเข้าสู่ระบบ KU Planner
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

              // 📏 แถบสีเขียวอ่อน KU
              Container(
                width: 230, // กว้าง 230 pixels
                height: 30, // สูง 30 pixels
                color: const Color(0xffb2bb1f), // สีเขียวอ่อน KU
              ),

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
              const SizedBox(height: 16), // ระยะห่าง 16 pixels
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
              // 🔐 ปุ่มเข้าสู่ระบบ
              ElevatedButton(
                onPressed: _isLoading ? null : _login, // ถ้ากำลังโหลด ห้ามกด
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
                            "กำลังเข้าสู่ระบบ...",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ],
                      )
                    : // แสดงข้อความปกติ
                      const Text(
                        "SIGN IN",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 24), // ระยะห่าง 24 pixels
              // 🔗 ปุ่มสมัครสมาชิก
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup'); // ไปหน้าสมัครสมาชิก
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    253,
                    253,
                    253,
                  ), // สีขาวอ่อน
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // มุมโค้งมน 50
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 150, // ระยะห่างซ้าย-ขวา 150 pixels
                    vertical: 14, // ระยะห่างบน-ล่าง 14 pixels
                  ),
                ),
                child: const Text(
                  "SIGN UP",
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

