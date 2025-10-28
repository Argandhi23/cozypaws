import 'service_packages.dart';

class Service {
  final String _id;
  String _name;
  double _price;
  String _description;
  String _imageUrl;
  List<ServicePackage> packages;

  Service({
    required String id,
    required String name,
    required double price,
    required String description,
    required String imageUrl,
    this.packages = const [],
  }) : _id = id,
       _name = name,
       _price = price,
       _description = description,
       _imageUrl = imageUrl;

  // Getter
  String get id => _id;
  String get name => _name;
  double get price => _price;
  String get description => _description;
  String get imageUrl => _imageUrl;

  // Setter dengan validasi
  set name(String newName) {
    if (newName.isNotEmpty) {
      _name = newName;
    }
  }

  set price(double newPrice) {
    if (newPrice > 0) {
      _price = newPrice;
    }
  }

  set description(String newDesc) {
    if (newDesc.isNotEmpty) {
      _description = newDesc;
    }
  }

   set imageUrl(String newUrl) {
    if (newUrl.isNotEmpty) {
      _imageUrl = newUrl;
    }
  }

  // Metode tambahan (contoh polimorfisme)
  String getDisplayPrice() {
    return 'Rp ${_price.toStringAsFixed(0)}';
  }
}
