class User {
  final int? id;
  final String email;
  final String password;
  final String username; // หรืออาจชื่อว่า fullName
  final DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.username,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ✅ For SQLite database
  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'password': password,
    'name': username,
    'created_at': createdAt.toIso8601String(),
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    email: map['email'],
    password: map['password'],
    username: map['name'],
    createdAt: DateTime.parse(map['created_at']),
  );

  // ✅ For JSON (backward compatibility)
  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
    "username": username,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json["email"],
    password: json["password"],
    username: json["username"],
  );
}
