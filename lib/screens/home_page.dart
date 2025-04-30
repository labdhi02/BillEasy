import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Product'),
        content: SingleChildScrollView(
          child: _AddProductForm(
            onSubmit: (product) {
              Provider.of<ProductProvider>(context, listen: false)
                  .addProduct(product);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.products;
        return Stack(
          children: [
            products.isEmpty
                ? Center(
                    child: Text(
                      'No products added yet',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    padding: EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                              'Price: ₹${product.price.toStringAsFixed(2)}\nGST: ${product.gstRate}%'),
                        ),
                      );
                    },
                  ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _addProduct,
                child: Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddProductForm extends StatefulWidget {
  final Function(Product) onSubmit;

  const _AddProductForm({required this.onSubmit});

  @override
  State<_AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<_AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _gstController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        gstRate: double.parse(_gstController.text),
      );
      widget.onSubmit(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Product Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter product name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _gstController,
            decoration: InputDecoration(labelText: 'GST Rate (%)'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter GST rate';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Add Product'),
          ),
        ],
      ),
    );
  }
}
