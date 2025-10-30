import 'package:dio/dio.dart'; // <-- 1. PASTIKAN KAMU IMPORT DIO

class ApiService {
  // --- 2. INI YANG HILANG ---
  // Kamu harus definisikan _dio sebagai variabel di dalam class
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://localhost:3000/api"));

  // Constructor
  ApiService();

  // --- 🔒 FUNGSI USER & AUTH ---

  // 🔹 Login User
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        return response.data['user'];
      }
      return null;
    } catch (e) {
      print("Error login: $e");
      return null;
    }
  }

  // 🔹 CREATE (Tambah user baru / Register)
  Future<Map<String, dynamic>?> addUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/users", data: data);
      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("Error addUser: $e");
      return null;
    }
  }

  // 🔹 READ (Ambil semua user)
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get("/users");
      return response.data;
    } catch (e) {
      print("Error getUsers: $e");
      return [];
    }
  }

  // 🔹 UPDATE (Perbarui user by ID)
  Future<Map<String, dynamic>?> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/users/$id", data: data);
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("Error updateUser: $e");
      return null;
    }
  }

  // 🔹 DELETE (Hapus user by ID)
  Future<bool> deleteUser(String id) async {
    try {
      final response = await _dio.delete("/users/$id");
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleteUser: $e");
      return false;
    }
  }

  // --- 📦 FUNGSI UNTUK SERVICES (Grooming, Boarding, dll) ---

  // 🔹 FUNGSI UNTUK MENGAMBIL DATA SERVICES (NANTI)
  Future<List<dynamic>> getServices() async {
    try {
      // Sekarang _dio.get() akan dikenali
      final response = await _dio.get("/services");
      return response.data;
    } catch (e) {
      print("Error getServices: $e");
      return [];
    }
  }

  // 🔹 FUNGSI UNTUK MENGIRIM DATA DUMMY (SEKARANG)
  // Fungsi ini akan kita panggil untuk upload
  Future<void> addService(Map<String, dynamic> data) async {
    try {
      // Mengirim satu service ke Node.js
      // Sekarang _dio.post() akan dikenali
      await _dio.post("/services", data: data);
      print("SUKSES upload: ${data['name']}");
    } catch (e) {
      // Jika error, mungkin karena data sudah ada
      print("GAGAL upload ${data['name']}: $e");
    }
  }
  
} // <-- 3. PASTIKAN SEMUA FUNGSI ADA DI DALAM KURUNG TUTUP INI