import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/entities/product.dart';
import 'presentation/screens/pos/cart_item.dart';
import 'presentation/screens/pos/cart_item_widget.dart';

void main() {
  runApp(const ProviderScope(child: TestCartApp()));
}

class TestCartApp extends StatelessWidget {
  const TestCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Cart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TestCartScreen(),
    );
  }
}

class TestCartScreen extends StatelessWidget {
  const TestCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Cart Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: getSampleCartItems().length,
              itemBuilder: (context, index) {
                final item = getSampleCartItems()[index];
                return CartItemWidget(
                  item: item,
                  onQuantityChanged: (productId, quantity) {
                    // No-op for test
                  },
                  onRemove: (productId) {
                    // No-op for test
                  },
                  onDiscountChanged: (productId, discount) {
                    // No-op for test
                  },
                );
              },
            ),
          ),
          
          // Bottom Section
          Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Customer Selection
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              value: null,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                              hint: const Text('Walk-in Customer'),
                              items: const [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Walk-in Customer'),
                                ),
                              ],
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {},
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Subtotal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 14),
                      ),
                      const Text(
                        'TK 2200.00',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Total
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'TK 2200.00',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Payment Method
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.payment, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPaymentMethodButton('Cash', true),
                          _buildPaymentMethodButton('Card', false),
                          _buildPaymentMethodButton('bKash', false),
                          _buildPaymentMethodButton('Nagad', false),
                          _buildPaymentMethodButton('Rocket', false),
                          _buildPaymentMethodButton('Advance', false),
                          _buildPaymentMethodButton('Due', false),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Checkout Button
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodButton(String label, bool isSelected) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

List<CartItem> getSampleCartItems() {
  return [
    CartItem(
      product: Product(
        id: 1,
        name: 'Ohi',
        sku: 'OHI001',
        barcode: '123456789',
        sellingPrice: 500.00,
        costPrice: 400.00,
        stockQuantity: 10,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      quantity: 1,
      discount: 0.0,
    ),
    CartItem(
      product: Product(
        id: 2,
        name: 'Biscuit',
        sku: 'BIS001',
        barcode: '223456789',
        sellingPrice: 60.00,
        costPrice: 40.00,
        stockQuantity: 50,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      quantity: 1,
      discount: 0.0,
    ),
    CartItem(
      product: Product(
        id: 3,
        name: 'Water',
        sku: 'WAT001',
        barcode: '323456789',
        sellingPrice: 10.00,
        costPrice: 5.00,
        stockQuantity: 100,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      quantity: 1,
      discount: 0.0,
    ),
    CartItem(
      product: Product(
        id: 4,
        name: 'Mojo',
        sku: 'MOJ001',
        barcode: '423456789',
        sellingPrice: 20.00,
        costPrice: 15.00,
        stockQuantity: 30,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      quantity: 1,
      discount: 0.0,
    ),
    CartItem(
      product: Product(
        id: 5,
        name: 'Noodles',
        sku: 'NOO001',
        barcode: '523456789',
        sellingPrice: 60.00,
        costPrice: 45.00,
        stockQuantity: 40,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      quantity: 1,
      discount: 0.0,
    ),
    CartItem(
      product: Product(
        id: 6,
        name: 'Rice',
        sku: 'RIC001',
        barcode: '623456789',
        sellingPrice: 1550.00,
        costPrice: 1400.00,
        stockQuantity: 25,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      quantity: 1,
      discount: 0.0,
    ),
  ];
}
