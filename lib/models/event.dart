class Event {
  final DateTime date;
  final String title;
  final String description;

  Event({
    required this.date,
    required this.title,
    required this.description,
  });

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
