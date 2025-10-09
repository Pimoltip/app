import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

/// ✅ Database Service สำหรับจัดการ SQLite บน Windows
class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'plannerapp.db';
  static const int _databaseVersion = 2;

  // Table names
  static const String eventsTable = 'events';
  static const String usersTable = 'users';
  static const String projectsTable = 'projects';

  /// ✅ Get database instance (Singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// ✅ Initialize database
  Future<Database> _initDatabase() async {
    // ✅ Initialize FFI for Windows desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// ✅ Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Events table
    await db.execute('''
      CREATE TABLE $eventsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Projects table
    await db.execute('''
      CREATE TABLE $projectsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        tag TEXT NOT NULL,
        progress INTEGER NOT NULL,
        members TEXT NOT NULL,
        deadline TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// ✅ Database upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // ✅ Update projects table schema
      await db.execute('DROP TABLE IF EXISTS $projectsTable');
      await db.execute('''
        CREATE TABLE $projectsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          tag TEXT NOT NULL,
          progress INTEGER NOT NULL,
          members TEXT NOT NULL,
          deadline TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  /// ✅ Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// ✅ Clear all data (for testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(eventsTable);
    await db.delete(usersTable);
    await db.delete(projectsTable);
  }
}
