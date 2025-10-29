import 'package:dio/dio.dart';

class ApiService {
  // Gunakan localhost karena Flutter Web dan Node.js jalan di komputer yang sama
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://localhost:3000/api"));

  // 🔹 Ambil semua user
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get("/users");
      return response.data;
    } catch (e) {
      print("Error getUsers: $e");
      return [];
    }
  }

  // 🔹 Tambah user baru
  Future<Map<String, dynamic>?> addUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/users", data: data);
      return response.data;
    } catch (e) {
      print("Error addUser: $e");
      return null;
    }
  }
}
