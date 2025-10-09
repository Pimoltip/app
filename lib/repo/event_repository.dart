import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/event.dart';

class EventRepository {
  final DatabaseService _dbService = DatabaseService();

  /// ✅ Load all events from SQLite
  Future<List<Event>> loadEvents() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.eventsTable,
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  /// ✅ Save new event to SQLite
  Future<void> saveEvent(Event newEvent) async {
    final db = await _dbService.database;
    await db.insert(
      DatabaseService.eventsTable,
      newEvent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ✅ Update existing event
  Future<void> updateEvent(Event event) async {
    final db = await _dbService.database;
    await db.update(
      DatabaseService.eventsTable,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// ✅ Delete event
  Future<void> deleteEvent(int id) async {
    final db = await _dbService.database;
    await db.delete(
      DatabaseService.eventsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Backward-compatible alias for callers expecting addEvent
  Future<void> addEvent(Event newEvent) {
    return saveEvent(newEvent);
  }
}
