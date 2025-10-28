import 'service.dart';
import 'service_packages.dart';

class Grooming extends Service {
  String _breed;   // ras kucing
  int _duration;   // durasi menit
  List<ServicePackage> _packages;

  Grooming({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.imageUrl,
    required super.packages,
    required String breed,
    required int duration,
  })  : _breed = breed,
       _duration = duration,
       _packages = packages;

  // Getter
  String get breed => _breed;
  int get duration => _duration;
  List<ServicePackage> get packages => _packages;

  // Setter
  set breed(String newBreed) {
    if (newBreed.isNotEmpty) {
      _breed = newBreed;
    }
  }

  set duration(int newDuration) {
    if (newDuration > 0) {
      _duration = newDuration;
    }
  }

  set packages(List<ServicePackage> newPackages) {
    if (newPackages.isNotEmpty) {
      _packages = newPackages;
    }
  }

  @override
 String toString() {
    return 'Grooming(${super.toString()}, breed: $_breed, duration: $_duration menit, packages: $_packages)';
  }
}
