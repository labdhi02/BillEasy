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

  // Theme colors
  final Color _primaryColor = const Color(0xFF1565C0);
  final Color _lightBgColor = const Color(0xFFE3F2FD);
  final Color _inputFillColor = Colors.grey[100]!;

  // GST calculation functions
  double _calculateCGST(Product product, int quantity) =>
      (product.price * product.gstRate / 100 * quantity) / 2;

  double _calculateSGST(Product product, int quantity) =>
      (product.price * product.gstRate / 100 * quantity) / 2;

  double _calculateTotalPrice() {
    double total = 0;
    _quantities.forEach((product, quantity) {
      double basePrice = product.price * quantity;
      total += basePrice +
          _calculateCGST(product, quantity) +
          _calculateSGST(product, quantity);
    });
    return total;
  }

  // Reusable widgets
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(10)),
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(borderRadius: borderRadius),
        filled: true,
        fillColor: _inputFillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isInSearch) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Price: ₹${product.price.toStringAsFixed(2)}\nGST: ${product.gstRate}%',
        ),
        trailing: isInSearch
            ? IconButton(
                icon: Icon(Icons.add_shopping_cart, color: _primaryColor),
                onPressed: () {
                  setState(() {
                    if (!_selectedProducts.contains(product)) {
                      _selectedProducts.add(product);
                    }
                    _quantities[product] = (_quantities[product] ?? 0) + 1;
                  });
                },
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: _primaryColor),
                    onPressed: () {
                      setState(() {
                        if (_quantities[product]! > 1) {
                          _quantities[product] = _quantities[product]! - 1;
                        }
                      });
                    },
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _lightBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_quantities[product] ?? 1}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: _primaryColor),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: _primaryColor),
                    onPressed: () {
                      setState(() {
                        _quantities[product] = (_quantities[product] ?? 1) + 1;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    onPressed: () {
                      setState(() {
                        _selectedProducts.remove(product);
                        _quantities.remove(product);
                      });
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBillItem(Product product, int quantity) {
    double basePrice = product.price * quantity;
    double cgst = _calculateCGST(product, quantity);
    double sgst = _calculateSGST(product, quantity);
    double total = basePrice + cgst + sgst;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('× $quantity',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Base Price:'),
                Text('₹${basePrice.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CGST (${product.gstRate / 2}%):'),
                Text('₹${cgst.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SGST (${product.gstRate / 2}%):'),
                Text('₹${sgst.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: _primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _lightBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: _primaryColor, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _customerName,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Bill Details',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _quantities.length,
            itemBuilder: (context, index) {
              Product product = _quantities.keys.elementAt(index);
              int quantity = _quantities[product]!;
              return _buildBillItem(product, quantity);
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                  '₹${_calculateTotalPrice().toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showBill ? 'Bill Details' : 'Create Bill',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_showBill) ...[
              _buildTextField(
                controller: _searchController,
                hintText: 'Search for products...',
                icon: Icons.search,
              ),
              const SizedBox(height: 12),
              if (_searchResults.isNotEmpty) ...[
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Search Results',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _primaryColor)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) =>
                              _buildProductCard(_searchResults[index], true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_selectedProducts.isNotEmpty) ...[
                if (_searchResults.isNotEmpty) const SizedBox(height: 16),
                Expanded(
                  flex: _searchResults.isEmpty ? 3 : 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shopping_cart, color: _primaryColor),
                          const SizedBox(width: 8),
                          Text(
                              'Selected Products (${_selectedProducts.length})',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _primaryColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _selectedProducts.length,
                          itemBuilder: (context, index) => _buildProductCard(
                              _selectedProducts[index], false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Enter customer name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter customer name'),
                          backgroundColor: Colors.red[400],
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _customerName = _nameController.text;
                      _showBill = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Generate Bill',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
              if (_selectedProducts.isEmpty &&
                  _searchController.text.isNotEmpty &&
                  _searchResults.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No products found',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
            ] else ...[
              Expanded(child: _buildBillView()),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showBill = false;
                    _nameController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Create New Bill',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize search when the widget is created
    _searchController.addListener(() {
      setState(() {
        _searchResults = _searchController.text.isEmpty
            ? []
            : Provider.of<ProductProvider>(context, listen: false)
                .searchProducts(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
