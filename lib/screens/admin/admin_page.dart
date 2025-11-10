import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

// Halaman-halaman yang akan diakses dari drawer
import 'service_management_page.dart';
import 'user_management_page.dart';
import 'order_management_page.dart';
import '../home_screen.dart';
import '../login_screen.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AuthService authService = AuthService();
  User? _currentUser;
  late Future<int> _totalUsersFuture;
  late Future<int> _totalOrdersFuture;

  @override
  void initState() {
    super.initState();
    _muatDataAdmin();
    _fetchDashboardData();
  }

  Future<void> _muatDataAdmin() async {
    final user = await authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _totalUsersFuture = authService.getUsers().then((list) => list.length);
      _totalOrdersFuture = authService.getOrders().then((list) => list.length);
    });
  }

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF48FB1),
                Color(0xFF7E57C2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Data Dashboard',
            onPressed: _fetchDashboardData,
          ),
        ],
      ),

      drawer: _buildAdminDrawer(context),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(),
            const SizedBox(height: 20),
            _buildWelcomeMessage(),
            const SizedBox(height: 20),
            _buildUserSummarySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
            value: 'All time',
            items: <String>['All time', 'Last 7 days', 'Last 30 days']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,      
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {},
          )
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                context: context,
                title: 'Pengguna',
                valueFuture: _totalUsersFuture,
                change: '+0%',
                isPositive: true,
                icon: Icons.people_outline,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildInfoCard(
                context: context,
                title: 'Pesanan',
                valueFuture: _totalOrdersFuture,
                change: '+0%',
                isPositive: true,
                icon: Icons.receipt_long_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required Future<int> valueFuture,
    required String change,
    required bool isPositive,
    required IconData icon,
  }) {
    return Card(
      color: Colors.white,
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
                Icon(icon, color: Colors.deepPurple),
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
                  return const Text('Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
                }
                return Text(
                  snapshot.data?.toString() ?? '0',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  'from last month',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Card(
      color: Colors.white,
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

  Widget _buildUserSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pengguna Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        FutureBuilder<List<dynamic>>(
          future: authService.getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error memuat pengguna: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada pengguna terdaftar.'));
            }

            List<dynamic> users = snapshot.data!;
            users.sort((a, b) => b['_id'].compareTo(a['_id']));
            final latestUsers = users.take(3).toList();

            return Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ...latestUsers.map((user) => _buildUserAvatar(
                          name: user['nama'] ?? 'Pengguna',
                          email: user['email'] ?? '',
                        )),
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
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserAvatar({required String name, required String email}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.deepPurple[100],
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Panel Admin Cozypaws',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
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

          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: Colors.deepPurple),
            title: const Text('Dashboard'),
            tileColor: Colors.deepPurple[50],
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.storefront_outlined, color: Colors.black54),
            title: const Text('Manajemen Layanan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ServiceManagementPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long_outlined, color: Colors.black54),
            title: const Text('Manajemen Pesanan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderManagementPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined, color: Colors.black54),
            title: const Text('Manajemen Pengguna'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementPage()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.home_outlined, color: Colors.black54),
            title: const Text('Kembali ke Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(userNameOrEmail: _currentUser?.name ?? 'User'),
                ),
                (route) => false,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
