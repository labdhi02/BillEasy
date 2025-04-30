import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  List<Product> _selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for products...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (query) {
              setState(() {
                _searchResults =
                    Provider.of<ProductProvider>(context, listen: false)
                        .searchProducts(query);
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                return Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      'Price: ₹${product.price.toStringAsFixed(2)}\nGST: ${product.gstRate}%',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        setState(() {
                          _selectedProducts.add(product);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedProducts.isNotEmpty) ...[
            Divider(),
            Text(
              'Selected Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = _selectedProducts[index];
                  return Card(
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        'Price: ₹${product.price.toStringAsFixed(2)}\nGST: ${product.gstRate}%',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            _selectedProducts.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
