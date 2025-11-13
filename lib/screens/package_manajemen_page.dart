import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/format_utils.dart';
import 'dart:convert'; // Untuk encode/decode list fasilitas

class PackageManagementPage extends StatefulWidget {
  final Map<String, dynamic> service; // Menerima data service lengkap

  const PackageManagementPage({Key? key, required this.service}) : super(key: key);

  @override
  State<PackageManagementPage> createState() => _PackageManagementPageState();
}

class _PackageManagementPageState extends State<PackageManagementPage> {
  final AuthService _authService = AuthService();
  // State untuk menyimpan daftar paket saat ini
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Salin daftar paket dari 'widget.service' ke state
    if (widget.service['packages'] != null) {
      // Pastikan semua item adalah Map<String, dynamic>
      _packages = List<Map<String, dynamic>>.from(widget.service['packages']);
    }
  }

  // --- Dialog untuk TAMBAH atau UPDATE Paket ---
  void _tampilkanDialogPaket({Map<String, dynamic>? paket, int? index}) {
    bool isUpdate = paket != null;
    String dialogTitle = isUpdate ? 'Update Paket' : 'Tambah Paket Baru';

    // Isi controller
    final TextEditingController namaController = TextEditingController(text: isUpdate ? paket['name'] : '');
    final TextEditingController priceController = TextEditingController(text: isUpdate ? paket['price']?.toString() : '');
    // Konversi List<String> fasilitas menjadi satu String (dipisah koma)
    final TextEditingController facilitiesController = TextEditingController(
      text: isUpdate ? (paket['facilities'] as List<dynamic>).join(', ') : ''
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: namaController, decoration: InputDecoration(labelText: 'Nama Paket (cth: Kitty Fresh)')),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Harga Paket (cth: 85000)'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: facilitiesController,
                  decoration: InputDecoration(
                    labelText: 'Fasilitas (pisahkan dengan koma)',
                    hintText: 'Sisir Bulu, Potong Kuku, ...'
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
            ElevatedButton(
              onPressed: () {
                // Ambil data dari form
                String nama = namaController.text.trim();
                double harga = double.tryParse(priceController.text) ?? 0;
                // Konversi String (dipisah koma) kembali menjadi List<String>
                List<String> fasilitas = facilitiesController.text.split(',')
                    .map((f) => f.trim()) // Hapus spasi
                    .where((f) => f.isNotEmpty) // Hapus item kosong
                    .toList();
                
                if (nama.isEmpty || harga == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Nama dan Harga paket tidak boleh kosong!'), backgroundColor: Colors.red),
                  );
                  return;
                }

                // Buat data paket baru
                Map<String, dynamic> dataPaket = {
                  'name': nama,
                  'price': harga,
                  'facilities': fasilitas,
                };

                // Update state
                setState(() {
                  if (isUpdate) {
                    _packages[index!] = dataPaket; // Ganti paket lama
                  } else {
                    _packages.add(dataPaket); // Tambah paket baru
                  }
                });
                
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Simpan Paket'),
            ),
          ],
        );
      },
    );
  }

  // --- Fungsi untuk HAPUS Paket ---
  void _hapusPaket(int index) {
    setState(() {
      _packages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paket dihapus (jangan lupa Simpan Perubahan)'), backgroundColor: Colors.orange),
    );
  }

  // --- Fungsi untuk SIMPAN SEMUA PERUBAHAN ke Database ---
  Future<void> _simpanPerubahanKeDB() async {
    setState(() => _isLoading = true);
    
    // Siapkan data untuk dikirim
    // Kita HANYA mengirim array 'packages' yang baru
    Map<String, dynamic> dataToUpdate = {
      'packages': _packages 
    };

    try {
      await _authService.updateService(widget.service['_id'], dataToUpdate);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Semua perubahan paket berhasil disimpan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke halaman 'Manajemen Layanan'
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
       if (mounted) {
         setState(() => _isLoading = false);
       }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kelola Paket: ${widget.service['name']}"),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Tombol SIMPAN PERUBAHAN
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isLoading ? null : _simpanPerubahanKeDB,
              child: _isLoading 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    "SIMPAN", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
            ),
          )
        ],
      ),
      body: _packages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text('Belum ada paket untuk layanan ini.'),
                  SizedBox(height: 16),
                  Text('Tekan tombol + untuk menambah paket pertama.'),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _packages.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final paket = _packages[index];
                final fasilitas = (paket['facilities'] as List<dynamic>).join(', ');
                
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(paket['name'] ?? 'Tanpa Nama', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(FormatUtils.rupiah(paket['price']?.toDouble() ?? 0.0), style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      Text("Fasilitas: $fasilitas", style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis,),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blueAccent),
                        tooltip: 'Edit Paket',
                        onPressed: () => _tampilkanDialogPaket(paket: paket, index: index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Hapus Paket',
                        onPressed: () => _hapusPaket(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tampilkanDialogPaket(), // Panggil dialog tambah
        child: Icon(Icons.add),
        tooltip: 'Tambah Paket Baru',
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}