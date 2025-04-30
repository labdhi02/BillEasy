import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => _products;

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return [];
    return _products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
