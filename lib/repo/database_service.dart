// Import libraries ที่จำเป็นสำหรับจัดการฐานข้อมูล
import 'dart:async'; // สำหรับ Future และ async/await
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // SQLite สำหรับ Desktop (Windows/Linux/macOS)
import 'package:path_provider/path_provider.dart'; // หา path ของ Documents directory
import 'package:path/path.dart'; // จัดการ path ของไฟล์
import 'dart:io'; // สำหรับ Platform detection

/// 🗄️ Database Service สำหรับจัดการ SQLite
///
/// Singleton class ที่จัดการฐานข้อมูล SQLite สำหรับแอป
/// - รองรับ Desktop (Windows/Linux/macOS) และ Mobile
/// - จัดการการสร้างตารางและอัปเกรด schema
/// - ให้ access ผ่าน singleton pattern
class DatabaseService {
  static Database? _database; // Database instance (singleton)
  static const String _databaseName = 'plannerapp.db'; // ชื่อไฟล์ฐานข้อมูล
  static const int _databaseVersion = 3; // เวอร์ชันของฐานข้อมูล

  // ชื่อตารางต่างๆ ในฐานข้อมูล
  static const String eventsTable = 'events'; // ตารางกิจกรรม
  static const String usersTable = 'users'; // ตารางผู้ใช้
  static const String projectsTable = 'projects'; // ตารางโปรเจกต์

  /// ดึง database instance (Singleton Pattern)
  ///
  /// ตรวจสอบว่ามี database instance หรือไม่
  /// ถ้าไม่มี จะสร้างใหม่ และส่งกลับ instance เดียว
  Future<Database> get database async {
    if (_database != null) return _database!; // ถ้ามีแล้ว ส่งกลับ
    _database = await _initDatabase(); // ถ้าไม่มี สร้างใหม่
    return _database!;
  }

  /// เริ่มต้นฐานข้อมูล
  ///
  /// - ตรวจสอบ platform และใช้ FFI สำหรับ Desktop
  /// - หา path ของ Documents directory
  /// - เปิดฐานข้อมูลและสร้างตาราง
  Future<Database> _initDatabase() async {
    // ✅ เริ่มต้น FFI สำหรับ Desktop (Windows/Linux/macOS)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit(); // เริ่มต้น FFI
      databaseFactory = databaseFactoryFfi; // ใช้ FFI factory แทน default
    }

    // หาตำแหน่ง Documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();

    // รวม path ของ Documents directory กับชื่อไฟล์ฐานข้อมูล
    final path = join(documentsDirectory.path, _databaseName);

