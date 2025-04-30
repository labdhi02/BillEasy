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
  final TextEditingController _nameController = TextEditingController();
  List<Product> _searchResults = [];
  final List<Product> _selectedProducts = [];
  final Map<Product, int> _quantities = {};
  String _customerName = '';
  bool _showBill = false;

  double _calculateCGST(Product product, int quantity) {
    return (product.price * product.gstRate / 100 * quantity) / 2;
  }

  double _calculateSGST(Product product, int quantity) {
    return (product.price * product.gstRate / 100 * quantity) / 2;
  }

  double _calculateTotalPrice() {
    double total = 0;
    _quantities.forEach((product, quantity) {
      double basePrice = product.price * quantity;
      double cgst = _calculateCGST(product, quantity);
      double sgst = _calculateSGST(product, quantity);
      total += basePrice + cgst + sgst;
    });
    return total;
  }

  Widget _buildBillView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Customer Name: $_customerName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text('Bill Details:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _quantities.length,
            itemBuilder: (context, index) {
              Product product = _quantities.keys.elementAt(index);
              int quantity = _quantities[product]!;
              double basePrice = product.price * quantity;
              double cgst = _calculateCGST(product, quantity);
              double sgst = _calculateSGST(product, quantity);

              return Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${product.name} × $quantity'),
                      Text('Base Price: ₹${basePrice.toStringAsFixed(2)}'),
                      Text(
                          'CGST (${product.gstRate / 2}%): ₹${cgst.toStringAsFixed(2)}'),
                      Text(
                          'SGST (${product.gstRate / 2}%): ₹${sgst.toStringAsFixed(2)}'),
                      Text(
                          'Total: ₹${(basePrice + cgst + sgst).toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
          Divider(),
          Text('Grand Total: ₹${_calculateTotalPrice().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_showBill) ...[
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
                              _quantities[product] =
                                  (_quantities[product] ?? 0) + 1;
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
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter customer name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Text('Selected Products',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _selectedProducts[index];
                      return Card(
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                              'Price: ₹${product.price.toStringAsFixed(2)}\nGST: ${product.gstRate}%'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (_quantities[product] != null &&
                                        _quantities[product]! > 1) {
                                      _quantities[product] =
                                          _quantities[product]! - 1;
                                    }
                                  });
                                },
                              ),
                              Text('${_quantities[product] ?? 1}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _quantities[product] =
                                        (_quantities[product] ?? 1) + 1;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    _selectedProducts.removeAt(index);
                                    _quantities.remove(product);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter customer name')),
                      );
                      return;
                    }
                    setState(() {
                      _customerName = _nameController.text;
                      _showBill = true;
                    });
                  },
                  child: Text('Generate Bill'),
                ),
              ],
            ] else ...[
              Expanded(child: _buildBillView()),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showBill = false;
                    _nameController.clear();
                    _selectedProducts.clear();
                    _quantities.clear();
                  });
                },
                child: Text('Create New Bill'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
