import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await _productService.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _productService.addProduct(product);
    await loadProducts();
  }

  List<Product> searchProducts(String query) {
    return _products.where((product) => product.name.contains(query)).toList();
  }
}
