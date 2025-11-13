import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Sesuaikan path

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({Key? key}) : super(key: key);

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  final AuthService authService = AuthService();
  late Future<List<dynamic>> _staffFuture;

  @override
  void initState() {
    super.initState();
    _muatStaf();
  }

  // Muat atau refresh data
  Future<void> _muatStaf() async {
    setState(() {
      _staffFuture = authService.getStaff();
    });
  }

  // Helper untuk mendapatkan ikon berdasarkan posisi
  IconData _getPosisiIcon(String? posisi) {
    switch (posisi) {
      case 'Groomer': return Icons.content_cut_outlined;
      case 'Penjaga Kandang': return Icons.night_shelter_outlined; // Ikon untuk Boarding
      case 'Dokter Hewan': return Icons.local_hospital_outlined; // Ikon untuk Vaksinasi
      case 'Driver': return Icons.local_shipping_outlined;
      case 'Kasir': return Icons.point_of_sale_outlined;
      case 'Admin': return Icons.admin_panel_settings_outlined;
      default: return Icons.person_outline;
    }
  }

  // --- Dialog Tambah/Update Staf ---
  void _tampilkanDialogStaf({Map<String, dynamic>? staf}) {
    // Cek apakah ini mode 'Update' (jika staf tidak null)
    bool isUpdate = staf != null;
    String dialogTitle = isUpdate ? 'Update Data Staf' : 'Tambah Staf Baru';
    String stafId = isUpdate ? staf['_id'] ?? '' : '';

    // Isi controller dengan data yang ada jika mode Update
    final TextEditingController namaController = TextEditingController(text: isUpdate ? staf['nama'] : '');
    final TextEditingController teleponController = TextEditingController(text: isUpdate ? staf['telepon'] : '');
    String currentPosisi = isUpdate ? (staf['posisi'] ?? 'Lainnya') : 'Groomer';
    
    // Daftar posisi yang sudah diperbarui
    final List<String> posisiOptions = [
      'Groomer', 
      'Penjaga Kandang', 
      'Dokter Hewan', 
      'Driver', 
      'Kasir', 
      'Admin', 
      'Lainnya'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(dialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(labelText: 'Nama Staf'),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: currentPosisi,
                      decoration: InputDecoration(labelText: 'Posisi / Jabatan'),
                      items: posisiOptions.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateInDialog(() { currentPosisi = newValue!; });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: teleponController,
                      decoration: InputDecoration(labelText: 'Nomor Telepon'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    String nama = namaController.text.trim();
                    if (nama.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Nama staf tidak boleh kosong!'), backgroundColor: Colors.red),
                       );
                       return;
                    }

                    Map<String, dynamic> dataStaf = {
                      'nama': nama,
                      'posisi': currentPosisi,
                      'telepon': teleponController.text.trim(),
                    };

                    try {
                      if (isUpdate) {
                        // Panggil API Update
                        await authService.updateStaff(stafId, dataStaf);
                      } else {
                        // Panggil API Tambah
                        await authService.addStaff(dataStaf);
                      }
                      
                      Navigator.of(context).pop();
                      _muatStaf(); // Refresh list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Data staf berhasil disimpan!'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Dialog Hapus Staf ---
  void _tampilkanDialogHapus(String id, String nama) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Staf?'),
          content: Text('Apakah kamu yakin ingin menghapus staf "$nama"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  await authService.deleteStaff(id);
                  Navigator.of(context).pop();
                  _muatStaf();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Staf "$nama" berhasil dihapus.'), backgroundColor: Colors.orange),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal hapus: $e'), backgroundColor: Colors.red),
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
        title: Text('Manajemen Staf'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _muatStaf,
        child: FutureBuilder<List<dynamic>>(
          future: _staffFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Gagal memuat data: ${snapshot.error}\n\nTarik ke bawah untuk mencoba lagi.', textAlign: TextAlign.center),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Tampilkan pesan dan tombol tambah jika kosong
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.badge_outlined, size: 80, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text('Belum ada data staf.'),
                     SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Tambah Staf Pertama'),
                      onPressed: () => _tampilkanDialogStaf(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              );
            }

            final List<dynamic> staffList = snapshot.data!;

            return ListView.separated(
              itemCount: staffList.length,
              separatorBuilder: (context, index) => Divider(height: 1, indent: 70), // Garis pemisah
              itemBuilder: (context, index) {
                final staf = staffList[index];
                final String stafId = staf['_id'] ?? '';
                final String namaStaf = staf['nama'] ?? 'Tanpa Nama';
                final String posisiStaf = staf['posisi'] ?? 'Lainnya';
                final String teleponStaf = staf['telepon'] ?? 'Tanpa nomor';

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    child: Icon(
                      _getPosisiIcon(posisiStaf), // Menggunakan ikon yang diperbarui
                      color: Colors.deepPurple,
                    ),
                  ),
                  title: Text(namaStaf, style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('$posisiStaf - $teleponStaf'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blueAccent),
                        tooltip: 'Edit Staf',
                        onPressed: () => _tampilkanDialogStaf(staf: staf),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Hapus Staf',
                        onPressed: () => _tampilkanDialogHapus(stafId, namaStaf),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tampilkanDialogStaf(), // Panggil dialog tambah
        child: Icon(Icons.add),
        tooltip: 'Tambah Staf Baru',
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}