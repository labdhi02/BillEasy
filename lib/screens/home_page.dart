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
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).loadProducts());
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Product'),
        content: SingleChildScrollView(
          child: _AddProductForm(
            onSubmit: (product) async {
              await Provider.of<ProductProvider>(context, listen: false)
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
  final _nameFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _gstFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _gstController.dispose();
    _nameFocusNode.dispose();
    _priceFocusNode.dispose();
    _gstFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Unfocus all fields before submitting
    _nameFocusNode.unfocus();
    _priceFocusNode.unfocus();
    _gstFocusNode.unfocus();

    if (_formKey.currentState!.validate()) {
      try {
        final product = Product(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text),
          gstRate: double.parse(_gstController.text),
        );
        widget.onSubmit(product);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      }
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
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              labelText: 'Product Name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _priceFocusNode.requestFocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter product name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            focusNode: _priceFocusNode,
            decoration: InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(),
              prefixText: '₹',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _gstFocusNode.requestFocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _gstController,
            focusNode: _gstFocusNode,
            decoration: InputDecoration(
              labelText: 'GST Rate (%)',
              border: OutlineInputBorder(),
              suffixText: '%',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitForm(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter GST rate';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
            ),
            child: Text('Add Product'),
          ),
        ],
      ),
    );
  }
}
