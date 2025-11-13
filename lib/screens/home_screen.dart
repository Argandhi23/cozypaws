import 'package:belajarflutter/screens/service_screen.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

// --- IMPORT MODELS ---
import '../models/service.dart';
import '../models/grooming.dart';
import '../models/boarding.dart';
import '../models/vaksinasi.dart';
import '../models/antarjemput.dart';
import '../models/service_packages.dart';
import '../models/generic_service.dart'; // <-- Pastikan ini ada

// --- IMPORT UNTUK API ---
import '../services/auth_service.dart';
// ---

import 'detail.screens.dart';
import 'profile_screen.dart';
import '../utils/format_utils.dart';

class HomeScreen extends StatefulWidget {
  final String userNameOrEmail;

  const HomeScreen({super.key, required this.userNameOrEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = "Semua";

  final AuthService authService = AuthService();
  late Future<List<Service>> _servicesFuture;
  
  // Kontroler untuk SearchAnchor
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _loadServicesFromMongo();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadServicesFromMongo() {
    setState(() {
      _servicesFuture = _fetchAndParseServices();
    });
  }

  // --- 🔽 FUNGSI PARSING DENGAN PERBAIKAN '?? 0' 🔽 ---
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
        String imageUrl = (item['imageUrl'] != null && item['imageUrl'].isNotEmpty)
            ? item['imageUrl']
            : 'https://placehold.co/400x300/EADCFB/7E57C2?text=Cozypaws';

        if (serviceType == 'Grooming') {
          servicesList.add(Grooming(
            id: id, name: name, price: price, description: description, imageUrl: imageUrl, 
            breed: item['breed'] ?? 'Semua Jenis',
            duration: (item['duration'] as num?)?.toInt() ?? 0, // <-- FIX DI SINI
            packages: packages,
          ));
        } else if (serviceType == 'Boarding') {
          servicesList.add(Boarding(
            id: id, name: name, price: price, description: description, imageUrl: imageUrl, 
            breed: item['breed'] ?? 'Semua Jenis', 
            days: (item['days'] as num?)?.toInt() ?? 0, // <-- FIX DI SINI
            includeFood: item['includeFood'] ?? false, 
            packages: packages
          ));
        } else if (serviceType == 'Vaksinasi') {
          servicesList.add(Vaksinasi(
            id: id, name: name, price: price, description: description, imageUrl: imageUrl, 
            vaccineType: item['vaccineType'] ?? 'Umum', 
            breed: item['breed'] ?? 'Semua Jenis', 
            packages: packages
          ));
        } else if (serviceType == 'AntarJemput') {
          servicesList.add(AntarJemput(
            id: id, name: name, price: price, description: description, imageUrl: imageUrl, 
            area: item['area'] ?? 'Dalam Kota', 
            distance: (item['distance'] as num?)?.toInt() ?? 0, // <-- FIX DI SINI
            packages: packages
          ));
        } else {
          // Perbaikan untuk 'Suntek', 'Beleh', dll.
          servicesList.add(GenericService(
            id: id, name: name, price: price, description: description, imageUrl: imageUrl, 
            packages: packages
          ));
        }
      }
      return servicesList;
    } catch (e) {
      debugPrint("Error di _fetchAndParseServices: $e");
      throw Exception('Gagal memuat & mem-parsing data layanan: $e');
    }
  }
  // --- -------------------------------------------- ---

  Widget _buildPage(int index) {
    if (index == 0) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Service>>(
              future: _servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(height: 500, child: const Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return Container(height: 500, child: Center(child: Text('Gagal memuat data: ${snapshot.error}')));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(height: 500, child: const Center(child: Text('Belum ada layanan tersedia.')));
                }

                final List<Service> services = snapshot.data!;
                
                final List<String> categories = ["Semua", ...services.map((s) => s.name).toList()];
                final uniqueCategories = categories.toSet().toList();

                List<Service> filteredServices;
                if (_selectedCategory == "Semua") {
                  filteredServices = services;
                } else {
                  filteredServices = services.where((service) => service.name == _selectedCategory).toList();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hai, ${widget.userNameOrEmail}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Meowcome di Cozypaws!",
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                          
                          // --- SEARCHANCHOR (PENCARIAN LIVE) ---
                          SearchAnchor(
                            searchController: _searchController,
                            builder: (BuildContext context, SearchController controller) {
                              return SearchBar(
                                controller: controller,
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                backgroundColor: MaterialStateProperty.all(Colors.white),
                                elevation: MaterialStateProperty.all(0.0),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                hintText: "Cari layanan...",
                                hintStyle: MaterialStateProperty.all(
                                  const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                textStyle: MaterialStateProperty.all(
                                   const TextStyle(fontSize: 12, color: Colors.black)
                                ),
                                leading: const Icon(Icons.search, color: Colors.purple),
                                onTap: () { controller.openView(); },
                                onChanged: (_) { controller.openView(); },
                              );
                            },
                            suggestionsBuilder: (BuildContext context, SearchController controller) {
                              final String query = controller.text;
                              if (query.isEmpty) {
                                return [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text('Ketik untuk mencari layanan (cth: "suntik", "vaksin", "boarding")...'),
                                  )
                                ];
                              }

                              final List<Service> results = services.where((service) =>
                                  service.name.toLowerCase().contains(query.toLowerCase()) ||
                                  service.description.toLowerCase().contains(query.toLowerCase())
                              ).toList();

                              if (results.isEmpty) {
                                return [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text('Tidak ada layanan ditemukan untuk "$query"'),
                                  )
                                ];
                              }

                              return List<ListTile>.generate(results.length, (int index) {
                                final service = results[index];
                                return ListTile(
                                  title: Text(service.name),
                                  subtitle: Text(service.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(service.imageUrl),
                                  ),
                                  onTap: () {
                                    controller.closeView(service.name);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreens(service: service),
                                      ),
                                    );
                                  },
                                );
                              });
                            },
                          ),
                          // --- --------------------------------------- ---
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // KATEGORI (Dinamis)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: uniqueCategories.map((category) {
                            final bool isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  category,
                                  style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.purple),
                                ),
                                selected: isSelected,
                                selectedColor: Colors.purple,
                                backgroundColor: Colors.white,
                                checkmarkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: BorderSide(color: isSelected ? Colors.purple : Colors.purple.shade100),
                                ),
                                onSelected: (_) {
                                  setState(() { _selectedCategory = category; });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // LIST LAYANAN
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                service.imageUrl,
                                width: 100, height: 100, fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) =>
                                    progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 100, height: 100, color: Colors.grey[200],
                                      child: const Icon(Icons.pets_outlined, size: 40, color: Colors.grey),
                                    ),
                              ),
                            ),
                            title: Text(
                              service.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.purple),
                            ),
                            subtitle: Text(
                              service.description,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Colors.black),
                            ),
                            trailing: Text(
                              "Mulai dari\n${FormatUtils.rupiah(service.price)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 10),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DetailScreens(service: service)),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // ACCORDION (Dikembalikan)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Mengapa Memilih Cozypaws?",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _accordion('Tenaga Profesional & Bersertifikat', 'Setiap layanan dilakukan oleh dokter hewan dan groomer berpengalaman...'),
                          _accordion('Fasilitas Bersih & Nyaman', 'Cozypaws menyediakan ruang perawatan ber-AC...'),
                          _accordion('Layanan Lengkap dalam Satu Tempat', 'Dari grooming, boarding, hingga vaksinasi...'),
                          _accordion('Pelayanan Ramah & Cepat Tanggap', 'Cozypaws siap membantu dengan pelayanan cepat...'),
                          _accordion('Layanan Antar-Jemput', 'Cozypaws menawarkan layanan antar-jemput...'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    } else if (index == 1) {
      return const ServiceScreen();
    } else {
      return const ProfileScreen();
    }
  }

  // Helper method untuk Accordion
  Widget _accordion(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: GFAccordion(
        title: title,
        contentChild: Text(content, style: const TextStyle(fontSize: 10, color: Colors.purple, height: 1.4)),
        textStyle: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w500),
        expandedTitleBackgroundColor: const Color.fromARGB(255, 241, 222, 245),
        collapsedIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
        expandedIcon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
        titleBorderRadius: BorderRadius.circular(10),
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 20,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        iconSize: 20,
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Service"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}