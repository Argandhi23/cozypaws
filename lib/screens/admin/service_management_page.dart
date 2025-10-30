import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/format_utils.dart'; // Import FormatUtils

class ServiceManagementPage extends StatefulWidget {
  const ServiceManagementPage({Key? key}) : super(key: key);

  @override
  State<ServiceManagementPage> createState() => _ServiceManagementPageState();
}

class _ServiceManagementPageState extends State<ServiceManagementPage> {
  final AuthService authService = AuthService();
  late Future<List<dynamic>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _muatLayanan();
  }

  // Muat atau refresh data
  Future<void> _muatLayanan() async {
    setState(() {
      // Panggil API getServices dan simpan Future-nya
      _servicesFuture = authService.getServices();
    });
  }

  // --- Dialog Tambah Layanan ---
  void _tampilkanDialogTambah() {
    // ... (Kode dialog ini sudah cukup baik, tidak perlu diubah signifikan) ...
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    String selectedServiceType = 'Grooming';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text('Tambah Layanan Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedServiceType,
                      decoration: InputDecoration(labelText: 'Tipe Layanan'),
                      items: ['Grooming', 'Boarding', 'Vaksinasi', 'AntarJemput']
                          .map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateInDialog(() { selectedServiceType = newValue!; });
                      },
                    ),
                    TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nama Layanan')),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Harga Dasar'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextField(controller: descController, decoration: InputDecoration(labelText: 'Deskripsi'), maxLines: 3),
                    TextField(controller: imageUrlController, decoration: InputDecoration(labelText: 'URL Gambar (opsional)')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic> newServiceData = {
                      'serviceType': selectedServiceType,
                      'name': nameController.text.trim(), // Trim spasi
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'description': descController.text.trim(), // Trim spasi
                      'imageUrl': imageUrlController.text.trim().isNotEmpty ? imageUrlController.text.trim() : null,
                      'packages': [],
                    };
                     // Validasi nama tidak boleh kosong
                    if (newServiceData['name'].isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Nama layanan tidak boleh kosong!'), backgroundColor: Colors.red),
                       );
                       return; // Hentikan proses jika nama kosong
                    }

                    try {
                      await authService.addService(newServiceData);
                      Navigator.of(context).pop();
                      _muatLayanan();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Layanan berhasil ditambahkan!'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menambah: $e'), backgroundColor: Colors.red),
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
  // --- END DIALOG TAMBAH ---

  // --- Dialog Update Layanan ---
  void _tampilkanDialogUpdate(Map<String, dynamic> service) {
    // ... (Kode dialog ini sudah cukup baik, tidak perlu diubah signifikan) ...
    final String id = service['_id'];
    final TextEditingController nameController = TextEditingController(text: service['name'] ?? '');
    final TextEditingController priceController = TextEditingController(text: service['price']?.toString() ?? '0');
    // TODO: Tambahkan controller lain jika perlu update deskripsi, tipe, imageUrl, dll.

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Layanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nama Layanan')),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Harga Dasar'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
               // TODO: Tambahkan field lain di sini
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updatedData = {
                  'name': nameController.text.trim(), // Trim spasi
                  'price': double.tryParse(priceController.text) ?? 0.0,
                   // TODO: Tambahkan data lain yang diupdate
                };
                 // Validasi nama tidak boleh kosong
                if (updatedData['name'].isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Nama layanan tidak boleh kosong!'), backgroundColor: Colors.red),
                    );
                    return; // Hentikan proses
                }

                try {
                  await authService.updateService(id, updatedData);
                  Navigator.of(context).pop();
                  _muatLayanan();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Layanan berhasil diperbarui!'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
  // --- END DIALOG UPDATE ---

  // --- Dialog Hapus Layanan ---
  void _tampilkanDialogHapus(String id, String serviceName) {
    // ... (Kode dialog ini sudah cukup baik, tidak perlu diubah signifikan) ...
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Layanan?'),
          content: Text('Apakah kamu yakin ingin menghapus layanan "$serviceName"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  await authService.deleteService(id);
                  Navigator.of(context).pop();
                  _muatLayanan();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Layanan "$serviceName" berhasil dihapus!'), backgroundColor: Colors.orange),
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
  // --- END DIALOG HAPUS ---

  // Helper untuk mendapatkan ikon berdasarkan tipe layanan
  IconData _getServiceIcon(String? serviceType) {
    switch (serviceType) {
      case 'Grooming': return Icons.content_cut_outlined; // Gunakan ikon outline
      case 'Boarding': return Icons.hotel_outlined;
      case 'Vaksinasi': return Icons.local_hospital_outlined;
      case 'AntarJemput': return Icons.local_shipping_outlined;
      default: return Icons.pets_outlined;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Layanan'),
        backgroundColor: Colors.deepPurple,
        // Tombol Refresh dipindah ke RefreshIndicator
      ),
      // Gunakan RefreshIndicator
      body: RefreshIndicator(
        onRefresh: _muatLayanan, // Panggil fungsi muat ulang saat ditarik
        child: FutureBuilder<List<dynamic>>(
          future: _servicesFuture,
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
              return Center(
                child: Text('Belum ada layanan di database.\nTekan tombol + untuk menambah.')
              );
            }

            List<dynamic> services = snapshot.data!;

            return ListView.separated( // Gunakan separated
              itemCount: services.length,
              separatorBuilder: (context, index) => Divider(height: 1, indent: 70), // Garis pemisah
              itemBuilder: (context, index) {
                final service = services[index];
                final String id = service['_id'] ?? ''; // Handle null ID
                final String serviceName = service['name'] ?? 'Tanpa Nama';
                final String serviceType = service['serviceType'] ?? 'Lainnya';
                final double price = (service['price'] as num?)?.toDouble() ?? 0.0; // Konversi aman

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Atur padding
                  leading: CircleAvatar( // Gunakan CircleAvatar untuk ikon
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    child: Icon(
                      _getServiceIcon(serviceType),
                      color: Colors.deepPurple,
                    ),
                  ),
                  title: Text(
                    serviceName,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
                  ),
                  subtitle: Text(
                    'Harga Dasar: ${FormatUtils.rupiah(price)}', // Gunakan FormatUtils
                    style: TextStyle(fontSize: 13, color: Colors.black54)
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blueAccent),
                        tooltip: 'Edit Layanan',
                        onPressed: () {
                          // Pastikan ID tidak kosong sebelum edit
                          if (id.isNotEmpty) {
                             _tampilkanDialogUpdate(service);
                          } else {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('Error: ID Layanan tidak valid.'), backgroundColor: Colors.red),
                             );
                          }
                        },
                         visualDensity: VisualDensity.compact, // Perkecil tombol
                      ),
                      // Tombol Delete
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Hapus Layanan',
                        onPressed: () {
                          // Pastikan ID tidak kosong sebelum hapus
                          if (id.isNotEmpty) {
                             _tampilkanDialogHapus(id, serviceName);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('Error: ID Layanan tidak valid.'), backgroundColor: Colors.red),
                             );
                          }
                        },
                         visualDensity: VisualDensity.compact, // Perkecil tombol
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      // FAB (Tambah Layanan)
      floatingActionButton: FloatingActionButton(
        onPressed: _tampilkanDialogTambah,
        child: Icon(Icons.add),
        tooltip: 'Tambah Layanan Baru',
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}