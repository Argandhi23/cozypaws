import 'package:flutter/material.dart';
// Import AuthService untuk panggil API
import '../services/auth_service.dart'; 
// Import model User untuk mendapatkan ID
import '../models/user.dart'; 
import '../utils/format_utils.dart';
// Hapus import SharedPreferences dan dart:convert

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
  final _catNameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false; // Tambahkan state loading

  // Buat instance AuthService
  final AuthService _authService = AuthService();
  User? _currentUser; // Untuk menyimpan data user yang sedang login

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Ambil data user saat halaman dibuka
  }

  // Fungsi untuk mengambil data user yang login (kita butuh ID-nya)
  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
        // Isi otomatis nama pemilik
        _ownerController.text = user.name; 
        // TODO: Jika model User punya 'telepon', isi juga _phoneController
        // if (user.telepon != null) {
        //   _phoneController.text = user.telepon!;
        // }
      });
    } else {
      // Jika tidak ada user (seharusnya tidak mungkin jika sudah login)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Tidak dapat menemukan data pengguna.'), backgroundColor: Colors.red),
      );
    }
  }

  // --- FUNGSI INI DIGANTI TOTAL ---
  // Fungsi untuk menyimpan pesanan ke MongoDB via API
  Future<void> _saveOrderToMongo() async {
    // Validasi tambahan sebelum kirim
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Harap lengkapi semua data."),
        ),
      );
      return;
    }
     if (_selectedDate == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Harap pilih tanggal booking."),
        ),
      );
      return;
    }
    if (_currentUser == null || _currentUser!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User tidak terdeteksi. Silakan login ulang.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true); // Mulai loading

    // Buat data pesanan baru sesuai Model Order.js di backend
    Map<String, dynamic> newOrderData = {
      'userId': _currentUser!.id, // ID user yang sedang login
      'packageName': widget.packageName,
      'price': widget.price,
      'ownerName': _ownerController.text,
      'catName': _catNameController.text,
      'bookingDate': _selectedDate!.toIso8601String(), // Kirim sebagai ISO String (standar)
      'phone': _phoneController.text,
      // 'status' akan otomatis 'Menunggu Konfirmasi' (default di backend)
    };

    try {
      // Panggil API createOrder
      await _authService.createOrder(newOrderData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.purple,
          content: Text(
            "Pesanan ${widget.packageName} berhasil dibuat!",
          ),
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
  // --- BATAS PERUBAHAN ---


  // Fungsi untuk dekorasi input (tidak berubah)
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.purple, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.purpleAccent, width: 0.6),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FC),
      appBar: AppBar(
        // ... (AppBar tidak berubah) ...
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
                // ... (Dekorasi container tidak berubah) ...
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
                  // ... (Bagian Judul Paket & Harga tidak berubah) ...
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

                  TextFormField(
                    controller: _ownerController,
                    decoration: _inputDecoration("Nama Pemilik"),
                    style: const TextStyle(fontSize: 13),
                    validator: (val) => val == null || val.isEmpty
                        ? "Nama pemilik wajib diisi"
                        : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _catNameController,
                    decoration: _inputDecoration("Nama Meow"),
                    style: const TextStyle(fontSize: 13),
                    validator: (val) => val == null || val.isEmpty
                        ? "Nama meow wajib diisi"
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // --- Logika Tanggal Booking Diperbaiki ---
                  InkWell(
                    onTap: () async {
                      // Jangan biarkan pilih tanggal jika sedang loading
                      if (_isLoading) return; 
                      
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 1)), // Mulai besok
                        firstDate: DateTime.now().add(Duration(days: 1)), // Tidak bisa hari ini
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: _inputDecoration("Tanggal Booking"),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? "Pilih tanggal"
                                : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                            style: TextStyle(
                              fontSize: 13,
                              color: _selectedDate == null
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                          ),
                          const Icon(Icons.calendar_today,
                              color: Colors.purple, size: 18),
                        ],
                      ),
                    ),
                  ),
                  // Validator manual untuk tanggal
                  ValueListenableBuilder(
                    valueListenable: ValueNotifier(_selectedDate), 
                    builder: (context, value, child) {
                      // Kita hanya tampilkan error jika user mencoba submit (dihandle di tombol)
                      // Tapi kita bisa beri tanda visual jika belum diisi
                      if (_selectedDate == null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            "Tanggal booking wajib diisi",
                            // Style dibuat lebih halus agar tidak terlalu agresif
                            style: TextStyle(color: Colors.grey[600], fontSize: 12), 
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration("Nomor Telepon"),
                    style: const TextStyle(fontSize: 13),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty
                        ? "Nomor telepon wajib diisi"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  InputDecorator(
                    decoration: _inputDecoration("Metode Pembayaran"),
                    child: const Text(
                      "Meowney On Spot (Cozy Paws)",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                    ),
                  ),
                  const SizedBox(height: 28),

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
                        // Nonaktifkan tombol saat loading
                        onPressed: _isLoading ? null : () async {
                          // Panggil fungsi baru
                          await _saveOrderToMongo();
                        },
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