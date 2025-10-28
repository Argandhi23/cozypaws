import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/auth_service.dart'; 
import '../models/user.dart';
import '../utils/format_utils.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;
  double _userRating = 3;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadOrders();
    _loadRating(); 
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrders();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false; 
      });
    }
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final orderList = prefs.getStringList('orders') ?? [];

    List<Map<String, dynamic>> loadedOrders = [];

    for (var item in orderList) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          loadedOrders.add(decoded);
        }
      } catch (e) {
        debugPrint('Error decoding order: $e');
      }
    }

    if (mounted) {
      setState(() {
        _orders = loadedOrders.reversed.toList();
      });
    }
  }

  Future<void> _clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders');
    if (mounted) {
      setState(() {
        _orders.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua riwayat pesanan telah dihapus."),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // ------------------ RATING ------------------
  Future<void> _loadRating() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRating = prefs.getDouble('user_rating') ?? 3;
    });
  }

  Future<void> _saveRating(double rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_rating', rating);
  }

  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.purple)),
      );
    }

    if (_currentUser != null) {
      final email = _currentUser!.email;
      final name = _currentUser!.name;

      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 246, 254),
        appBar: AppBar(
          title: const Text(
            "Profil Saya",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8BBD0), Color(0xFFB39DDB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.purple),
                    ),
                    const SizedBox(height: 10),
                    Text("Hai, $name",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(email,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // INFORMASI AKUN
              _buildAccordion(
                title: "Informasi Akun",
                icon: Icons.account_circle,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.person, "Nama Pengguna", name),
                    const SizedBox(height: 8),
                    _infoRow(Icons.email, "Email", email),
                    const SizedBox(height: 8),
                    _infoRow(Icons.verified_user, "Status Akun", "Aktif"),
                  ],
                ),
              ),

              // RIWAYAT PESANAN
              _buildAccordion(
                title: "Riwayat Pesanan (${_orders.length})",
                icon: Icons.history,
                content: _orders.isEmpty
                    ? const Text(
                        "Belum ada riwayat pesanan.",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      )
                    : Column(
                        children: [
                          ..._orders.map((order) {
                            final package = order['packageName'] ?? 'Paket Tidak Diketahui';
                            final date = order['date'] ?? '-';
                            final cat = order['catName'] ?? 'Tanpa nama';
                            final owner = order['owner'] ?? '-';
                            final price = FormatUtils.rupiah(order['price']); // <-- pakai global

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              leading: const Icon(Icons.pets, color: Colors.purple),
                              title: Text(
                                package,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                "$date • $cat (Pemilik: $owner)",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black87),
                              ),
                              trailing: Text(
                                price,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _clearOrders,
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            label: const Text(
                              "Hapus Semua Riwayat",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
              ),

              // Tentang
              _buildAccordion(
                title: "Tentang Aplikasi",
                icon: Icons.info_outline,
                content: const Text(
                  "Cozypaws adalah aplikasi layanan perawatan hewan peliharaan berbasis Flutter. "
                  "Dikembangkan untuk membantu pawrent menjadwalkan grooming, boarding, vaksinasi, dan konsultasi dengan mudah dan cepat. "
                  "Created with love by 006_B_Febriana N.A.",
                  style:
                      TextStyle(fontSize: 12, color: Colors.purple, height: 1.4),
                ),
              ),

              const SizedBox(height: 18),

              // RATING
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Bagaimana pengalaman Anda menggunakan Cozypaws?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      RatingBar.builder(
                        initialRating: _userRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return const Icon(Icons.sentiment_very_dissatisfied,
                                  color: Colors.red);
                            case 1:
                              return const Icon(Icons.sentiment_dissatisfied,
                                  color: Colors.redAccent);
                            case 2:
                              return const Icon(Icons.sentiment_neutral,
                                  color: Colors.amber);
                            case 3:
                              return const Icon(Icons.sentiment_satisfied,
                                  color: Colors.lightGreen);
                            case 4:
                              return const Icon(Icons.sentiment_very_satisfied,
                                  color: Colors.green);
                            default:
                              return const Icon(Icons.sentiment_neutral);
                          }
                        },
                        onRatingUpdate: (rating) {
                          setState(() => _userRating = rating);
                          _saveRating(rating); // <- simpan rating setiap update
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Rating Anda: ${_userRating.toStringAsFixed(1)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // LOGOUT
              Center(
                child: Container(
                  width: 140,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: _logout,
                    child: const Center(
                      child: Text(
                        "LOGOUT",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }
    
    return const Scaffold(
      body: Center(
        child: Text("Tidak ada pengguna yang login. Silakan coba login kembali."),
      ),
    );
  }

  // Reusable Accordion Builder
  Widget _buildAccordion({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GFAccordion(
        title: title,
        titleBorder: Border.all(color: Colors.transparent),
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        contentPadding: const EdgeInsets.all(12),
        collapsedIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
        expandedIcon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
        titleBorderRadius: BorderRadius.circular(10),
        expandedTitleBackgroundColor: const Color(0xFFF3E5F5),
        textStyle: const TextStyle(
          fontSize: 14,
          color: Colors.purple,
          fontWeight: FontWeight.bold,
        ),
        titleChild: Row(
          children: [
            Icon(icon, color: Colors.purple),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        contentChild: content,
      ),
    );
  }

  static Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple)),
              Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}