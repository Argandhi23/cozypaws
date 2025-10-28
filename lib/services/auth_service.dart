import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  final String _usersKey = 'users';
  final String _currentUserKey = 'currentUser';

  /// REGISTER USER
  Future<void> register(String name, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      // Validasi
      if (name.isEmpty || name.length < 3) {
        throw Exception('Nama minimal 3 karakter');
      }
      if (email.isEmpty || !_isValidEmail(email)) {
        throw Exception('Gunakan email dengan format @gmail.com');
      }
      if (password.isEmpty || password.length < 8) {
        throw Exception('Password minimal 8 karakter');
      }

      // Cek user sudah ada
      final isExisting = await isUserExists(name, email);
      if (isExisting) throw Exception('Nama atau Email sudah terdaftar');

      // Tambah user baru
      final newUser = User(name: name, email: email, password: password);
      users.add(newUser.encode());
      await prefs.setStringList(_usersKey, users);
    } catch (e) {
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  /// LOGIN USER
  Future<bool> login(String nameOrEmail, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      for (var user in users) {
        final userData = User.decode(user);
        if ((userData.name == nameOrEmail || userData.email == nameOrEmail) &&
            userData.password == password) {
          await prefs.setString(_currentUserKey, userData.encode());
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception('Login gagal: ${e.toString()}');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// CEK USER ADA
  Future<bool> isUserExists(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_usersKey) ?? [];
    return users.any((user) {
      final userData = User.decode(user);
      return userData.name == name || userData.email == email;
    });
  }

  /// GET CURRENT USER
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserData = prefs.getString(_currentUserKey);
    if (currentUserData == null) return null;
    return User.decode(currentUserData);
  }

  /// GET ALL USERS
  Future<List<User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_usersKey) ?? [];
    return users.map((u) => User.decode(u)).toList();
  }

  /// RESET PASSWORD
  Future<void> resetPassword(String email, String newPassword) async {
    if (newPassword.isEmpty || newPassword.length < 8) {
      throw Exception('Password minimal 8 karakter');
    }

    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_usersKey) ?? [];

    bool isUpdated = false;

    for (int i = 0; i < users.length; i++) {
      final userData = User.decode(users[i]);
      if (userData.email == email) {
        // Update password
        final updatedUser = User(
          name: userData.name,
          email: userData.email,
          password: newPassword,
        );
        users[i] = updatedUser.encode();
        isUpdated = true;
        break;
      }
    }

    if (!isUpdated) {
      throw Exception('Email tidak terdaftar');
    }

    await prefs.setStringList(_usersKey, users);
  }

  /// VALIDASI EMAIL
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.\-]+@gmail\.com$');
    return regex.hasMatch(email);
  }
}