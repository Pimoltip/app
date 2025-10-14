// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import 'package:flutter/foundation.dart'; // Flutter framework สำหรับ debugPrint และ foundation classes
import 'package:shared_preferences/shared_preferences.dart'; // สำหรับเก็บข้อมูลการตั้งค่าและ session
import '../models/user.dart'; // Model ข้อมูลผู้ใช้
import '../repo/user_repository.dart'; // Repository สำหรับจัดการข้อมูลผู้ใช้
// เมื่อlogin : AuthService จะเรียก UserRepository ตรวจสอบข้อมูล ถ้าผ่าน จะใช้ SharedPreferences บันทึกรหัสผู้ใช้และ Token (หลักฐานการล็อกอิน)
// เมื่อเปิดแอป : AuthService จะตรวจสอบ SharedPreferences ทันทีว่ามีหลักฐานการล็อกอินอยู่หรือไม่ ถ้ามีและยังไม่หมดอายุ (ภายใน 30 วัน) ก็จะนำทางผู้ใช้เข้าสู่หน้าหลักทันที
class AuthService {
  // ========================================
  // 🔑 SharedPreferences Keys - คีย์สำหรับเก็บข้อมูล
  // ========================================
  static const String _isLoggedInKey = 'is_logged_in'; /// คีย์สำหรับเก็บสถานะการเข้าสู่ระบบ ใช้ตรวจสอบอย่างรวดเร็วว่าผู้ใช้ได้ล็อกอินอยู่หรือไม่  (ใช้สำหรับ Auto-login)
  static const String _userIdKey = 'user_id'; /// คีย์สำหรับเก็บ ID ของผู้ใช้ ใช้ระบุว่าผู้ใช้คนใดกำลังล็อกอินอยู่ เพื่อดึงข้อมูลเฉพาะบุคคลจากฐานข้อมูล
  static const String _userEmailKey = 'user_email';/// คีย์สำหรับเก็บอีเมลของผู้ใช้  
  static const String _userNameKey = 'user_name'; /// คีย์สำหรับเก็บชื่อผู้ใช้ ใช้แสดงชื่อบน Dashboard 
  static const String _loginTimeKey = 'login_time'; /// คีย์สำหรับเก็บเวลาที่เข้าสู่ระบบ สำคัญมาก! ใช้ในการตรวจสอบว่า Session หมดอายุ (Expire) หรือยัง (ตามที่ระบุว่ามีระบบตรวจสอบ 30 วัน)
  
  // ========================================
  // 🔧 Repository & Service Instances - อินสแตนซ์ของ Service
  // ========================================

  final UserRepository _userRepo = UserRepository(); /// Repository สำหรับจัดการข้อมูลผู้ใช้ในฐานข้อมูล SQLite

  // ========================================
  // 📊 Session Management Methods - ฟังก์ชันจัดการ Session
  // ========================================

