import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 
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
  final _catNameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;

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

    // Fungsi untuk menyimpan pesanan ke SharedPreferences
  Future<void> _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil daftar pesanan lama (kalau ada)
    List<String> existingOrders = prefs.getStringList('orders') ?? [];

    // Buat pesanan baru dalam bentuk map
    Map<String, dynamic> newOrder = {
      'packageName': widget.packageName,
      'price': widget.price,
      'owner': _ownerController.text,
      'catName': _catNameController.text,
      'date': _selectedDate != null
          ? "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}"
          : "",
      'phone': _phoneController.text,
    };

    // Tambahkan ke list lama
    existingOrders.add(jsonEncode(newOrder));

    // Simpan kembali ke SharedPreferences
    await prefs.setStringList('orders', existingOrders);
  }

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

                  InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
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
                  if (_selectedDate == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 6),
                      child: Text(
                        "Tanggal booking wajib diisi",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedDate != null) {
                            await _saveOrder(); //simpan pesanan

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.purple,
                                content: Text(
                                  "Pesanan ${widget.packageName} berhasil disimpan!",
                                ),
                              ),
                            );
                            Navigator.pop(context); // kembali ke halaman sebelumnya
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.purple,
                                content: Text(
                                  "Lengkapi semua data sebelum konfirmasi",
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
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