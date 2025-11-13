import 'dart:convert';

// --- MODEL BARU UNTUK PET ---
class Pet {
  final String? id; // Akan berisi _id dari Mongoose
  final String nama;
  final String jenis; // Kucing, Anjing, dll.
  final String? ras;
  final int? umur;
  final String? gender;

  Pet({
    this.id,
    required this.nama,
    required this.jenis,
    this.ras,
    this.umur,
    this.gender,
  });

  // Konversi dari JSON (data dari MongoDB)
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['_id'] as String?,
      nama: json['nama'] as String? ?? 'Tanpa Nama',
      jenis: json['jenis'] as String? ?? 'N/A',
      ras: json['ras'] as String?,
      umur: (json['umur'] as num?)?.toInt(),
      gender: json['gender'] as String?,
    );
  }

  // Konversi ke JSON (untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'jenis': jenis,
      'ras': ras,
      'umur': umur,
      'gender': gender,
      // Kita tidak perlu mengirim 'id' saat membuat/update
    };
  }
}
// --- -------------------- ---


class User {
  final String? id;
  final String name;
  final String email;
  final String? password;
  final String role;
  final String? telepon;    // <-- Field untuk nomor telepon
  final List<Pet> pets;   // <-- Menggunakan class Pet

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.role = 'user',
    this.telepon,         // <-- Tambahkan di constructor
    this.pets = const [], // Defaultnya list kosong
  });

  // Konversi ke JSON (untuk disimpan ke SharedPreferences)
  Map<String, dynamic> toJson() => {
        '_id': id, 
        'nama': name,
        'email': email,
        'password': password,
        'role': role,
        'telepon': telepon, // <-- Simpan telepon
        // 'pets' tidak disimpan di SharedPreferences
        // karena kita akan mengambilnya via API
      };

  // Factory untuk membuat User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    
    // Logika parsing Pets
    List<Pet> parsedPets = [];
    if (json['pets'] != null && json['pets'] is List) {
      parsedPets = (json['pets'] as List)
          .map((petJson) => Pet.fromJson(petJson as Map<String, dynamic>))
          .toList();
    }

    return User(
      id: json['id'] as String? ?? json['_id'] as String?, 
      name: json['nama'] as String? ?? 'Tanpa Nama',
      email: json['email'] as String? ?? 'Tanpa Email',
      password: json['password'] as String?,
      role: json['role'] as String? ?? 'user',
      telepon: json['telepon'] as String?, // <-- Parsing telepon
      pets: parsedPets, // <-- Masukkan pets yang sudah diparsing
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
    return "User(id: $id, name: $name, email: $email, role: $role, pets: ${pets.length})";
  }
}