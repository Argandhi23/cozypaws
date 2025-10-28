class ServicePackage {
  String _name;
  double _price;
  List<String> _facilities;

  ServicePackage({
    required String name,
    required double price,
    required List<String> facilities, 
  })  : _name = name,
        _price = price,
        _facilities = facilities;

  // Getter
  String get name => _name;
  double get price => _price;
  List<String> get facilities => _facilities;

  // Setter
  set name(String newName) => _name = newName;
  
  set price(double newPrice) {
    if (newPrice > 0) {
      _price = newPrice;
    }
  }
  
  set facilities(List<String> newFacilities) => _facilities = newFacilities; 
}
