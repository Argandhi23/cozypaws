import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart'; // Pastikan user.dart punya field 'role' dan 'id'

class AuthService {
  final String _currentUserKey = 'currentUser';
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://localhost:3000/api"));

  // --- Helper Cerdas untuk Ekstrak Pesan Error ---
  String _handleError(Exception e) {
    String errorMessage = "Terjadi kesalahan tidak diketahui.";

    if (e is DioException) {
      // Jika ini error dari Dio (koneksi, 404, 500)
      if (e.response?.data is Map) {
        // Coba ambil 'message' dari JSON { "message": "..." }
        errorMessage = (e.response!.data as Map)['message']?.toString() 
                       ?? 'Server mengembalikan error tanpa pesan.';
      } else if (e.response?.data != null) {
        // Jika respons error bukan JSON (misal: HTML)
        errorMessage = e.response!.data.toString();
      } else {
        // Jika tidak ada respons (misal: koneksi gagal)
        errorMessage = e.message ?? 'Koneksi ke server gagal.';
      }
    } else {
      // Jika ini error Flutter (TypeError, dll)
      errorMessage = e.toString();
    }
    
    // Cetak error ke konsol debug
    debugPrint("AuthService Error: $errorMessage");
    debugPrint(e.toString());
    
    // Lempar exception yang bersih untuk ditangkap UI
    throw Exception(errorMessage);
  }

  // --- 👤 FUNGSI AUTH & USER 👤 ---

  Future<void> register(String name, String email, String password) async {
    try {
      if (name.isEmpty || name.length < 3) throw Exception('Nama minimal 3 karakter');
      if (!_isValidEmail(email)) throw Exception('Gunakan email dengan format @gmail.com');
      if (password.isEmpty || password.length < 6) throw Exception('Password minimal 6 karakter');
      
      final response = await _dio.post(
        '/users',
        data: {'nama': name, 'email': email, 'password': password},
      );
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gagal registrasi (${response.statusCode})');
      }
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
    }
  }

  Future<User?> login(String nameOrEmail, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': nameOrEmail, 'password': password},
      );
      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final prefs = await SharedPreferences.getInstance();
        final currentUser = User.fromJson(userData);
        await prefs.setString(_currentUserKey, currentUser.encode());
        return currentUser;
      } else {
        return null;
      }
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return null; // Tambahan untuk memuaskan tipe return nullable
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_currentUserKey);
    if (data == null) return null;
    return User.decode(data);
  }

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      if (newPassword.isEmpty || newPassword.length < 6) throw Exception('Password minimal 6 karakter');
      
      final response = await _dio.put(
        '/users/reset-password',
        data: {'email': email, 'newPassword': newPassword},
      );
      if (response.statusCode != 200) {
        throw Exception('Gagal reset password');
      }
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.\-]+@gmail\.com$');
    return regex.hasMatch(email);
  }

  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get("/users");
      return response.data;
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return []; // Kembalikan list kosong jika error
    }
  }

  Future<Map<String, dynamic>?> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/users/$id", data: data);
      if (response.statusCode == 200) {
        return response.data['user'];
      }
      return null;
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return null;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      final response = await _dio.delete("/users/$id");
      return (response.statusCode == 200 || response.statusCode == 204);
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return false;
    }
  }

  // --- 📦 FUNGSI UNTUK SERVICES 📦 ---

  Future<List<dynamic>> getServices() async {
    try {
      final response = await _dio.get("/services");
      return response.data;
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return [];
    }
  }

  Future<Map<String, dynamic>?> addService(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/services", data: data);
      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateService(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/services/$id", data: data);
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return null;
    }
  }

  Future<bool> deleteService(String id) async {
    try {
      final response = await _dio.delete("/services/$id");
      return (response.statusCode == 200 || response.statusCode == 204);
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return false;
    }
  }

  // --- 🛒 FUNGSI UNTUK MANAJEMEN PESANAN 🛒 ---

  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/orders", data: data);
      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return null;
    }
  }

  Future<List<dynamic>> getOrders() async {
    try {
      final response = await _dio.get("/orders");
      return response.data;
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return [];
    }
  }

  Future<Map<String, dynamic>?> updateOrderStatus(String id, String status) async {
    try {
      final response = await _dio.put(
        "/orders/$id",
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      _handleError(e as Exception); // Gunakan helper
      return null;
    }
  }
}

