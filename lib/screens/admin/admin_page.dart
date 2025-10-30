import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

// Halaman-halaman yang akan diakses dari drawer
import 'service_management_page.dart'; // <--- BARU, untuk manajemen layanan
import 'user_management_page.dart';
import 'order_management_page.dart';
import '../home_screen.dart'; // Untuk "Kembali ke Home"
import '../login_screen.dart'; // Untuk "Logout"

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AuthService authService = AuthService();
  User? _currentUser;
  late Future<int> _totalUsersFuture; // Untuk menampilkan jumlah user
  late Future<int> _totalOrdersFuture; // Untuk menampilkan jumlah pesanan

  @override
  void initState() {
    super.initState();
    _muatDataAdmin();
    _fetchDashboardData(); // Panggil fungsi untuk ambil data dashboard
  }

  // Fungsi untuk memuat data admin (nama/email)
  Future<void> _muatDataAdmin() async {
    final user = await authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  // Fungsi untuk mengambil data dashboard (jumlah user, jumlah pesanan)
  Future<void> _fetchDashboardData() async {
    setState(() {
      // Perhatikan: fungsi getUsers dan getOrders mengembalikan List<dynamic>
      // Kita perlu menghitung .length dari list tersebut.
      _totalUsersFuture = authService.getUsers().then((list) => list.length);
      _totalOrdersFuture = authService.getOrders().then((list) => list.length);
    });
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    await authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background lebih terang
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Icon menu hitam
        title: const Text('Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Muat Ulang Data Dashboard',
            onPressed: _fetchDashboardData, // Refresh data dashboard
          ),
          // Tombol Sign In/Sign Up dari gambar tidak relevan untuk admin
        ],
      ),
      drawer: _buildAdminDrawer(context), // Sidebar
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header "Dashboard" sudah di AppBar
            // Bagian Overview
            _buildOverviewSection(),
            const SizedBox(height: 20),

            // Welcome Message & Send Button
            _buildWelcomeMessage(),
            const SizedBox(height: 20),

            // Customer Section (kita akan sesuaikan untuk Users)
            _buildUserSummarySection(),
          ],
        ),
      ),
    );
  }

  // Widget untuk bagian Overview (Customers & Revenue)
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: 'All time', // Contoh saja, bisa dinamis
              items: <String>['All time', 'Last 7 days', 'Last 30 days']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Implementasi filter waktu jika diperlukan
              },
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                context: context,
                title: 'Pengguna',
                valueFuture: _totalUsersFuture, // Menggunakan future
                change: '+0%', // Placeholder, bisa dihitung dari data
                isPositive: true,
                icon: Icons.people_outline,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildInfoCard(
                context: context,
                title: 'Pesanan',
                valueFuture: _totalOrdersFuture, // Menggunakan future
                change: '+0%', // Placeholder, bisa dihitung dari data
                isPositive: true,
                icon: Icons.receipt_long_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Widget untuk Kartu Info (Customers/Revenue)
  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required Future<int> valueFuture, // Menerima Future<int>
    required String change,
    required bool isPositive,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[700])),
                Icon(icon, color: Colors.deepPurple), // Menambahkan ikon
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: valueFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(strokeWidth: 2);
                }
                if (snapshot.hasError) {
                  return Text('Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
                }
                return Text(
                  snapshot.data?.toString() ?? '0', // Tampilkan jumlah atau '0'
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'from last month', // Placeholder
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Welcome Message (disesuaikan)
  Widget _buildWelcomeMessage() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Selamat datang, Admin! Kelola operasional Cozypaws dengan mudah. 🐾',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Aksi untuk pesan khusus, jika ada
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur kirim pesan belum diimplementasi.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Kirim Notifikasi'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk User Summary (menggantikan Customers di gambar)
  Widget _buildUserSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pengguna Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        FutureBuilder<List<dynamic>>(
          future: authService.getUsers(), // Ambil daftar pengguna
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error memuat pengguna: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Belum ada pengguna terdaftar.'));
            }

            // Tampilkan maksimal 3 pengguna untuk "Terbaru"
            List<dynamic> users = snapshot.data!;
            // Urutkan berdasarkan _id (waktu dibuat) secara descending jika memungkinkan
            users.sort((a, b) => b['_id'].compareTo(a['_id']));
            
            final latestUsers = users.take(3).toList(); // Ambil 3 teratas

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ...latestUsers.map((user) => _buildUserAvatar(
                              name: user['nama'] ?? 'Pengguna',
                              email: user['email'] ?? '',
                            )),
                        // Tombol "View all"
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UserManagementPage()),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper Widget untuk Avatar User
  Widget _buildUserAvatar({required String name, required String email}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.deepPurple[100],
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          // Jika ada gambar profil bisa pakai NetworkImage
          // backgroundImage: NetworkImage('URL_GAMBAR'),
        ),
        const SizedBox(height: 8),
        Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }


  // --- 🔽 WIDGET UNTUK MEMBANGUN SIDEBAR (DRAWER) 🔽 ---
  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)], // Warna header
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Panel Admin Cozypaws',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _currentUser?.email ?? 'Loading...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu 1: Dashboard (Halaman saat ini)
          ListTile(
            leading: Icon(Icons.dashboard_outlined, color: Colors.deepPurple),
            title: Text('Dashboard'),
            tileColor: Colors.deepPurple[50], // Tandai halaman aktif
            onTap: () {
              Navigator.pop(context); // Tutup drawer-nya
            },
          ),
          
          // Menu 2: Manajemen Layanan (link ke halaman baru)
          ListTile(
            leading: Icon(Icons.storefront_outlined, color: Colors.black54),
            title: Text('Manajemen Layanan'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ServiceManagementPage()), // <--- LINK BARU
              );
            },
          ),
          
          // Menu 3: Manajemen Pesanan
          ListTile(
            leading: Icon(Icons.receipt_long_outlined, color: Colors.black54),
            title: Text('Manajemen Pesanan'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderManagementPage()),
              );
            },
          ),

          // Menu 4: Manajemen Pengguna
          ListTile(
            leading: Icon(Icons.manage_accounts_outlined, color: Colors.black54),
            title: Text('Manajemen Pengguna'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementPage()),
              );
            },
          ),
          
          Divider(),

          // Menu 5: Kembali ke Home (Aplikasi User)
          ListTile(
            leading: Icon(Icons.home_outlined, color: Colors.black54),
            title: Text('Kembali ke Home'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              // Ganti halaman dan hapus semua rute admin dari stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(userNameOrEmail: _currentUser?.name ?? 'User')),
                (route) => false,
              );
            },
          ),

          // Menu 6: Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: Text('Logout'),
            onTap: () {
              // Panggil fungsi logout
              _logout();
            },
          ),
        ],
      ),
    );
  }
  // --- -------------------------------------------- ---
}