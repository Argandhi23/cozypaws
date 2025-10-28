import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/service_data.dart';
import '../models/service_packages.dart';
import 'order_screen.dart';
import '../utils/format_utils.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  // ignore: unused_element
  List<ServicePackage> _getAllPackages(List<Service> services) {
    final List<ServicePackage> allPackages = [];
    for (var s in services) {
      allPackages.addAll(s.packages);
    }
    return allPackages;
  }

  @override
  Widget build(BuildContext context) {
    final services = ServiceData.getServices();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Semua Paw-ket",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan per kategori service
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

              // Daftar packages untuk service tersebut
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
                              const Text("• ", style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  facility,
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
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
                              colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)],
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
                        )
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
      ),
    );
  }
}