  //ฟังก์ชัน isLoggedIn() นี้จะถูกเรียกใช้ในหน้าจอเริ่มต้น (Login Page) เพื่อตรวจสอบอย่างรวดเร็วว่าควรแสดงหน้า Login ให้ผู้ใช้กรอกข้อมูล
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  } 

  //ฟังก์ชัน saveLoginSession()ทำหน้าที่สร้าง "บัตรผ่าน" ให้ผู้ใช้ เพื่อให้แอปจำสถานะการล็อกอินไ ทำหน้าที่ บันทึกข้อมูลสำคัญ SharedPreferences เพื่อใช้ในการทำ Auto-login และจัดการ Session 
  Future<void> saveLoginSession(User user) async {
    final prefs = await SharedPreferences.getInstance(); 
   
    // สั่ง await prefs.set... เพื่อบันทึกข้อมูลทีละอย่าง โดยใช้ คีย์ (Key) ที่ถูกกำหนดไว้
    await prefs.setBool(_isLoggedInKey, true);                    // สถานะเข้าสู่ระบบ เป็น true 
    await prefs.setInt(_userIdKey, user.id ?? 0);                 // ID ผู้ใช้ 
    await prefs.setString(_userEmailKey, user.email);             // อีเมล 
    await prefs.setString(_userNameKey, user.username);           // ชื่อผู้ใช้
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String()); // เวลาที่เข้าสู่ระบบ - ใช้ตรวจสอบ วันหมดอายุ (30 วัน) ในฟังก์ชัน isSessionValid()
  }

  //ฟังก์ชัน getCurrentUser() ดึงข้อมูลโปรไฟล์ ของผู้ใช้ที่กำลังล็อกอินอยู่จากmem (SharedPreferences) เพื่อให้แอปนำไปแสดงผลหรือใช้งานต่อได้ทันทีโดยไม่ต้องไปดึงจากฐานข้อมูลหลัก
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false; 
    //การ อ่านข้อมูลจาก "บัตรประจำตัว Session" ที่ถูกเก็บไว้

    if (!isLoggedIn) return null; // หากไม่ได้เข้าสู่ระบบ ให้คืนค่า null

    // อ่านข้อมูลผู้ใช้จาก SharedPreferences ดึงข้อมูลผู้ใช้
    final userId = prefs.getInt(_userIdKey); //ใช้ prefs.get...ดึงข้อมูลของผู้ใช้ทีละส่วนโดยใช้ Key ที่บันทึกไว้ในฟังก์ชัน saveLoginSession()
    final userEmail = prefs.getString(_userEmailKey);
    final userName = prefs.getString(_userNameKey);
    final loginTimeStr = prefs.getString(_loginTimeKey);

    // ตรวจสอบความครบถ้วนของข้อมูล
    if (userId == null || userEmail == null || userName == null) {
      return null;
    }//ถ้าดึงข้อมูลหลักๆ มาไม่ได้ แสดงว่าข้อมูล Session อาจเสียหายหรือไม่สมบูรณ์  หากข้อมูลไม่ครบ ฟังก์ชันจะส่งค่า null กลับไป

    // สร้าง User object จากข้อมูลที่เก็บไว้
    return User(
      id: userId,
      email: userEmail,
      username: userName,
      password: '', // ไม่เก็บ password ใน session เพื่อความปลอดภัย
      createdAt: loginTimeStr != null
          ? DateTime.parse(loginTimeStr) // ใช้เวลาที่เข้าสู่ระบบ
          : DateTime.now(), // fallback หากไม่มีข้อมูล
    );
  }
  
  //ฟังก์ชัน login() ฟังก์ชันนี้จะทำงานเป็นขั้นตอนเพื่อยืนยันตัวตนผู้ใช้และบันทึกสถานะการล็อกอินลงในเครื่อง
  Future<bool> login(String email, String password) async {
    try {
      // ตรวจสอบข้อมูลการเข้าสู่ระบบ
      final success = await _userRepo.validateUser(email, password);

      if (success) {
        // ดึงข้อมูลผู้ใช้ที่เข้าสู่ระบบสำเร็จ
        final user = await _userRepo.getUserByEmail(email);
        if (user != null) {
          // เก็บข้อมูล session
          await saveLoginSession(user);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return false;
    }
  }

  //ฟังก์ชัน logout() นี้ทำหน้าที่เป็น "กุญแจรีเซ็ต" ลบข้อมูลทั้งหมดที่แอปใช้ในการจำผู้ใช้
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ลบข้อมูล session ทั้งหมด
    await prefs.remove(_isLoggedInKey);    // สถานะการเข้าสู่ระบบ
    await prefs.remove(_userIdKey);        // ID ของผู้ใช้
    await prefs.remove(_userEmailKey);     // อีเมลของผู้ใช้
    await prefs.remove(_userNameKey);      // ชื่อผู้ใช้
    await prefs.remove(_loginTimeKey);     // เวลาที่เข้าสู่ระบบ
  }

  //ฟังก์ชัน isSessionValid() นี้ทำหน้าที่เป็น "พนักงานตรวจอายุบัตรผ่าน" ยังไม่หมดอายุ 30 วัน
  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    // หากไม่ได้เข้าสู่ระบบ ให้คืนค่า false
    if (!isLoggedIn) return false;

    // ตรวจสอบการหมดอายุของ session
    final loginTimeStr = prefs.getString(_loginTimeKey);
    if (loginTimeStr != null) {
      final loginTime = DateTime.parse(loginTimeStr);
      final now = DateTime.now();
      final difference = now.difference(loginTime).inDays;

      // Session หมดอายุหลังจาก 30 วัน
      if (difference > 30) {
        await logout(); // ลบ session ที่หมดอายุ
        return false;
      }
    }

    return true;
  }

  // ========================================
  // 👤 User Registration Methods - ฟังก์ชันการลงทะเบียน
  // ========================================
  
  // ฟังก์ชัน isEmailExists() นี้ทำหน้าที่เป็น "พนักงานต้อนรับ" ที่ตรวจสอบว่าอีเมลที่ผู้ใช้กำลังจะใช้ในการลงทะเบียนนั้น มีคนอื่นใช้ไปแล้วหรือยัง โดยติดต่อกับฐานข้อมูล
  Future<bool> isEmailExists(String email) async {
    try {
      final user = await _userRepo.getUserByEmail(email);
      return user != null;
    } catch (e) {
      debugPrint('❌ Check email error: $e');
      return false;
    }
  }

  ///ฟังก์ชัน register() กระบวนการสร้างบัญชีผู้ใช้ใหม่ทั้งหมด ทำหน้าที่เป็น "เจ้าหน้าที่ลงทะเบียน" ที่รับข้อมูลพื้นฐาน (ชื่อ, อีเมล, รหัสผ่าน) และบันทึกข้อมูลนั้นลงในฐานข้อมูลอย่างมีขั้นตอน
  Future<bool> register(String name, String email, String password) async {
    try {
      // ตรวจสอบว่าอีเมลถูกใช้แล้วหรือไม่
      final emailExists = await isEmailExists(email);
      if (emailExists) {
        return false; // อีเมลถูกใช้แล้ว
      }

      // สร้าง User object ใหม่
      final user = User(email: email, username: name, password: password);

      // บันทึกข้อมูลผู้ใช้ลงฐานข้อมูล
      await _userRepo.addUser(user);
      return true;
    } catch (e) {
      debugPrint('❌ Register error: $e');
      return false;
    }
  }
}
