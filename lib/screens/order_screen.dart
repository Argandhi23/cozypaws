import 'package:flutter/material.dart';
import '../services/auth_service.dart'; 
import '../models/user.dart'; // Import model User (dan Pet)
import '../utils/format_utils.dart';

class OrderScreen extends StatefulWidget {
  final String packageName;
  final double price;

  const OrderScreen({
    super.key,
    required this.packageName,
    required this.price,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false; 

  final AuthService _authService = AuthService();
  User? _currentUser;
  
  // --- 🔽 STATE BARU UNTUK HEWAN 🔽 ---
  String? _selectedPetValue; // Menyimpan ID pet atau "TAMBAH_BARU"
  bool _isLainnyaSelected = false; 

  // Controller untuk form hewan baru
  final _newPetNameController = TextEditingController();
  final _newPetJenisController = TextEditingController();
  final _newPetRasController = TextEditingController();
  String _newPetGender = 'Tidak Diketahui';
  // --- -------------------------------- ---

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); 
  }

  // Mengambil data user TERBARU (termasuk list pets) dari server
  Future<void> _loadCurrentUser() async {
    // Panggil getFreshUserProfile agar daftar pets selalu terbaru
    final user = await _authService.getFreshUserProfile(); 
    if (user != null) {
      setState(() {
        _currentUser = user;
        _ownerController.text = user.name; 
        
        if (user.telepon != null && user.telepon!.isNotEmpty) {
           _phoneController.text = user.telepon!;
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Gagal memuat data pengguna.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Fungsi untuk menyimpan pesanan ke MongoDB via API
  Future<void> _saveOrderToMongo() async {
    // Validasi form utama
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Harap lengkapi semua data.")),
      );
      return;
    }
    if (_selectedDate == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Harap pilih tanggal booking.")),
      );
      return;
    }
    if (_currentUser == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User tidak terdeteksi. Silakan login ulang.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true); 

    String catNameForOrder;

    try {
      // --- 🔽 LOGIKA BARU: SIMPAN HEWAN JIKA PERLU 🔽 ---
      if (_isLainnyaSelected) {
        // 1. Validasi form hewan baru
        final newNama = _newPetNameController.text.trim();
        final newJenis = _newPetJenisController.text.trim();
        if (newNama.isEmpty || newJenis.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.red, content: Text("Nama dan Jenis Hewan Baru wajib diisi.")),
           );
           setState(() => _isLoading = false);
           return;
        }
        
        // 2. Buat objek data hewan baru
        Map<String, dynamic> newPetData = {
          'nama': newNama,
          'jenis': newJenis,
          'ras': _newPetRasController.text.trim(),
          'gender': _newPetGender,
          // 'umur' bisa ditambahkan jika perlu
        };

        // 3. Panggil API addPet
        final newPet = await _authService.addPet(newPetData);
        if (newPet == null) {
          throw Exception("Gagal menyimpan hewan baru ke profil.");
        }
        
        catNameForOrder = newPet['nama']; // Gunakan nama hewan yang baru disimpan

      } else {
        // Jika memilih dari dropdown, cari namanya
        final selectedPet = _currentUser!.pets.firstWhere((p) => p.id == _selectedPetValue);
        catNameForOrder = selectedPet.nama;
      }
      // --- ----------------------------------------- ---

      // 4. Buat data pesanan
      Map<String, dynamic> newOrderData = {
        'userId': _currentUser!.id, 
        'packageName': widget.packageName,
        'price': widget.price,
        'ownerName': _ownerController.text,
        'catName': catNameForOrder, // <-- Gunakan nama hewan yang sudah pasti
        'bookingDate': _selectedDate!.toIso8601String(),
        'phone': _phoneController.text,
      };

      // 5. Panggil API createOrder
      await _authService.createOrder(newOrderData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.purple,
          content: Text("Pesanan ${widget.packageName} berhasil dibuat!"),
        ),
      );
      Navigator.pop(context); // Kembali ke halaman detail

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Gagal membuat pesanan: $e"),
        ),
      );
    } finally {
       if (mounted) {
         setState(() => _isLoading = false); // Hentikan loading
       }
    }
  }

  // Fungsi untuk dekorasi input (tidak berubah)
  InputDecoration _inputDecoration(String label, {bool isEnabled = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isEnabled ? Colors.purple : Colors.grey[700], 
        fontSize: 13
      ),
      filled: true,
      fillColor: isEnabled ? Colors.white : Colors.grey[200], 
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: isEnabled ? Colors.purpleAccent : Colors.grey[400]!, width: 0.6),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: isEnabled ? Colors.deepPurple : Colors.grey[400]!, width: 1.4),
      ),
    );
  }
  
  // --- 🔽 WIDGET BARU UNTUK FORM HEWAN 🔽 ---
  Widget _buildNewPetForm() {
    return Visibility(
      visible: _isLainnyaSelected,
      child: Container(
        margin: const EdgeInsets.only(top: 14.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurple[100]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.deepPurple[50]!.withOpacity(0.3)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tambah Hewan Baru", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 12),
            TextFormField(
              controller: _newPetNameController,
              decoration: _inputDecoration("Nama Hewan Baru *"),
              style: const TextStyle(fontSize: 13),
              validator: (val) {
                if (_isLainnyaSelected && (val == null || val.isEmpty)) {
                  return "Nama hewan baru wajib diisi";
                }
                return null;
              },
            ),
            SizedBox(height: 14),
            TextFormField(
              controller: _newPetJenisController,
              decoration: _inputDecoration("Jenis (Kucing/Anjing) *"),
              style: const TextStyle(fontSize: 13),
               validator: (val) {
                if (_isLainnyaSelected && (val == null || val.isEmpty)) {
                  return "Jenis hewan wajib diisi";
                }
                return null;
              },
            ),
             SizedBox(height: 14),
            TextFormField(
              controller: _newPetRasController,
              decoration: _inputDecoration("Ras (Opsional)"),
              style: const TextStyle(fontSize: 13),
            ),
             SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _newPetGender,
              decoration: _inputDecoration("Gender (Opsional)"),
              items: ['Jantan', 'Betina', 'Tidak Diketahui'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() { _newPetGender = newValue!; });
              },
            ),
          ],
        ),
      ),
    );
  }
  // --- --------------------------------- ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FC),
      appBar: AppBar(
         title: const Text(
          "Pesanan Anda",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
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
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  // Judul Paket & Harga
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.packageName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatUtils.rupiah(widget.price), 
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // NAMA PEMILIK (Otomatis)
                  TextFormField(
                    controller: _ownerController,
                    decoration: _inputDecoration("Nama Pemilik", isEnabled: false), 
                    readOnly: true, 
                    style: const TextStyle(fontSize: 13, color: Colors.grey), 
                    validator: (val) => val == null || val.isEmpty
                        ? "Nama pemilik wajib diisi"
                        : null,
                  ),
                  const SizedBox(height: 14),
                  
                  // DROPDOWN HEWAN
                  DropdownButtonFormField<String>(
                    value: _selectedPetValue,
                    decoration: _inputDecoration("Pilih Hewan Peliharaan *"),
                    hint: Text("Pilih dari hewan Anda..."),
                    items: [
                      ...(_currentUser?.pets ?? []).map((Pet pet) {
                        return DropdownMenuItem<String>(
                          value: pet.id, // Gunakan ID pet sebagai value
                          child: Text(pet.nama),
                        );
                      }).toList(),
                      DropdownMenuItem<String>(
                        value: "TAMBAH_BARU",
                        child: Text(
                          "Lainnya (Tambah Hewan Baru)...",
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPetValue = newValue;
                        if (newValue == "TAMBAH_BARU") {
                          _isLainnyaSelected = true;
                        } else {
                          _isLainnyaSelected = false;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Harap pilih hewan peliharaan';
                      }
                      return null;
                    },
                  ),
                  
                  // FORM HEWAN BARU (Kondisional)
                  _buildNewPetForm(), // <-- Panggil widget form baru

                  const SizedBox(height: 14), // <-- Ini spasi yang memperbaiki UI

                  // TANGGAL BOOKING
                  InkWell(
                    onTap: () async {
                      if (_isLoading) return; 
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 1)),
                        firstDate: DateTime.now().add(Duration(days: 1)),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() { _selectedDate = pickedDate; });
                      }
                    },
                    child: InputDecorator(
                      decoration: _inputDecoration("Tanggal Booking *"),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? "Pilih tanggal"
                                : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                            style: TextStyle(
                              fontSize: 13,
                              color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.purple, size: 18),
                        ],
                      ),
                    ),
                  ),
                  // Validator manual untuk tanggal (tidak berubah)
                  ValueListenableBuilder(
                    valueListenable: ValueNotifier(_selectedDate), 
                    builder: (context, value, child) {
                      if (_selectedDate == null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Text( "Tanggal booking wajib diisi", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        );
                      }
                      return SizedBox.shrink();
                    }
                  ),
                  const SizedBox(height: 14),

                  // NOMOR TELEPON
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration("Nomor Telepon *"), 
                    style: const TextStyle(fontSize: 13),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty
                        ? "Nomor telepon wajib diisi"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // METODE PEMBAYARAN
                  InputDecorator(
                    decoration: _inputDecoration("Metode Pembayaran", isEnabled: false),
                    child: const Text(
                      "Meowney On Spot (Cozy Paws)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple),
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // TOMBOL KONFIRMASI
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveOrderToMongo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: _isLoading 
                          ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text(
                              "Konfirmasi Pesanan",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}