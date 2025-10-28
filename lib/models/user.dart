import 'dart:convert';

class User {
  final String name;
  final String email;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.password,
  });

  // Konversi ke JSON (untuk disimpan)
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };

  // Factory untuk membuat User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  // Encode ke String (untuk SharedPreferences)
  String encode() => jsonEncode(toJson());

  // Decode dari String
  static User decode(String userString) {
    return User.fromJson(jsonDecode(userString));
  }

  @override
  String toString() {
    return "User(name: $name, email: $email)";
  }
}
