import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/format_utils.dart';
import '../package_manajemen_page.dart'; // Import FormatUtils


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
              title: Text('Tambah Kategori Layanan'), // Judul diubah
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedServiceType,
                      decoration: InputDecoration(labelText: 'Tipe Layanan'),
                      items: ['Grooming', 'Boarding', 'Vaksinasi', 'AntarJemput', 'Lainnya'] // Tambah 'Lainnya'
                          .map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateInDialog(() { selectedServiceType = newValue!; });
                      },
                    ),
                    TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nama Kategori (cth: Grooming)')),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Harga Dasar (cth: 45000)'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextField(controller: descController, decoration: InputDecoration(labelText: 'Deskripsi'), maxLines: 3),
                    TextField(controller: imageUrlController, decoration: InputDecoration(labelText: 'URL Gambar (Wajib diisi)')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    // Validasi
                    if (nameController.text.trim().isEmpty || 
                        descController.text.trim().isEmpty ||
                        imageUrlController.text.trim().isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Semua field wajib diisi!'), backgroundColor: Colors.red),
                       );
                       return;
                    }

                    Map<String, dynamic> newServiceData = {
                      'serviceType': selectedServiceType,
                      'name': nameController.text.trim(),
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'description': descController.text.trim(),
                      'imageUrl': imageUrlController.text.trim(),
                      'packages': [], // Paket ditambahkan nanti lewat 'Kelola Paket'
                    };

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
    // Dialog ini HANYA mengupdate info dasar (Nama, Harga, Deskripsi, URL)
    // BUKAN mengupdate 'packages'
    final String id = service['_id'];
    final TextEditingController nameController = TextEditingController(text: service['name'] ?? '');
    final TextEditingController priceController = TextEditingController(text: service['price']?.toString() ?? '0');
    final TextEditingController descController = TextEditingController(text: service['description'] ?? '');
    final TextEditingController imageUrlController = TextEditingController(text: service['imageUrl'] ?? '');
    String selectedServiceType = service['serviceType'] ?? 'Grooming';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Tambahkan StatefulBuilder
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text('Update Layanan Utama'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     DropdownButtonFormField<String>(
                      value: selectedServiceType,
                      decoration: InputDecoration(labelText: 'Tipe Layanan'),
                      items: ['Grooming', 'Boarding', 'Vaksinasi', 'AntarJemput', 'Lainnya']
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
                    TextField(controller: imageUrlController, decoration: InputDecoration(labelText: 'URL Gambar')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty || 
                        descController.text.trim().isEmpty ||
                        imageUrlController.text.trim().isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Semua field wajib diisi!'), backgroundColor: Colors.red),
                       );
                       return;
                    }

                    Map<String, dynamic> updatedData = {
                      'serviceType': selectedServiceType,
                      'name': nameController.text.trim(),
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'description': descController.text.trim(),
                      'imageUrl': imageUrlController.text.trim(),
                      // Kita tidak mengirim 'packages' di sini agar tidak terhapus
                    };

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
      },
    );
  }
  // --- END DIALOG UPDATE ---

  // --- Dialog Hapus Layanan ---
  void _tampilkanDialogHapus(String id, String serviceName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Layanan?'),
          content: Text('Apakah kamu yakin ingin menghapus layanan "$serviceName" DAN SEMUA PAKET di dalamnya?'), // Peringatan baru
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
      case 'Grooming': return Icons.content_cut_outlined;
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
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Manajemen Layanan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Gagal memuat data: ${snapshot.error}\n\nTarik ke bawah untuk mencoba lagi.', textAlign: TextAlign.center),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined, size: 80, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text('Belum ada layanan di database.'),
                    SizedBox(height: 16),
                    Text('Tekan tombol + untuk menambah kategori layanan.'),
                  ],
                )
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
                final double price = (service['price'] as num?)?.toDouble() ?? 0.0;
                // --- 2. HITUNG JUMLAH PAKET ---
                final int packageCount = (service['packages'] as List<dynamic>?)?.length ?? 0;

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
                  // --- 3. TAMPILKAN JUMLAH PAKET ---
                  subtitle: Text(
                    'Harga Dasar: ${FormatUtils.rupiah(price)}\n'
                    'Jumlah Paket: $packageCount', // <-- Tampilkan di sini
                     style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.3)
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- 4. TOMBOL BARU "KELOLA PAKET" ---
                      IconButton(
                        icon: Icon(Icons.inventory_2_outlined, color: Colors.green[700]),
                        tooltip: 'Kelola Paket (cth: Kitty Fresh)',
                        onPressed: () {
                          // Navigasi ke halaman baru
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Kirim data 'service' lengkap ke halaman baru
                              builder: (context) => PackageManagementPage(service: service),
                            ),
                          ).then((_) {
                             // Setelah kembali dari halaman paket,
                             // muat ulang data untuk update 'Jumlah Paket'
                            _muatLayanan(); 
                          });
                        },
                         visualDensity: VisualDensity.compact,
                      ),
                      // ---------------------------------

                      // Tombol Edit (Edit Layanan Utama)
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blueAccent),
                        tooltip: 'Edit Layanan (Nama, Harga Dasar)',
                        onPressed: () {
                          if (id.isNotEmpty) {
                             _tampilkanDialogUpdate(service);
                          } else { /* ... (error snackbar) ... */ }
                        },
                         visualDensity: VisualDensity.compact, 
                      ),
                      // Tombol Delete (Hapus Layanan Utama)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Hapus Kategori Layanan',
                        onPressed: () {
                          if (id.isNotEmpty) {
                             _tampilkanDialogHapus(id, serviceName);
                          } else { /* ... (error snackbar) ... */ }
                        },
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
      // FAB (Tambah Layanan)
      floatingActionButton: FloatingActionButton(
        onPressed: _tampilkanDialogTambah,
        child: Icon(Icons.add),
        tooltip: 'Tambah Kategori Layanan Baru', // Tooltip diubah
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}