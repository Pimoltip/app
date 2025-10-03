import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart'; // 👈 ใช้สำหรับโหลดไฟล์จาก assets
import 'package:path_provider/path_provider.dart';
import '../models/event.dart';

class EventRepository {
  Future<File> _getEventFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/events.json");

    if (!await file.exists()) {
      // ถ้าไฟล์ยังไม่มี → copy จาก assets (แก้ path ให้ตรงกับ pubspec.yaml)
      final defaultData = await rootBundle.loadString("assets/events.json");
      await file.writeAsString(defaultData);
    }

    return file;
  }

  Future<List<Event>> loadEvents() async {
    final file = await _getEventFile();
    final content = await file.readAsString();
    final List data = jsonDecode(content);
    return data.map((e) => Event.fromJson(e)).toList();
  }

  Future<void> addEvent(Event event) async {
    final events = await loadEvents();
    events.add(event);
    final file = await _getEventFile();
    await file.writeAsString(
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<Event>> getEventsByDay(DateTime day) async {
    final events = await loadEvents();
    return events.where((e) =>
        e.date.year == day.year &&
        e.date.month == day.month &&
        e.date.day == day.day).toList();
  }
}
