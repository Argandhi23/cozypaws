import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Sesuaikan path
import '../../utils/format_utils.dart'; // Untuk format Rupiah & Tanggal

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({Key? key}) : super(key: key);

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final AuthService authService = AuthService();
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _muatPesanan();
  }

  // Fungsi untuk memuat (atau me-refresh) data pesanan
  Future<void> _muatPesanan() async { // Tambahkan async
    setState(() {
      _ordersFuture = authService.getOrders();
    });
  }

  // Mendapatkan warna chip berdasarkan status
  Color _getStatusColor(String? status) {
    // ... (Kode ini sudah bagus) ...
    switch (status) {
      case 'Menunggu Konfirmasi': return Colors.orange.shade100;
      case 'Dikonfirmasi': return Colors.blue.shade100;
      case 'Selesai': return Colors.green.shade100;
      case 'Dibatalkan': return Colors.red.shade100;
      default: return Colors.grey.shade200;
    }
  }

  // Mendapatkan warna teks chip berdasarkan status
  Color _getStatusTextColor(String? status) {
    // ... (Kode ini sudah bagus) ...
     switch (status) {
      case 'Menunggu Konfirmasi': return Colors.orange.shade800;
      case 'Dikonfirmasi': return Colors.blue.shade800;
      case 'Selesai': return Colors.green.shade800;
      case 'Dibatalkan': return Colors.red.shade800;
      default: return Colors.grey.shade800;
    }
  }

  // Dialog untuk mengedit status pesanan
  void _tampilkanDialogUpdateStatus(Map<String, dynamic> order) {
    // ... (Kode dialog ini sudah cukup bagus) ...
    String currentStatus = order['status'] ?? 'Menunggu Konfirmasi'; 
    final String orderId = order['_id']; 
    
    final List<String> statusOptions = [
      'Menunggu Konfirmasi', 'Dikonfirmasi', 'Selesai', 'Dibatalkan'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text('Update Status Pesanan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pesanan: ${order['packageName'] ?? 'N/A'}"),
                  Text("Pemesan: ${order['ownerName'] ?? 'N/A'}"),
                  SizedBox(height: 20),
                  Text("Pilih status baru:"),
                  DropdownButton<String>(
                    value: currentStatus,
                    isExpanded: true,
                    items: statusOptions.map((String value) {
                      return DropdownMenuItem<String>( value: value, child: Text(value),);
                    }).toList(),
                    onChanged: (String? newValue) {
                      setStateInDialog(() { currentStatus = newValue!; });
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
                    try {
                      await authService.updateOrderStatus(orderId, currentStatus);
                      Navigator.of(context).pop();
                      _muatPesanan(); // Refresh list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Status pesanan berhasil diubah!'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal update status: $e'), backgroundColor: Colors.red),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Pesanan'),
        backgroundColor: Colors.deepPurple,
        // Tombol Refresh dipindah ke RefreshIndicator
      ),
      // Gunakan RefreshIndicator
      body: RefreshIndicator(
        onRefresh: _muatPesanan, // Panggil fungsi muat ulang saat ditarik
        child: FutureBuilder<List<dynamic>>(
          future: _ordersFuture,
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
              return Center(child: Text('Belum ada pesanan yang masuk.'));
            }

            final List<dynamic> orders = snapshot.data!;

            return ListView.separated( // Gunakan separated untuk garis pemisah
              itemCount: orders.length,
              separatorBuilder: (context, index) => Divider(height: 1), // Garis pemisah
              itemBuilder: (context, index) {
                final order = orders[index];
                final user = order['userId'];
                String userName = (user is Map) ? (user['nama'] ?? 'User N/A') : 'User Dihapus';
                String userEmail = (user is Map) ? (user['email'] ?? 'N/A') : ''; // Ambil email juga

                // Format tanggal dengan lebih aman
                String formattedDate = "Tanggal N/A";
                if (order['bookingDate'] != null) {
                  try {
                    DateTime bookingDate = DateTime.parse(order['bookingDate']);
                    // Gunakan FormatUtils jika ada, atau format manual
                    formattedDate = FormatUtils.tanggal(bookingDate); // Asumsi FormatUtils punya fungsi tanggal
                    // formattedDate = "${bookingDate.day}-${bookingDate.month}-${bookingDate.year}"; // Manual
                  } catch(e) {
                    formattedDate = "Format Tgl Salah";
                  }
                }
                
                // Format harga dengan FormatUtils
                String formattedPrice = FormatUtils.rupiah(order['price']?.toDouble() ?? 0.0);

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Atur padding
                  // Ikon berdasarkan status? Atau biarkan simpel
                  // leading: Icon(Icons.receipt_outlined), 
                  title: Text(
                    order['packageName'] ?? 'Tanpa Nama Paket', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                  ),
                  subtitle: Padding( // Beri padding di bawah title
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gunakan RichText untuk label tebal
                        RichText(text: TextSpan(style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13), children: [
                          TextSpan(text: 'Pemesan: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: "${order['ownerName'] ?? 'N/A'} ($userName)"),
                        ])),
                        RichText(text: TextSpan(style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13), children: [
                          TextSpan(text: 'Kucing: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: "${order['catName'] ?? 'N/A'}"),
                        ])),
                         RichText(text: TextSpan(style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13), children: [
                          TextSpan(text: 'Tanggal: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: formattedDate),
                        ])),
                         RichText(text: TextSpan(style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13), children: [
                          TextSpan(text: 'Kontak: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: "${order['phone'] ?? 'N/A'}"),
                        ])),
                        SizedBox(height: 6),
                        Row( // Letakkan harga dan status sejajar
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text(
                               formattedPrice,
                               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 13),
                             ),
                             Chip(
                                label: Text(order['status'] ?? 'N/A'),
                                backgroundColor: _getStatusColor(order['status']),
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusTextColor(order['status'])
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                visualDensity: VisualDensity.compact, // Perkecil chip
                              ),
                           ],
                         ),
                      ],
                    ),
                  ),
                  trailing: IconButton( // Tombol edit status
                    icon: Icon(Icons.edit_note, color: Colors.blueAccent),
                    tooltip: 'Ubah Status Pesanan',
                    onPressed: () => _tampilkanDialogUpdateStatus(order),
                     visualDensity: VisualDensity.compact, // Perkecil tombol ikon
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