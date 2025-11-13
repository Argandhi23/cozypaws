import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart'; // Kita butuh model Pet dari file ini

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({Key? key}) : super(key: key);

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false; // Hanya untuk loading sementara

  // State utama sekarang adalah Future
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    // Panggil API baru untuk mengambil data user + pets
    _userFuture = _authService.getFreshUserProfile();
  }

  // Fungsi untuk memuat (atau me-refresh) data pengguna dan hewan
  Future<void> _muatDataHewan() async {
    // Set state untuk memicu FutureBuilder lagi
    setState(() {
      _userFuture = _authService.getFreshUserProfile(); 
    });
  }

  // --- Dialog untuk TAMBAH atau UPDATE Hewan ---
  void _tampilkanDialogPet({Pet? pet}) {
    bool isUpdate = pet != null;
    String dialogTitle = isUpdate ? 'Update Data Hewan' : 'Tambah Hewan Baru';

    final TextEditingController namaController = TextEditingController(text: isUpdate ? pet.nama : '');
    final TextEditingController jenisController = TextEditingController(text: isUpdate ? pet.jenis : '');
    final TextEditingController rasController = TextEditingController(text: isUpdate ? pet.ras : '');
    final TextEditingController umurController = TextEditingController(text: isUpdate ? pet.umur?.toString() : '');
    String currentGender = isUpdate ? (pet.gender ?? 'Tidak Diketahui') : 'Tidak Diketahui';
    
    final List<String> genderOptions = ['Jantan', 'Betina', 'Tidak Diketahui'];
    
    // State loading khusus untuk tombol dialog
    bool isDialogLoading = false;

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
                    TextField(controller: namaController, decoration: InputDecoration(labelText: 'Nama Hewan *')),
                    SizedBox(height: 16),
                    TextField(controller: jenisController, decoration: InputDecoration(labelText: 'Jenis (Kucing/Anjing) *')),
                     SizedBox(height: 16),
                    TextField(controller: rasController, decoration: InputDecoration(labelText: 'Ras (Opsional)')),
                    SizedBox(height: 16),
                    TextField(
                      controller: umurController,
                      decoration: InputDecoration(labelText: 'Umur (Opsional)'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: currentGender,
                      decoration: InputDecoration(labelText: 'Gender (Opsional)'),
                      items: genderOptions.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateInDialog(() { currentGender = newValue!; });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDialogLoading ? null : () => Navigator.of(context).pop(), 
                  child: Text('Batal')
                ),
                ElevatedButton(
                  // Nonaktifkan tombol saat loading
                  onPressed: isDialogLoading ? null : () async {
                    String nama = namaController.text.trim();
                    String jenis = jenisController.text.trim();
                    if (nama.isEmpty || jenis.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Nama dan Jenis wajib diisi!'), backgroundColor: Colors.red),
                       );
                       return;
                    }
                    
                    setStateInDialog(() => isDialogLoading = true); // Mulai loading

                    Map<String, dynamic> dataHewan = {
                      'nama': nama, 'jenis': jenis, 'ras': rasController.text.trim(),
                      'umur': int.tryParse(umurController.text), 'gender': currentGender,
                    };

                    try {
                      if (isUpdate) {
                        await _authService.updatePet(pet!.id!, dataHewan);
                      } else {
                        await _authService.addPet(dataHewan);
                      }
                      
                      Navigator.of(context).pop();
                      
                      // Panggil refresh data dari server
                      _muatDataHewan(); 
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Data hewan berhasil disimpan!'), backgroundColor: Colors.green),
                      );

                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                       if(mounted) {
                         setStateInDialog(() => isDialogLoading = false); // Selesai loading
                       }
                    }
                  },
                  child: isDialogLoading 
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // --- Dialog Hapus Hewan ---
  void _tampilkanDialogHapus(Pet pet) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Hewan?'),
          content: Text('Apakah kamu yakin ingin menghapus "${pet.nama}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  await _authService.deletePet(pet.id!);
                  Navigator.of(context).pop();
                  
                  // Refresh data dari server
                  _muatDataHewan(); 
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hewan "${pet.nama}" berhasil dihapus.'), backgroundColor: Colors.orange),
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
        title: Text('Hewan Peliharaan Saya'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _muatDataHewan,
        child: FutureBuilder<User?>(
          future: _userFuture,
          builder: (context, snapshot) {
            
            // Tampilkan loading awal
            if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
              // Jika ini adalah refresh, tampilkan list lama di belakang loading
              if (snapshot.data != null && snapshot.data!.pets.isNotEmpty) {
                 // Lanjutkan ke build list di bawah
              } else {
                 return Center(child: CircularProgressIndicator());
              }
            }
            
            if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
               return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text("Gagal memuat data user."));
            }

            // Ambil daftar pets dari data user yang sudah di-refresh
            final List<Pet> pets = snapshot.data!.pets; 

            if (pets.isEmpty) {
              return Center( // Tampilan jika tidak ada hewan
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 80, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text('Kamu belum mendaftarkan hewan peliharaan.'),
                     SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Tambah Hewan Pertama'),
                      onPressed: () => _tampilkanDialogPet(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              );
            }

            // Tampilkan daftar hewan
            return ListView.separated(
              itemCount: pets.length,
              separatorBuilder: (context, index) => Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final pet = pets[index];

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink.withOpacity(0.1),
                    child: Icon(
                      pet.jenis.toLowerCase() == 'kucing' ? Icons.pets : Icons.pets_outlined, // Ganti ikon jika bukan kucing
                      color: Colors.pinkAccent,
                    ),
                  ),
                  title: Text(pet.nama, style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text("${pet.jenis} - ${pet.ras ?? 'N/A'} - ${pet.gender ?? ''}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blueAccent),
                        tooltip: 'Edit Hewan',
                        onPressed: () => _tampilkanDialogPet(pet: pet),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Hapus Hewan',
                        onPressed: () => _tampilkanDialogHapus(pet),
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
      floatingActionButton: FutureBuilder<User?>( // Tampilkan FAB berdasarkan Future
         future: _userFuture,
         builder: (context, snapshot) {
           // Hanya tampilkan tombol tambah jika data sudah ada DAN list tidak kosong
           if (snapshot.hasData && snapshot.data!.pets.isNotEmpty) {
             return FloatingActionButton(
                onPressed: () => _tampilkanDialogPet(),
                child: Icon(Icons.add),
                tooltip: 'Tambah Hewan Baru',
                backgroundColor: Colors.deepPurple,
              );
           }
           // Jika list kosong, tombol tambah sudah ada di tengah layar
           return SizedBox.shrink(); 
         }
      ),
    );
  }
}