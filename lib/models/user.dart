import 'dart:convert';

class User {
  final String? id; // id bisa null saat register
  final String name;
  final String email;
  final String? password; // Opsional
  final String role;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.role = 'user',
  });

  // Konversi ke JSON (untuk disimpan ke SharedPreferences)
  Map<String, dynamic> toJson() => {
        // Selalu simpan sebagai '_id' agar konsisten
        '_id': id, 
        'nama': name,
        'email': email,
        'password': password,
        'role': role,
      };

  // Factory untuk membuat User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // --- INI PERBAIKANNYA ---
      // Cek 'id' (dari API login) ATAU '_id' (dari API getUsers/SharedPreferences)
      id: json['id'] as String? ?? json['_id'] as String?, 
      // -------------------------

      name: json['nama'] as String? ?? 'Tanpa Nama',
      email: json['email'] as String? ?? 'Tanpa Email',
      password: json['password'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }

  // Encode ke String (untuk SharedPreferences)
  String encode() => jsonEncode(toJson());

  // Decode dari String (dari SharedPreferences)
  static User decode(String userString) {
    return User.fromJson(jsonDecode(userString));
  }

  @override
  String toString() {
    return "User(id: $id, name: $name, email: $email, role: $role)";
  }
}