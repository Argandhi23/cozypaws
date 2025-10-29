import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  final String _currentUserKey = 'currentUser';

  // 🔹 Ganti sesuai mode kamu jalankan Flutter
  // Web         → http://localhost:3000/api
  // Android     → http://10.0.2.2:3000/api
  // HP Asli     → http://192.168.x.x:3000/api
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://localhost:3000/api"));

  /// 🔹 REGISTER USER
  Future<void> register(String name, String email, String password) async {
    try {
      if (name.isEmpty || name.length < 3) {
        throw Exception('Nama minimal 3 karakter');
      }
      if (!_isValidEmail(email)) {
        throw Exception('Gunakan email dengan format @gmail.com');
      }
      if (password.isEmpty || password.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }

      final response = await _dio.post(
        '/users',
        data: {
          'nama': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registrasi berhasil: ${response.data}');
      } else {
        throw Exception('Gagal registrasi (${response.statusCode})');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan koneksi server';
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 🔹 LOGIN USER
  Future<bool> login(String nameOrEmail, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': nameOrEmail,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final prefs = await SharedPreferences.getInstance();

        // Simpan user yang sedang login
        final currentUser = User(
          name: userData['nama'],
          email: userData['email'],
          password: userData['password'],
        );

        await prefs.setString(_currentUserKey, currentUser.encode());
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login gagal. Coba lagi.';
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 🔹 LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
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
    if (newPassword.isEmpty || newPassword.length < 6) {
      throw Exception('Password minimal 6 karakter');
    }

    try {
      final response = await _dio.put(
        '/users/reset-password',
        data: {
          'email': email,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal reset password');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Gagal reset password';
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 🔹 VALIDASI EMAIL
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.\-]+@gmail\.com$');
    return regex.hasMatch(email);
  }
}