    // เปิดฐานข้อมูล
    return await openDatabase(
      path, // path ของไฟล์ฐานข้อมูล
      version: _databaseVersion, // เวอร์ชันของฐานข้อมูล
      onCreate: _onCreate, // ฟังก์ชันที่เรียกเมื่อสร้างฐานข้อมูลครั้งแรก
      onUpgrade: _onUpgrade, // ฟังก์ชันที่เรียกเมื่ออัปเกรดเวอร์ชัน
    );
  }

  /// สร้างตารางทั้งหมดในฐานข้อมูล
  ///
  /// ฟังก์ชันนี้จะถูกเรียกเมื่อสร้างฐานข้อมูลครั้งแรก
  /// จะสร้างตารางทั้งหมดที่แอปต้องการ
  Future<void> _onCreate(Database db, int version) async {
    // สร้างตาราง events (กิจกรรม)
    await db.execute('''
      CREATE TABLE $eventsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Primary key ที่เพิ่มขึ้นอัตโนมัติ
        title TEXT NOT NULL,                   -- หัวข้อกิจกรรม (ไม่เป็น null)
        description TEXT,                      -- คำอธิบาย (เป็น null ได้)
        date TEXT NOT NULL,                    -- วันที่ (ไม่เป็น null)
        user_id INTEGER NOT NULL,              -- ID ของผู้ใช้เจ้าของกิจกรรม (ไม่เป็น null)
        created_at TEXT NOT NULL,              -- วันที่สร้าง (ไม่เป็น null)
        FOREIGN KEY (user_id) REFERENCES $usersTable(id) -- Foreign key เชื่อมกับตาราง users
      )
    ''');

    // สร้างตาราง users (ผู้ใช้)
    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Primary key ที่เพิ่มขึ้นอัตโนมัติ
        email TEXT UNIQUE NOT NULL,            -- อีเมล (ไม่ซ้ำกัน, ไม่เป็น null)
        password TEXT NOT NULL,                -- รหัสผ่าน (ไม่เป็น null)
        name TEXT,                             -- ชื่อ (เป็น null ได้)
        created_at TEXT NOT NULL               -- วันที่สร้าง (ไม่เป็น null)
      )
    ''');

    // สร้างตาราง projects (โปรเจกต์)
    await db.execute('''
      CREATE TABLE $projectsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Primary key ที่เพิ่มขึ้นอัตโนมัติ
        name TEXT NOT NULL,                    -- ชื่อโปรเจกต์ (ไม่เป็น null)
        tag TEXT NOT NULL,                     -- ประเภทโปรเจกต์ (ไม่เป็น null)
        progress INTEGER NOT NULL,             -- ความคืบหน้า 0-100 (ไม่เป็น null)
        members TEXT NOT NULL,                 -- รายชื่อสมาชิก (เก็บเป็น String)
        deadline TEXT,                         -- กำหนดส่ง (เป็น null ได้)
        user_id INTEGER NOT NULL,              -- ID ของผู้ใช้เจ้าของโปรเจกต์ (ไม่เป็น null)
        created_at TEXT NOT NULL,              -- วันที่สร้าง (ไม่เป็น null)
        FOREIGN KEY (user_id) REFERENCES $usersTable(id) -- Foreign key เชื่อมกับตาราง users
      )
    ''');
  }

  /// อัปเกรดฐานข้อมูล
  ///
  /// ฟังก์ชันนี้จะถูกเรียกเมื่อเวอร์ชันฐานข้อมูลเปลี่ยน
  /// จะจัดการการเปลี่ยนแปลง schema ของตาราง
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // จัดการการอัปเกรดฐานข้อมูลที่นี่

    // ถ้าเวอร์ชันเก่าน้อยกว่า 2
    if (oldVersion < 2) {
      // ✅ อัปเดต schema ของตาราง projects
      await db.execute('DROP TABLE IF EXISTS $projectsTable'); // ลบตารางเก่า
      await db.execute(
        '''                                      // สร้างตารางใหม่
        CREATE TABLE $projectsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          tag TEXT NOT NULL,
          progress INTEGER NOT NULL,
          members TEXT NOT NULL,
          deadline TEXT,
          created_at TEXT NOT NULL
        )
      ''',
      );
    }

    // ถ้าเวอร์ชันเก่าน้อยกว่า 3
    if (oldVersion < 3) {
      // ✅ เพิ่ม user_id column ให้กับตาราง events
      await db.execute(
        'ALTER TABLE $eventsTable ADD COLUMN user_id INTEGER NOT NULL DEFAULT 1',
      );

      // ✅ เพิ่ม user_id column ให้กับตาราง projects
      await db.execute(
        'ALTER TABLE $projectsTable ADD COLUMN user_id INTEGER NOT NULL DEFAULT 1',
      );

      // ✅ เพิ่ม Foreign Key constraints (ถ้า SQLite รองรับ)
      // Note: SQLite ไม่รองรับการเพิ่ม Foreign Key ใน ALTER TABLE
      // แต่เราสามารถสร้างตารางใหม่และย้ายข้อมูลได้
    }
  }

  /// ปิดฐานข้อมูล
  ///
  /// ใช้เมื่อต้องการปิดการเชื่อมต่อฐานข้อมูล
  /// มักใช้เมื่อปิดแอป
  Future<void> close() async {
    final db = await database; // ดึง database instance
    await db.close(); // ปิดการเชื่อมต่อ
  }

  /// ลบข้อมูลทั้งหมด (สำหรับการทดสอบ)
  ///
  /// ใช้เมื่อต้องการลบข้อมูลทั้งหมดในฐานข้อมูล
  /// ใช้สำหรับการทดสอบหรือ reset ข้อมูล
  Future<void> clearAllData() async {
    final db = await database; // ดึง database instance

    // ลบข้อมูลจากทุกตาราง
    await db.delete(eventsTable); // ลบข้อมูลในตาราง events
    await db.delete(usersTable); // ลบข้อมูลในตาราง users
    await db.delete(projectsTable); // ลบข้อมูลในตาราง projects
  }
}
