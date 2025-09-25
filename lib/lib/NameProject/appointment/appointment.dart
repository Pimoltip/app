// appointment.dart
class Appointment {
  final String code;
  final String title;
  final String location;
  final String section;
  final DateTime startTime;
  final DateTime endTime;

  Appointment({
    required this.code,
    required this.title,
    required this.location,
    required this.section,
    required this.startTime,
    required this.endTime,
  });

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }
}
