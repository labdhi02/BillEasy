import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot querySnapshot = await _productsCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          gstRate: (data['gstRate'] ?? 0.0).toDouble(),
        );
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _productsCollection.add({
        'name': product.name,
        'price': product.price,
        'gstRate': product.gstRate,
      });
    } catch (e) {
      print('Error adding product: $e');
      throw e;
    }
  }
}
