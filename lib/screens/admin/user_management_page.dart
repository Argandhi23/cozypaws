import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Sesuaikan path
import '../../models/user.dart'; // Sesuaikan path

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final AuthService authService = AuthService();
  // Gunakan List<User> agar lebih type-safe
  late Future<List<User>> _usersFuture; 

  @override
  void initState() {
    super.initState();
    _muatPengguna();
  }

  // Fungsi untuk memuat (atau me-refresh) data pengguna
  Future<void> _muatPengguna() async {
    setState(() {
      _usersFuture = _fetchAndParseUsers(); // Panggil fungsi parsing
    });
  }

  // Fungsi terpisah untuk fetch dan parse data
  Future<List<User>> _fetchAndParseUsers() async {
    try {
      final List<dynamic> userDataList = await authService.getUsers();
      // Konversi List<dynamic> (Map) menjadi List<User>
      return userDataList
          .map((userData) => User.fromJson(userData as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Jika gagal fetch/parse, lempar error agar FutureBuilder bisa tangkap
      throw Exception('Gagal memuat data pengguna: $e');
    }
  }

  // Dialog untuk mengedit role user
  void _tampilkanDialogEditRole(User user) {
    // ... (Kode dialog ini sudah cukup bagus, tidak perlu diubah signifikan) ...
    String currentRole = user.role; 
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text('Edit Role: ${user.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Pilih role baru untuk pengguna ini:"),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: currentRole,
                    isExpanded: true,
                    items: ['user', 'admin'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setStateInDialog(() { 
                        currentRole = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (currentRole != user.role) { 
                      try {
                        await authService.updateUser(user.id!, {'role': currentRole});
                         Navigator.of(context).pop();
                         _muatPengguna(); // Refresh list
                         ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Role ${user.name} berhasil diubah ke $currentRole'), backgroundColor: Colors.green),
                         );
                      } catch (e) {
                         if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Gagal update role: $e'), backgroundColor: Colors.red),
                           );
                         }
                      }
                    } else {
                       Navigator.of(context).pop(); 
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Dialog konfirmasi hapus user
  void _tampilkanDialogHapus(User user) {
     // ... (Kode dialog ini sudah cukup bagus, tidak perlu diubah signifikan) ...
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Pengguna?'),
          content: Text('Apakah kamu yakin ingin menghapus pengguna "${user.name}" (${user.email})? Tindakan ini tidak bisa dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                 try {
                    await authService.deleteUser(user.id!); 
                    Navigator.of(context).pop();
                    _muatPengguna(); // Refresh list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pengguna ${user.name} berhasil dihapus.'), backgroundColor: Colors.orange),
                    );
                 } catch (e) {
                     if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Gagal menghapus pengguna: $e'), backgroundColor: Colors.red),
                       );
                     }
                 }
              },
              child: Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Pengguna'),
        backgroundColor: Colors.deepPurple,
        // Tombol Refresh dipindah ke RefreshIndicator
      ),
      // Gunakan RefreshIndicator
      body: RefreshIndicator( 
        onRefresh: _muatPengguna, // Panggil fungsi muat ulang saat ditarik
        child: FutureBuilder<List<User>>( // Ubah ke List<User>
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              // Tampilkan pesan error yang lebih user-friendly
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Gagal memuat data: ${snapshot.error}\n\nTarik ke bawah untuk mencoba lagi.', textAlign: TextAlign.center),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Tidak ada pengguna terdaftar.'));
            }

            final List<User> users = snapshot.data!; // Sekarang sudah List<User>

            return ListView.separated( // Gunakan separated untuk garis pemisah
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(height: 1, indent: 70), // Garis pemisah
              itemBuilder: (context, index) {
                final user = users[index];
                bool isAdmin = user.role == 'admin'; // Cek apakah admin

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Atur padding
                  leading: CircleAvatar(
                    backgroundColor: isAdmin ? Colors.deepPurple[100] : Colors.pink[50],
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline, // Ikon outline
                      color: isAdmin ? Colors.deepPurple : Colors.pinkAccent,
                    ),
                  ),
                  title: Text(
                    user.name, 
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15) // Sedikit perbesar nama
                  ),
                  subtitle: Text(user.email, style: TextStyle(fontSize: 13, color: Colors.black54)), // Perjelas subtitle
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit Role dibuat lebih jelas
                      TextButton.icon(
                        icon: Icon(Icons.edit_note, size: 20, color: Colors.blueAccent),
                        label: Text(user.role, style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                        style: TextButton.styleFrom(
                           padding: EdgeInsets.symmetric(horizontal: 8),
                           minimumSize: Size(0, 30), // Perkecil tombol
                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                           side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)) // Tambah border tipis
                        ),
                        onPressed: () => _tampilkanDialogEditRole(user),
                      ),
                      SizedBox(width: 4), // Beri sedikit jarak
                      // Tombol Hapus User
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent), // Ikon outline
                        tooltip: 'Hapus Pengguna',
                        onPressed: () => _tampilkanDialogHapus(user),
                        visualDensity: VisualDensity.compact, // Perkecil tombol ikon
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}