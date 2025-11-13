import 'service.dart';
import 'service_packages.dart';

/// Model ini digunakan untuk menangani semua tipe layanan
/// yang tidak memiliki model spesifik (cth: Grooming, Boarding).
/// Ini memungkinkan kita menampilkan layanan "Lainnya" seperti "Suntik".
class GenericService extends Service {
  
  GenericService({
    required String id,
    required String name,
    required double price,
    required String description,
    required String imageUrl,
    required List<ServicePackage> packages,
  }) : super(
          id: id,
          name: name,
          price: price,
          description: description,
          imageUrl: imageUrl,
          packages: packages,
        );

  // Kita tidak perlu method tambahan apa pun,
  // karena kita hanya butuh properti dasar dari 'Service'.
}