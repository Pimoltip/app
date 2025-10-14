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
  ///
  /// ขั้นตอนการทำงาน:
  /// 1. ดึงข้อมูลจากช่องกรอกและลบช่องว่าง
  /// 2. ตรวจสอบความครบถ้วนของข้อมูล
  /// 3. ตรวจสอบรหัสผ่านตรงกัน
  /// 4. ตรวจสอบความยาวรหัสผ่าน
  /// 5. ตรวจสอบความซับซ้อนของรหัสผ่าน
  /// 6. เรียก AuthService เพื่อสร้างบัญชี
  /// 7. แสดงผลลัพธ์และนำทางไปหน้าถัดไป
  void _signUp() async {
    // 📥 ดึงข้อมูลจากช่องกรอกและลบช่องว่างหน้า-หลัง
    // trim() จะลบช่องว่างที่อยู่หน้าและหลังข้อความออก
    final name = nameCtrl.text.trim(); // ชื่อผู้ใช้
    final email = emailCtrl.text.trim(); // อีเมล
    final pass = passCtrl.text.trim(); // รหัสผ่าน
    final confirm = confirmCtrl.text.trim(); // ยืนยันรหัสผ่าน

    // ✅ ขั้นตอนที่ 1: ตรวจสอบความครบถ้วนของข้อมูล
    // ตรวจสอบว่าผู้ใช้กรอกข้อมูลครบทุกช่องหรือไม่
    // isEmpty จะคืนค่า true ถ้าข้อความเป็นค่าว่างหรือมีแต่ช่องว่าง
    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      // แสดงข้อความแจ้งเตือนสีแดงที่ด้านล่างของหน้าจอ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรอกข้อมูลให้ครบทุกช่อง"),
          backgroundColor: Colors.red, // สีแดงแสดงข้อผิดพลาด
        ),
      );
      return; // หยุดการทำงานทันที ไม่ดำเนินการต่อ
    }

    // ✅ ขั้นตอนที่ 2: ตรวจสอบรหัสผ่านตรงกัน
    // เปรียบเทียบรหัสผ่านที่กรอกกับรหัสผ่านที่ยืนยัน
    // ต้องตรงกันทุกตัวอักษรเพื่อป้องกันการพิมพ์ผิด
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("รหัสผ่านไม่ตรงกัน"),
          backgroundColor: Colors.red,
        ),
      );
      return; // หยุดการทำงานทันที
    }

    // ✅ ขั้นตอนที่ 3: ตรวจสอบความยาวของรหัสผ่าน
    // รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษรเพื่อความปลอดภัย
    // length จะคืนค่าจำนวนตัวอักษรในสตริง
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร"),
          backgroundColor: Colors.red,
        ),
      );
      return; // หยุดการทำงานทันที
    }

    // ✅ ขั้นตอนที่ 4: ตรวจสอบความซับซ้อนของรหัสผ่าน
    // ใช้ Regular Expression (RegExp) เพื่อตรวจสอบรูปแบบรหัสผ่าน
    //
    // อธิบาย Regex Pattern:
    // ^ = เริ่มต้นสตริง
    // (?=.*[A-Z]) = ต้องมีตัวพิมพ์ใหญ่อย่างน้อย 1 ตัว (Positive Lookahead)
    // (?=.*[!@#\$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]) = ต้องมีอักขระพิเศษอย่างน้อย 1 ตัว
    // [A-Za-z0-9!@#\$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]{6,} = อนุญาตเฉพาะตัวอักษร, ตัวเลข, และอักขระพิเศษ ความยาวอย่างน้อย 6 ตัว
    // $ = สิ้นสุดสตริง
    final RegExp passRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[!@#\$%^&*()_+\-=\[\]{};:"\\|,.<>\/?])[A-Za-z0-9!@#\$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]{6,}$',
    );

    // ตรวจสอบว่ารหัสผ่านตรงตามรูปแบบที่กำหนดหรือไม่
    if (!passRegex.hasMatch(pass)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "รหัสผ่านต้องมีตัวพิมพ์ใหญ่อย่างน้อย 1 ตัว และอักขระพิเศษอย่างน้อย 1 ตัว",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // หยุดการทำงานทันที
    }

    // 🔄 ขั้นตอนที่ 5: แสดง Loading Indicator
    // เปลี่ยนสถานะ _isLoading เป็น true เพื่อแสดงการโหลด
    // setState() จะทำให้ UI อัปเดตใหม่ (ปุ่มจะแสดง loading)
    setState(() {
      _isLoading = true;
    });

    // 🔄 ขั้นตอนที่ 6: เรียก AuthService เพื่อสร้างบัญชี
    // ใช้ try-catch เพื่อจัดการกับ error ที่อาจเกิดขึ้น
    try {
      // เรียกฟังก์ชัน register จาก AuthService
      // await จะรอให้การสมัครสมาชิกเสร็จสิ้นก่อนดำเนินการต่อ
      final success = await _authService.register(name, email, pass);

      // ✅ กรณีสมัครสมาชิกสำเร็จ
      if (success) {
        // ตรวจสอบว่า widget ยังคงอยู่ในหน้าจอหรือไม่ (mounted)
        // ป้องกันการแสดง SnackBar หลังจากที่ผู้ใช้ออกจากหน้าแล้ว
        if (mounted) {
          // แสดงข้อความสำเร็จสีเขียว
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("สมัครสมาชิกสำเร็จ! 🎉"),
              backgroundColor: Colors.green, // สีเขียวแสดงความสำเร็จ
            ),
          );
          // นำทางไปหน้าเข้าสู่ระบบ
          // pushReplacementNamed จะแทนที่หน้าปัจจุบันด้วยหน้าใหม่
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
      // ❌ กรณีสมัครสมาชิกไม่สำเร็จ (อีเมลถูกใช้แล้ว)
      else {
        if (mounted) {
          // แสดงข้อความแจ้งเตือนสีแดง
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("อีเมลนี้ถูกใช้แล้ว กรุณาใช้อีเมลอื่น"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    // 🚨 จัดการ error ที่อาจเกิดขึ้นระหว่างการสมัครสมาชิก
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e"), // แสดง error message
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // 🧹 ทำความสะอาดเสมอ (ซ่อน loading indicator)
    // finally จะทำงานเสมอ ไม่ว่าจะมี error หรือไม่
    finally {
      if (mounted) {
        // เปลี่ยนสถานะ _isLoading เป็น false เพื่อซ่อนการโหลด
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 🎨 สร้าง UI ของหน้าสมัครสมาชิก KU Planner
  ///
  /// Widget build() จะถูกเรียกเมื่อต้องการสร้าง UI
  /// ใช้ Scaffold เป็นโครงสร้างหลักของหน้า
  /// ประกอบด้วย:
  /// - โลโก้ KU และ PLANER
  /// - ช่องกรอกข้อมูล (ชื่อ, อีเมล, รหัสผ่าน, ยืนยันรหัสผ่าน)
  /// - ปุ่มสมัครสมาชิก (พร้อม loading indicator)
  /// - ปุ่มเข้าสู่ระบบ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 กำหนดสีพื้นหลังเป็นสีขาว
      backgroundColor: const Color.fromARGB(
        255, // Alpha (ความโปร่งใส) = 255 (ทึบแสง)
        255, // Red = 255
        255, // Green = 255
        255, // Blue = 255
      ), // ผลลัพธ์: สีขาวทึบแสง
      body: Center(
        // 📐 จัดให้เนื้อหาอยู่ตรงกลางหน้าจอ
        child: Padding(
          padding: const EdgeInsets.all(
            20.0,
          ), // ระยะห่างจากขอบทุกด้าน 20 pixels
          child: Column(
            mainAxisSize: MainAxisSize.min, // ใช้พื้นที่น้อยที่สุดตามเนื้อหา
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
              // 📝 ปุ่มสมัครสมาชิก - ปุ่มหลักของหน้า
              ElevatedButton(
                // ถ้ากำลังโหลด (_isLoading = true) ให้ปุ่มไม่สามารถกดได้ (null)
                // ถ้าไม่โหลด (_isLoading = false) ให้เรียกฟังก์ชัน _signUp
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xff006866,
                  ), // สีเขียวเข้ม KU (#006866)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      50,
                    ), // มุมโค้งมน 50 pixels
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 150, // ระยะห่างซ้าย-ขวา 150 pixels
                    vertical: 14, // ระยะห่างบน-ล่าง 14 pixels
                  ),
                ),
                child: _isLoading
                    ? // 🔄 แสดง loading indicator ขณะประมวลผล
                      const Row(
                        mainAxisSize: MainAxisSize.min, // ใช้พื้นที่น้อยที่สุด
                        children: [
                          SizedBox(
                            width: 16, // กว้าง 16 pixels
                            height: 16, // สูง 16 pixels
                            child: CircularProgressIndicator(
                              strokeWidth:
                                  2, // ความหนาของวงกลม loading 2 pixels
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white, // สีขาว
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ), // ระยะห่างระหว่าง loading กับข้อความ 8 pixels
                          Text(
                            "กำลังสมัครสมาชิก...",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ],
                      )
                    : // 📝 แสดงข้อความปกติเมื่อไม่โหลด
                      const Text(
                        "SIGN UP",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 24), // ระยะห่าง 24 pixels
              // 🔗 ปุ่มเข้าสู่ระบบ - ปุ่มรองสำหรับผู้ที่มีบัญชีแล้ว
              ElevatedButton(
                onPressed: () {
                  // นำทางไปหน้าเข้าสู่ระบบ
                  // pushReplacementNamed จะแทนที่หน้าปัจจุบันด้วยหน้าใหม่
                  Navigator.pushReplacementNamed(
                    context,
                    '/login', // ชื่อ route ของหน้าเข้าสู่ระบบ
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255, // Alpha = 255 (ทึบแสง)
                    255, // Red = 255
                    255, // Green = 255
                    255, // Blue = 255
                  ), // สีขาว (พื้นหลังของปุ่ม)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      50,
                    ), // มุมโค้งมน 50 pixels
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
                    color: Color(0xff006866), // สีเขียวเข้ม KU (#006866)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
