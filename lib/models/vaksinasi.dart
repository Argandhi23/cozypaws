import 'service.dart';
import 'service_packages.dart';

class Vaksinasi extends Service {
  String _vaccineType; // tipe vaksin
  String _breed; // ras kucing
  List<ServicePackage> _packages;

  Vaksinasi({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.imageUrl,
    required super.packages,
    required String vaccineType,
    required String breed,
  }) : _vaccineType = vaccineType,
       _breed = breed,
       _packages = packages;

  // Getter
  String get vaccineType => _vaccineType;
  String get breed => _breed;
  List<ServicePackage> get packages => _packages;

  // Setter
  set vaccineType(String newType) {
    if (newType.isNotEmpty) {
      _vaccineType = newType;
    }
  }

  set breed(String newBreed) {
    if (newBreed.isNotEmpty) {
      _breed = newBreed;
    }
  }

  set packages(List<ServicePackage> newPackages) {
    if (newPackages.isNotEmpty) {
      _packages = newPackages;
    }
  }

  @override
  String toString() {
    return 'Vaksinasi(${super.toString()}, vaccineType: $_vaccineType, breed: $_breed)';
  }
}
