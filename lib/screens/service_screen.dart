import 'package:flutter/material.dart';

// === IMPORT MODEL ===
import '../models/service.dart';
import '../models/grooming.dart';
import '../models/boarding.dart';
import '../models/vaksinasi.dart';
import '../models/antarjemput.dart';
import '../models/service_packages.dart';

// === IMPORT UNTUK API ===
import '../services/auth_service.dart';

// === IMPORT TAMBAHAN ===
import 'order_screen.dart';
import '../utils/format_utils.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final AuthService authService = AuthService();
  late Future<List<Service>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _loadServicesFromMongo();
  }

  void _loadServicesFromMongo() {
    setState(() {
      _servicesFuture = _fetchAndParseServices();
    });
  }

  Future<List<Service>> _fetchAndParseServices() async {
    try {
      final List<dynamic> mongoData = await authService.getServices();
      List<Service> servicesList = [];

      for (var item in mongoData) {
        if (item == null || item is! Map<String, dynamic>) continue;

        List<ServicePackage> packages = [];
        if (item['packages'] is List) {
          packages = (item['packages'] as List<dynamic>)
              .map((pkg) => ServicePackage(
                    name: pkg['name'] ?? 'Paket Tanpa Nama',
                    price: (pkg['price'] as num?)?.toDouble() ?? 0.0,
                    facilities: List<String>.from(pkg['facilities'] ?? []),
                  ))
              .toList();
        }

        String serviceType = item['serviceType'] ?? 'Lainnya';
        String id = item['_id'] ?? UniqueKey().toString();
        String name = item['name'] ?? 'Layanan Tanpa Nama';
        double price = (item['price'] as num?)?.toDouble() ?? 0.0;
        String description = item['description'] ?? 'Tanpa Deskripsi';
        String imageUrl =
            (item['imageUrl'] != null && item['imageUrl'].isNotEmpty)
                ? item['imageUrl']
                : 'https://placehold.co/400x300/EADCFB/7E57C2?text=Cozypaws';

        if (serviceType == 'Grooming') {
          servicesList.add(Grooming(
            id: id,
            name: name,
            price: price,
            description: description,
            imageUrl: imageUrl,
            breed: item['breed'] ?? 'Semua Jenis',
            duration: (item['duration'] as num?)?.toInt() ?? 0,
            packages: packages,
          ));
        } else if (serviceType == 'Boarding') {
          servicesList.add(Boarding(
            id: id,
            name: name,
            price: price,
            description: description,
            imageUrl: imageUrl,
            breed: item['breed'] ?? 'Semua Jenis',
            days: (item['days'] as num?)?.toInt() ?? 0,
            includeFood: item['includeFood'] ?? false,
            packages: packages,
          ));
        } else if (serviceType == 'Vaksinasi') {
          servicesList.add(Vaksinasi(
            id: id,
            name: name,
            price: price,
            description: description,
            imageUrl: imageUrl,
            vaccineType: item['vaccineType'] ?? 'Umum',
            breed: item['breed'] ?? 'Semua Jenis',
            packages: packages,
          ));
        } else if (serviceType == 'AntarJemput') {
          servicesList.add(AntarJemput(
            id: id,
            name: name,
            price: price,
            description: description,
            imageUrl: imageUrl,
            area: item['area'] ?? 'Dalam Kota',
            distance: (item['distance'] as num?)?.toInt() ?? 0,
            packages: packages,
          ));
        } else {
          servicesList.add(Service(
            id: id,
            name: name,
            price: price,
            description: description,
            imageUrl: imageUrl,
            packages: packages,
          ));
        }
      }

      return servicesList;
    } catch (e) {
      debugPrint("Error di _fetchAndParseServices: $e");
      throw Exception('Gagal memuat & mem-parsing data layanan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Semua Paw-ket",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
      body: FutureBuilder<List<Service>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat data: ${snapshot.error.toString()}'));
          }

          // Data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Belum ada layanan yang tersedia.'));
          }

          // Data berhasil dimuat
          final services = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var service in services) ...[
                  Center(
                    child: Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // List package
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: service.packages.length,
                    itemBuilder: (context, index) {
                      final pkg = service.packages[index];
                      return Card(
                        color: Colors.white,
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.4),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            pkg.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: pkg.facilities.map((facility) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ",
                                      style: TextStyle(fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      facility,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                FormatUtils.rupiah(pkg.price),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 26,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF48FB1),
                                      Color(0xFF7E57C2)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderScreen(
                                          packageName: pkg.name,
                                          price: pkg.price,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Pesan",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
