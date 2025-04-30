class Product {
  final String? id;
  final String name;
  final double price;
  final double gstRate;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.gstRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'gstRate': gstRate,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      gstRate: (map['gstRate'] ?? 0.0).toDouble(),
    );
  }
}
