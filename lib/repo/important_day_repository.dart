import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/important_day.dart';

class ImportantDayRepository {
  List<ImportantDay> importantDays = [];

  Future<void> loadImportantDays() async {
    final jsonString = await rootBundle.loadString(
      'assets/important_days.json',
    );
    final List<dynamic> data = json.decode(jsonString);
    importantDays = data.map((e) => ImportantDay.fromJson(e)).toList();
  }

  /// ✅ ดึงวันสำคัญของวันนั้น
  List<ImportantDay> getByDate(DateTime date) {
    final formatted = date.toIso8601String().split('T').first;
    return importantDays.where((e) => e.date == formatted).toList();
  }
}
