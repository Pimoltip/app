import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/event.dart';

class EventRepository {
  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/events.json';
  }

  Future<List<Event>> loadEvents() async {
    final path = await _getFilePath();
    final file = File(path);
    if (!await file.exists()) return [];

    final data = json.decode(await file.readAsString()) as List;
    return data.map((e) => Event.fromJson(e)).toList();
  }

  Future<void> saveEvent(Event newEvent) async {
    final path = await _getFilePath();
    final file = File(path);
    List<Event> events = [];

    if (await file.exists()) {
      final data = json.decode(await file.readAsString()) as List;
      events = data.map((e) => Event.fromJson(e)).toList();
    }

    events.add(newEvent);
    await file.writeAsString(
      json.encode(events.map((e) => e.toJson()).toList()),
    );
  }

  // Backward-compatible alias for callers expecting addEvent
  Future<void> addEvent(Event newEvent) {
    return saveEvent(newEvent);
  }
}
