// Import Flutter framework สำหรับ debugPrint
import 'package:flutter/foundation.dart';

// Import สำหรับเก็บข้อมูลการตั้งค่า
import 'package:shared_preferences/shared_preferences.dart';

// Import models และ repositories
import '../models/user.dart';
import '../repo/user_repository.dart';

/// 🔐 Authentication Service สำหรับจัดการการเข้าสู่ระบบ
/// 
/// จัดการการ login, logout, และ session ของผู้ใช้
/// ใช้ SharedPreferences เก็บข้อมูลการเข้าสู่ระบบ
class AuthService {
  // คีย์สำหรับเก็บข้อมูลใน SharedPreferences
  static const String _isLoggedInKey = 'is_logged_in';    // สถานะการเข้าสู่ระบบ
  static const String _userIdKey = 'user_id';             // ID ของผู้ใช้
  static const String _userEmailKey = 'user_email';       // อีเมลของผู้ใช้
  static const String _userNameKey = 'user_name';         // ชื่อผู้ใช้
  static const String _loginTimeKey = 'login_time';       // เวลาที่เข้าสู่ระบบ

  // Repository สำหรับจัดการข้อมูลผู้ใช้
  final UserRepository _userRepo = UserRepository();

  /// 🔍 ตรวจสอบว่าผู้ใช้เข้าสู่ระบบอยู่หรือไม่
  /// 
  /// อ่านข้อมูลจาก SharedPreferences
  /// ส่งกลับ true ถ้าผู้ใช้เข้าสู่ระบบอยู่
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// 💾 เก็บข้อมูล session หลังเข้าสู่ระบบสำเร็จ
  /// 
  /// เก็บข้อมูลผู้ใช้ลงใน SharedPreferences
  /// เพื่อใช้ในการตรวจสอบ session ในครั้งต่อไป
  Future<void> saveLoginSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // เก็บข้อมูลการเข้าสู่ระบบ
    await prefs.setBool(_isLoggedInKey, true);                    // สถานะเข้าสู่ระบบ
    await prefs.setInt(_userIdKey, user.id ?? 0);                 // ID ผู้ใช้
    await prefs.setString(_userEmailKey, user.email);             // อีเมล
    await prefs.setString(_userNameKey, user.username);           // ชื่อผู้ใช้
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String()); // เวลาที่เข้าสู่ระบบ
  }

  /// ✅ ดึงข้อมูลผู้ใช้ที่ login อยู่
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return null;

    final userId = prefs.getInt(_userIdKey);
    final userEmail = prefs.getString(_userEmailKey);
    final userName = prefs.getString(_userNameKey);
    final loginTimeStr = prefs.getString(_loginTimeKey);

    if (userId == null || userEmail == null || userName == null) {
      return null;
    }

    return User(
      id: userId,
      email: userEmail,
      username: userName,
      password: '', // ไม่เก็บ password ใน session
      createdAt: loginTimeStr != null
          ? DateTime.parse(loginTimeStr)
          : DateTime.now(),
    );
  }

  /// ✅ Login ด้วย email และ password
  Future<bool> login(String email, String password) async {
    try {
      final success = await _userRepo.validateUser(email, password);

      if (success) {
        // ดึงข้อมูลผู้ใช้ที่ login สำเร็จ
        final user = await _userRepo.getUserByEmail(email);
        if (user != null) {
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

  /// ✅ Logout และลบ session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_loginTimeKey);
  }

  /// ✅ ตรวจสอบ session ว่ายัง valid หรือไม่
  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return false;

    // ตรวจสอบว่า session หมดอายุหรือไม่ (เช่น 30 วัน)
    final loginTimeStr = prefs.getString(_loginTimeKey);
    if (loginTimeStr != null) {
      final loginTime = DateTime.parse(loginTimeStr);
      final now = DateTime.now();
      final difference = now.difference(loginTime).inDays;

      // Session หมดอายุหลังจาก 30 วัน
      if (difference > 30) {
        await logout();
        return false;
      }
    }

    return true;
  }

  /// ✅ ตรวจสอบว่า email ถูกใช้แล้วหรือไม่
  Future<bool> isEmailExists(String email) async {
    try {
      final user = await _userRepo.getUserByEmail(email);
      return user != null;
    } catch (e) {
      debugPrint('❌ Check email error: $e');
      return false;
    }
  }

  /// ✅ Register ผู้ใช้ใหม่
  Future<bool> register(String name, String email, String password) async {
    try {
      // ตรวจสอบว่า email ถูกใช้แล้วหรือไม่
      final emailExists = await isEmailExists(email);
      if (emailExists) {
        return false; // Email ถูกใช้แล้ว
      }

      // สร้าง user ใหม่
      final user = User(email: email, username: name, password: password);

      // บันทึกลง database
      await _userRepo.addUser(user);
      return true;
    } catch (e) {
      debugPrint('❌ Register error: $e');
      return false;
    }
  }
}
