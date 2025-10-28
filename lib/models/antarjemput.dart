import 'service.dart';
import 'service_packages.dart';

class AntarJemput extends Service {
  String _area; // area layanan antar jemput
  int _distance; // jarak dalam km
  List<ServicePackage> _packages;

  AntarJemput({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.imageUrl,
    required super.packages,
    required String area,
    required int distance,
  })  : _area = area,
        _distance = distance,
        _packages = packages;

  // Getter
  String get area => _area;
  int get distance => _distance;
  List<ServicePackage> get packages => _packages;

  // Setter
  set area(String newArea) {
    if (newArea.isNotEmpty) {
      _area = newArea;
    }
  }

  set distance(int newDistance) {
    if (newDistance > 0) {
      _distance = newDistance;
    }
  }

  set packages(List<ServicePackage> newPackages) {
    if (newPackages.isNotEmpty) {
      _packages = newPackages;
    }
  }

  @override
  String toString() {
    return 'AntarJemput(${super.toString()}, area: $_area, distance: $_distance km, packages: $_packages)';
  }
}
