class ImportantDay {
  final String title;
  final String date;
  final String description;
  final String color;

  ImportantDay({
    required this.title,
    required this.date,
    required this.description,
    required this.color,
  });

  factory ImportantDay.fromJson(Map<String, dynamic> json) {
    return ImportantDay(
      title: json['title'] ?? 'No Title',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '#FF0000', // ✅ ใส่ค่าเริ่มต้นถ้าไม่มีใน JSON
    );
  }
}
