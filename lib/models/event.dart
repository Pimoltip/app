class Event {
  final int? id;
  final DateTime date;
  final String title;
  final String description;
  final DateTime createdAt;

  Event({
    this.id,
    required this.date,
    required this.title,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ✅ For SQLite database
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  factory Event.fromMap(Map<String, dynamic> map) => Event(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    date: DateTime.parse(map['date']),
    createdAt: DateTime.parse(map['created_at']),
  );

  // ✅ For JSON (backward compatibility)
  Map<String, dynamic> toJson() => {
    "date": date.toIso8601String(),
    "title": title,
    "description": description,
  };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    date: DateTime.parse(json["date"]),
    title: json["title"],
    description: json["description"],
  );
}
