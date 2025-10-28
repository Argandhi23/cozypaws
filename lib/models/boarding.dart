import 'service.dart';
import 'service_packages.dart';

class Boarding extends Service {
  String _breed; // ras kucing
  int _days; // jumlah hari penitipan
  bool _includeFood; // apakah termasuk makanan
  List<ServicePackage> _packages;

  Boarding({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.packages,
    required super.imageUrl,
    required String breed,
    required int days,
    bool includeFood = true,
  }) : _breed = breed,
       _days = days,
       _includeFood = includeFood,
       _packages = packages;

  // Getter
  String get breed => _breed;
  int get days => _days;
  bool get includeFood => _includeFood;
  List<ServicePackage> get packages => _packages;

  // Setter
  set breed(String newBreed) {
    if (newBreed.isNotEmpty) {
      _breed = newBreed;
    }
  }

  set days(int newDays) {
    if (newDays > 0) {
      _days = newDays;
    }
  }

  set includeFood(bool value) {
    _includeFood = value;
  }

  set packages(List<ServicePackage> newPackages) {
    if (newPackages.isNotEmpty) {
      _packages = newPackages;
    }
  }

  @override
  String toString() {
    return 'Boarding(${super.toString()}, breed: $_breed, days: $_days, includeFood: $_includeFood, packages: $_packages)';
  }
}