import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; 
import '../../utils/format_utils.dart'; 

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({Key? key}) : super(key: key);

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final AuthService authService = AuthService();
  late Future<List<dynamic>> _ordersFuture;

  // State untuk menyimpan daftar staf
  List<dynamic> _staffList = [];
  bool _isStaffLoading = true;

  @override
  void initState() {
    super.initState();
    _muatDataHalaman(); // Panggil fungsi baru
  }

  // Fungsi baru untuk memuat pesanan DAN staf
  Future<void> _muatDataHalaman() async {
    setState(() {
      _isStaffLoading = true; // Set loading staf
      // Mulai fetch pesanan
      _ordersFuture = authService.getOrders(); 
    });
    
    try {
      // Sambil pesanan di-fetch, ambil juga daftar staf
      final staff = await authService.getStaff();
      if (mounted) {
        setState(() {
          _staffList = staff;
          _isStaffLoading = false; // Selesai loading staf
        });
      }
    } catch (e) {
       if (mounted) {
         setState(() { _isStaffLoading = false; });
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data staf: $e'), backgroundColor: Colors.red),
         );
       }
    }
  }

  // Fungsi refresh (pull-to-refresh)
  Future<void> _muatPesanan() async {
    // Fungsi refresh sekarang harus memuat keduanya
    await _muatDataHalaman();
  }

  // (Fungsi _getStatusColor dan _getStatusTextColor tidak berubah)
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Menunggu Konfirmasi': return Colors.orange.shade100;
      case 'Dikonfirmasi': return Colors.blue.shade100;
      case 'Selesai': return Colors.green.shade100;
      case 'Dibatalkan': return Colors.red.shade100;
      default: return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String? status) {
     switch (status) {
      case 'Menunggu Konfirmasi': return Colors.orange.shade800;
      case 'Dikonfirmasi': return Colors.blue.shade800;
      case 'Selesai': return Colors.green.shade800;
      case 'Dibatalkan': return Colors.red.shade800;
      default: return Colors.grey.shade800;
    }
  }

  // --- DIALOG UPDATE (DIROMBAK UNTUK STAF) ---
  void _tampilkanDialogUpdateStatus(Map<String, dynamic> order) {
    String currentStatus = order['status'] ?? 'Menunggu Konfirmasi';
    final String orderId = order['_id'];
    
    // Cek apakah staf sudah ditugaskan
    String? currentStaffId; 
    if (order['assignedStaff'] != null && order['assignedStaff'] is Map) {
      currentStaffId = order['assignedStaff']['_id'];
    }
    
    final List<String> statusOptions = ['Menunggu Konfirmasi', 'Dikonfirmasi', 'Selesai', 'Dibatalkan'];

    showDialog(
      context: context,
      builder: (context) {
        // Gunakan StatefulBuilder agar dropdown bisa di-update
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            
            // Jika data staf masih loading saat dialog dibuka
            if (_isStaffLoading) {
              return AlertDialog(
                title: Text('Update Status Pesanan'),
                content: Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator(), SizedBox(height: 10), Text("Memuat data staf...")]
                )),
              );
            }

            return AlertDialog(
              title: Text('Update Status Pesanan'),
              content: SingleChildScrollView( // Agar bisa di-scroll
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pesanan: ${order['packageName'] ?? 'N/A'}"),
                    Text("Pemesan: ${order['ownerName'] ?? 'N/A'}"),
                    SizedBox(height: 20),
                    
                    // 1. Dropdown Status
                    Text("Pilih status baru:", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: currentStatus,
                      isExpanded: true,
                      items: statusOptions.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateInDialog(() { currentStatus = newValue!; });
                      },
                    ),
                    SizedBox(height: 20),

                    // 2. Dropdown Staf
                    Text("Tugaskan ke Staf:", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String?>(
                      value: currentStaffId, // Bisa null
                      isExpanded: true,
                      hint: Text("Pilih staf..."),
                      // Buat daftar item dari _staffList
                      items: [
                        // Opsi "Belum Ditugaskan"
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text("Belum Ditugaskan", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
                        ),
                        // Tambahkan semua staf dari list
                        ..._staffList.map((staf) {
                          return DropdownMenuItem<String?>(
                            value: staf['_id'] as String?,
                            child: Text(staf['nama'] ?? 'Staf Error'),
                          );
                        }).toList()
                      ],
                      onChanged: (String? newValue) {
                        setStateInDialog(() {
                          currentStaffId = newValue; // Simpan ID staf yang dipilih
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Panggil API updateOrderStatus dengan 3 argumen
                      await authService.updateOrderStatus(orderId, currentStatus, currentStaffId);
                      
                      Navigator.of(context).pop();
                      _muatPesanan(); // Refresh list (sudah memuat staf juga)
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Muat Ulang Data',
            onPressed: _muatPesanan, // Panggil fungsi refresh
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _muatPesanan,
        child: FutureBuilder<List<dynamic>>(
          future: _ordersFuture,
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
               return Center(child: Text('Belum ada pesanan yang masuk.'));
            }

            final List<dynamic> orders = snapshot.data!;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final user = order['userId'];
                
                // Ambil data staf yang di-populate
                final staff = order['assignedStaff']; 
                String staffName = "Belum Ditugaskan";
                if (staff is Map) {
                  staffName = staff['nama'] ?? 'Nama Staf Error';
                }

                String userName = (user is Map) ? user['nama'] : 'User Dihapus';
                
                // Format tanggal
                String formattedDate = "Tgl N/A";
                if (order['bookingDate'] != null) {
                  try {
                    DateTime bookingDate = DateTime.parse(order['bookingDate']);
                    formattedDate = FormatUtils.tanggal(bookingDate); // Gunakan util
                  } catch(e) { /* biarkan N/A */ }
                }

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(order['packageName'] ?? 'Tanpa Nama Paket', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pemesan: ${order['ownerName']} ($userName)"),
                          Text("Kucing: ${order['catName']}"),
                          Text("Tgl Booking: $formattedDate"),
                          Text("Kontak: ${order['phone'] ?? 'N/A'}"),
                          SizedBox(height: 5),
                          // Tampilkan Staf yang Ditugaskan
                          Text(
                            "Penangan: $staffName", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 13,
                              color: staffName == "Belum Ditugaskan" ? Colors.grey[600] : Colors.deepPurple[700]
                            ),
                          ),
                          SizedBox(height: 5),
                          Chip(
                            label: Text(order['status'] ?? 'N/A'),
                            backgroundColor: _getStatusColor(order['status'] ?? ''),
                            labelStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getStatusTextColor(order['status'] ?? '')
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          )
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit_calendar_outlined, color: Colors.blueAccent),
                      tooltip: 'Ubah Status & Penugasan',
                      onPressed: () => _tampilkanDialogUpdateStatus(order),
                    ),
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