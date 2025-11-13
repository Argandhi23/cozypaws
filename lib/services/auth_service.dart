import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart'; 

class AuthService {
  final String _currentUserKey = 'currentUser';
  final String _tokenKey = 'authToken'; 
  final Dio _dio;

  AuthService() : _dio = Dio(BaseOptions(baseUrl: "http://localhost:3000/api")) {
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('Interceptor: Token ditambahkan ke header');
        } else {
          debugPrint('Interceptor: Tidak ada token, request dikirim tanpa token');
        }
        return handler.next(options); 
      },
      onError: (DioException e, handler) async {
         if (e.response?.statusCode == 401) {
           debugPrint('Interceptor: Token tidak valid atau expired (401)');
           await logout(); 
         }
         return handler.next(e);
      }
    ));
  }

  String _handleError(Exception e) {
    String errorMessage = "Terjadi kesalahan tidak diketahui.";
    if (e is DioException) {
      if (e.response?.data is Map) {
        errorMessage = (e.response!.data as Map)['message']?.toString() 
                       ?? 'Server mengembalikan error tanpa pesan.';
      } else if (e.response?.data != null) {
        errorMessage = e.response!.data.toString();
      } else {
        errorMessage = e.message ?? 'Koneksi ke server gagal.';
      }
    } else {
      errorMessage = e.toString();
    }
    debugPrint("AuthService Error: $errorMessage");
    debugPrint(e.toString());
    throw Exception(errorMessage);
  }

  // --- 👤 FUNGSI AUTH & USER 👤 ---

  Future<void> register(String name, String email, String password) async {
    try {
      if (name.isEmpty || name.length < 3) throw Exception('Nama minimal 3 karakter');
      if (!_isValidEmail(email)) throw Exception('Gunakan email dengan format @gmail.com');
      if (password.isEmpty || password.length < 6) throw Exception('Password minimal 6 karakter');
      final response = await _dio.post(
        '/users', data: {'nama': name, 'email': email, 'password': password},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gagal registrasi (${response.statusCode})');
      }
    } catch (e) { _handleError(e as Exception); }
  }

  Future<User?> login(String nameOrEmail, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login', data: {'email': nameOrEmail, 'password': password},
      );
      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token']; 
        final prefs = await SharedPreferences.getInstance();
        
        // User.fromJson sekarang akan mem-parsing 'pets' juga
        final currentUser = User.fromJson(userData); 
        
        await prefs.setString(_currentUserKey, currentUser.encode());
        await prefs.setString(_tokenKey, token); 
        
        return currentUser;
      } else { return null; }
    } catch (e) {
      _handleError(e as Exception); 
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove(_tokenKey); 
  }

  // --- 🔽 TAMBAHKAN FUNGSI BARU INI 🔽 ---
  /// 🔹 GET FRESH USER PROFILE (dari Server)
  /// Mengambil data user terbaru (termasuk pets) dari server
  Future<User?> getFreshUserProfile() async {
    try {
      // Panggil API /profile baru. Interceptor akan kirim token
      final response = await _dio.get("/users/profile"); 
      
      if (response.statusCode == 200) {
        // 1. Ambil data user lengkap (termasuk pets)
        final userData = response.data;
        final currentUser = User.fromJson(userData);
        
        // 2. Perbarui data di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentUserKey, currentUser.encode());
        
        // 3. Kembalikan data user baru
        return currentUser;
      }
      return null;
    } catch (e) {
      _handleError(e as Exception);
      return null;
    }
  }
  // --- ------------------------------- ---

  /// 🔹 GET CURRENT USER (dari SharedPreferences)
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_currentUserKey);
    if (data == null) return null;
    // Perhatikan: User.decode (dan FromJson) sekarang mem-parsing 'pets'
    return User.decode(data); 
  }

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      if (newPassword.isEmpty || newPassword.length < 6) throw Exception('Password minimal 6 karakter');
      final response = await _dio.put(
        '/users/reset-password', data: {'email': email, 'newPassword': newPassword},
      );
      if (response.statusCode != 200) { throw Exception('Gagal reset password'); }
    } catch (e) { _handleError(e as Exception); }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.\-]+@gmail\.com$');
    return regex.hasMatch(email);
  }

  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get("/users");
      return response.data;
    } catch (e) { _handleError(e as Exception); return []; }
  }

  Future<Map<String, dynamic>?> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/users/$id", data: data);
      if (response.statusCode == 200) { return response.data['user']; }
      return null;
    } catch (e) { _handleError(e as Exception); return null; }
  }

  Future<bool> deleteUser(String id) async {
    try {
      final response = await _dio.delete("/users/$id");
      return (response.statusCode == 200 || response.statusCode == 204);
    } catch (e) { _handleError(e as Exception); return false; }
  }

  // --- 📦 FUNGSI UNTUK SERVICES 📦 ---

  Future<List<dynamic>> getServices() async {
    try {
      final response = await _dio.get("/services");
      return response.data;
    } catch (e) { _handleError(e as Exception); return []; }
  }

  Future<Map<String, dynamic>?> addService(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/services", data: data);
      if (response.statusCode == 201) { return response.data; }
      return null;
    } catch (e) { _handleError(e as Exception); return null; }
  }

  Future<Map<String, dynamic>?> updateService(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/services/$id", data: data);
      if (response.statusCode == 200) { return response.data; }
      return null;
    } catch (e) { _handleError(e as Exception); return null; }
  }

  Future<bool> deleteService(String id) async {
    try {
      final response = await _dio.delete("/services/$id");
      return (response.statusCode == 200 || response.statusCode == 204);
    } catch (e) { _handleError(e as Exception); return false; }
  }

  // --- 🛒 FUNGSI UNTUK MANAJEMEN PESANAN 🛒 ---

  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/orders", data: data);
      if (response.statusCode == 201) { return response.data; }
      return null;
    } catch (e) { _handleError(e as Exception); return null; }
  }

  Future<List<dynamic>> getOrders() async {
    try {
      final response = await _dio.get("/orders");
      return response.data;
    } catch (e) { _handleError(e as Exception); return []; }
  }

  Future<List<dynamic>> getMyOrders() async {
    try {
      final response = await _dio.get("/orders/myorders"); 
      return response.data;
    } catch (e) {
      _handleError(e as Exception);
      return [];
    }
  }

  Future<Map<String, dynamic>?> updateOrderStatus(String id, String status, String? staffId) async {
    try {
      Map<String, dynamic> data = { 'status': status, 'assignedStaff': staffId };
      final response = await _dio.put("/orders/$id", data: data);
      if (response.statusCode == 200) { return response.data; }
      return null;
    } catch (e) { _handleError(e as Exception); return null; }
  }

  // --- 🧑‍🔧 FUNGSI UNTUK MANAJEMEN STAF 🧑‍🔧 ---

  Future<Map<String, dynamic>?> addStaff(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/staff", data: data);
      if (response.statusCode == 201) { return response.data; }
      return null;
    } catch (e) { _handleError(e as Exception); return null; }
  }

  Future<List<dynamic>> getStaff() async {
    try {
      final response = await _dio.get("/staff");
      return response.data;
    } catch (e) { _handleError(e as Exception); return []; }
  }

  Future<Map<String, dynamic>?> updateStaff(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/staff/$id", data: data);
      if (response.statusCode == 200) { return response.data; }
      return null;
    } catch (e) { _handleError(e as Exception); return null; }
  }

  Future<bool> deleteStaff(String id) async {
    try {
      final response = await _dio.delete("/staff/$id");
      return (response.statusCode == 200 || response.statusCode == 204);
    } catch (e) { _handleError(e as Exception); return false; }
  }

  // --- 🐾 FUNGSI UNTUK MANAJEMEN PETS (MILIK USER) 🐾 ---

  Future<Map<String, dynamic>?> addPet(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/users/pets", data: data);
      if (response.statusCode == 201) {
        return response.data; 
      }
      return null;
    } catch (e) {
      _handleError(e as Exception);
      return null;
    }
  }

  Future<Map<String, dynamic>?> updatePet(String petId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/users/pets/$petId", data: data);
      if (response.statusCode == 200) {
        return response.data; 
      }
      return null;
    } catch (e) {
      _handleError(e as Exception);
      return null;
    }
  }

  Future<bool> deletePet(String petId) async {
    try {
      final response = await _dio.delete("/users/pets/$petId");
      return (response.statusCode == 200 || response.statusCode == 204);
    } catch (e) {
      _handleError(e as Exception);
      return false;
    }
  }
}