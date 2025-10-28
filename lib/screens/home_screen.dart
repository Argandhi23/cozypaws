import 'package:belajarflutter/screens/service_screen.dart';
import 'package:flutter/material.dart';
import '../models/service_data.dart';
import '../models/service.dart';
import 'detail.screens.dart';
import 'profile_screen.dart';
import 'package:getwidget/getwidget.dart';
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

  void _searchService(
    BuildContext context,
    String query,
    List<Service> services,
  ) {
    final results = services
        .where(
          (service) =>
              service.name.toLowerCase().contains(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    if (results.isNotEmpty) {
      final match = results.first;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailScreens(service: match)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Layanan tidak ditemukan")));
    }
  }

  Widget _buildPage(int index) {
    if (index == 0) {
      final List<Service> services = ServiceData.getServices();

      final List<String> categories = [
        "Semua",
        "Grooming",
        "Boarding",
        "Vaksinasi",
        "Pick-up and Drop off",
      ];

      // Filter berdasarkan nama layanan
      List<Service> filteredServices;
      if (_selectedCategory == "Semua") {
        filteredServices = services;
      } else {
        filteredServices = services.where((service) {
          final name = service.name.toLowerCase();
          if (_selectedCategory == "Grooming") {
            return name.contains("grooming") || name.contains("potong");
          } else if (_selectedCategory == "Boarding") {
            return name.contains("titip") || name.contains("boarding");
          } else if (_selectedCategory == "Vaksinasi") {
            return name.contains("vaksin") ||
                name.contains("dokter") ||
                name.contains("periksa");
          } else if (_selectedCategory == "Pick-up and Drop off") {
            return name.contains("pick") ||
                name.contains("drop") ||
                name.contains("antar") ||
                name.contains("jemput");
          }
          return false;
        }).toList();
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Gradient
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Meowcome di Cozypaws!",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),

                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.purple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: "Cari layanan...",
                              hintStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 12),
                            onSubmitted: (query) {
                              _searchService(context, query, services);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            
            // Filter kategori
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final bool isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : Colors.purple,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.purple,
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white, 
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: BorderSide(
                          color: isSelected ? Colors.purple : Colors.purple.shade100,
                        ),
                      ),
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // List layanan utama
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        service.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    title: Text(
                      service.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.purple,
                      ),
                    ),
                    subtitle: Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: Colors.black),
                    ),
                    trailing: Text(
                      "Mulai dari\n${FormatUtils.rupiah(service.price)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 8,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailScreens(service: service),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // "Mengapa Memilih Kami"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Mengapa Memilih Cozypaws?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Accordion 1
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GFAccordion(
                      title: 'Tenaga Profesional & Bersertifikat',
                      contentChild: const Text(
                        'Setiap layanan dilakukan oleh dokter hewan dan groomer berpengalaman yang memahami kebutuhan hewan peliharaan dengan baik.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple,
                          height: 1.4,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                      expandedTitleBackgroundColor: Color.fromARGB(255, 241, 222, 245),
                      collapsedIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                      expandedIcon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
                      titleBorderRadius: BorderRadius.circular(10),
                      titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  // Accordion 2
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GFAccordion(
                      title: 'Fasilitas Bersih & Nyaman',
                      contentChild: const Text(
                        'Cozypaws menyediakan ruang perawatan ber-AC, area bermain yang aman, dan peralatan steril untuk menjaga kesehatan hewan.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple,
                          height: 1.4,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                      expandedTitleBackgroundColor: Color.fromARGB(255, 241, 222, 245),
                      collapsedIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                      expandedIcon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
                      titleBorderRadius: BorderRadius.circular(10),
                      titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  // Accordion 3
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GFAccordion(
                      title: 'Layanan Lengkap dalam Satu Tempat',
                      contentChild: const Text(
                        'Dari grooming, boarding, hingga vaksinasi — semua kebutuhan hewan peliharaan tersedia di satu tempat.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple,
                          height: 1.4,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                      expandedTitleBackgroundColor: Color.fromARGB(255, 241, 222, 245),
                      collapsedIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                      expandedIcon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
                      titleBorderRadius: BorderRadius.circular(10),
                      titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  // Accordion 4
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GFAccordion(
                      title: 'Pelayanan Ramah & Cepat Tanggap',
                      contentChild: const Text(
                        'Cozypaws siap membantu dengan pelayanan cepat dan ramah agar pawrent merasa tenang.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple,
                          height: 1.4,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                      expandedTitleBackgroundColor: Color.fromARGB(255, 241, 222, 245),
                      collapsedIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                      expandedIcon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
                      titleBorderRadius: BorderRadius.circular(10),
                      titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  // Accordion 5
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GFAccordion(
                      title: 'Layanan Antar-Jemput',
                      contentChild: const Text(
                        'Cozypaws menawarkan layanan antar-jemput untuk mempermudah pawrent melakukan perawatan tanpa harus datang ke lokasi.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple,
                          height: 1.4,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                      expandedTitleBackgroundColor: Color.fromARGB(255, 241, 222, 245),
                      collapsedIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                      expandedIcon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
                      titleBorderRadius: BorderRadius.circular(10),
                      titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
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
