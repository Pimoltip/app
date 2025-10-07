class User {
  final String email;
  final String password;
  final String username;   // หรืออาจชื่อว่า fullName

  User({
    required this.email,
    required this.password,
    required this.username,
  });

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

