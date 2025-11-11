import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart'; // Pastikan user.dart punya field 'role' dan 'id'

class AuthService {
  final String _currentUserKey = 'currentUser';
  final String _tokenKey = 'authToken'; // <-- 1. KUNCI BARU UNTUK TOKEN
  final Dio _dio;

  // --- 2. UBAH CONSTRUCTOR UNTUK MENAMBAHKAN INTERCEPTOR ---
  AuthService() : _dio = Dio(BaseOptions(baseUrl: "http://localhost:3000/api")) {
    
    // 3. TAMBAHKAN INTERCEPTOR (PENJAGA OTOMATIS)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Fungsi ini berjalan SEBELUM setiap request dikirim
        
        // 1. Ambil token dari SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_tokenKey);

        if (token != null) {
          // 2. Jika token ada, tambahkan ke header
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('Interceptor: Token ditambahkan ke header');
        } else {
          debugPrint('Interceptor: Tidak ada token, request dikirim tanpa token');
        }
        
        // 3. Lanjutkan request
        return handler.next(options); 
      },
      onError: (DioException e, handler) async {
         // (Opsional) Tangani error 401 (token expired) secara global
         if (e.response?.statusCode == 401) {
           debugPrint('Interceptor: Token tidak valid atau expired (401)');
           // Jika token expired, hapus data login
           await logout(); 
           // TODO: Di sini kamu bisa tambahkan navigasi paksa ke LoginScreen
         }
         return handler.next(e);
      }
    ));
    // --- ---------------------------------------------------- ---
  }


  // --- Helper Cerdas untuk Ekstrak Pesan Error ---
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

  /// 🔹 REGISTER USER
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
      _handleError(e as Exception);
    }
  }

  /// 🔹 LOGIN USER
  Future<User?> login(String nameOrEmail, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': nameOrEmail, 'password': password},
      );
      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token']; // <-- 4. AMBIL TOKEN

        final prefs = await SharedPreferences.getInstance();
        
        final currentUser = User.fromJson(userData);

        // --- 5. SIMPAN USER DAN TOKEN ---
        await prefs.setString(_currentUserKey, currentUser.encode());
        await prefs.setString(_tokenKey, token); // <-- SIMPAN TOKEN
        // -------------------------------
        
        return currentUser;
      } else {
        return null;
      }
    } catch (e) {
      _handleError(e as Exception); 
      return null;
    }
  }

  /// 🔹 LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // --- 6. HAPUS USER DAN TOKEN ---
    await prefs.remove(_currentUserKey);
    await prefs.remove(_tokenKey); // <-- HAPUS TOKEN
    // -----------------------------
  }

  /// 🔹 GET CURRENT USER
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_currentUserKey);
    if (data == null) return null;
    return User.decode(data);
  }

  /// 🔹 RESET PASSWORD
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
      _handleError(e as Exception);
    }
  }

  /// 🔹 VALIDASI EMAIL
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.\-]+@gmail\.com$');
    return regex.hasMatch(email);
  }

  /// 🔹 GET (Ambil semua users)
  /// (TIDAK PERLU DIUBAH - Interceptor menangani token)
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get("/users");
      return response.data;
    } catch (e) {
      _handleError(e as Exception); 
      return []; 
    }
  }

  /// 🔹 UPDATE (Update user by ID)
  /// (TIDAK PERLU DIUBAH - Interceptor menangani token)
  Future<Map<String, dynamic>?> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/users/$id", data: data);
      if (response.statusCode == 200) {
        return response.data['user'];
      }
      return null;
    } catch (e) {
      _handleError(e as Exception); 
      return null;
    }
  }

  /// 🔹 DELETE (Hapus user by ID)
  /// (TIDAK PERLU DIUBAH - Interceptor menangani token)
  Future<bool> deleteUser(String id) async {
    try {
      final response = await _dio.delete("/users/$id");
      return (response.statusCode == 200 || response.statusCode == 204);
    } catch (e) {
      _handleError(e as Exception);
      return false;
    }
  }

  // --- 📦 FUNGSI UNTUK SERVICES 📦 ---
  // (SEMUA FUNGSI DI BAWAH INI TIDAK PERLU DIUBAH)

  /// 🔹 READ (Ambil semua services)
  Future<List<dynamic>> getServices() async {
    try {
      final response = await _dio.get("/services");
      return response.data;
    } catch (e) {
      _handleError(e as Exception); 
      return [];
    }
  }

  /// 🔹 CREATE (Tambah service baru)
  Future<Map<String, dynamic>?> addService(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/services", data: data);
      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      _handleError(e as Exception);
      return null;
    }
  }

  /// 🔹 UPDATE (Perbarui service by ID)
  Future<Map<String, dynamic>?> updateService(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/services/$id", data: data);
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      _handleError(e as Exception);
      return null;
    }
  }

  /// 🔹 DELETE (Hapus service by ID)
  Future<bool> deleteService(String id) async {
    try {
      final response = await _dio.delete("/services/$id");
      return (response.statusCode == 200 || response.statusCode == 204);
    } catch (e) {
      _handleError(e as Exception); 
      return false;
    }
  }

  // --- 🛒 FUNGSI UNTUK MANAJEMEN PESANAN 🛒 ---
  // (SEMUA FUNGSI DI BAWAH INI TIDAK PERLU DIUBAH)

  /// 🔹 CREATE (Buat pesanan baru)
  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/orders", data: data);
      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      _handleError(e as Exception);
      return null;
    }
  }

  /// 🔹 READ (Ambil semua pesanan - Untuk Admin)
  Future<List<dynamic>> getOrders() async {
    try {
      final response = await _dio.get("/orders");
      return response.data;
    } catch (e) {
      _handleError(e as Exception);
      return [];
    }
  }

  /// 🔹 UPDATE (Update status pesanan by ID - Untuk Admin)
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
      _handleError(e as Exception);
      return null;
    }
  }
}