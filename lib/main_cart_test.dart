import 'package:flutter/material.dart';

void main() {
  runApp(const CartTestApp());
}

class CartTestApp extends StatelessWidget {
  const CartTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cart Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CartTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CartTestScreen extends StatelessWidget {
  const CartTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          // Cart Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _sampleItems.length,
              itemBuilder: (context, index) {
                final item = _sampleItems[index];
                return CartItemWidget(
                  name: item.name,
                  price: item.price,
                  quantity: item.quantity,
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
                    children: const [
                      Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
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

class CartItem {
  final String name;
  final double price;
  final int quantity;

  CartItem({required this.name, required this.price, required this.quantity});
}

final List<CartItem> _sampleItems = [
  CartItem(name: 'Ohi', price: 500.0, quantity: 1),
  CartItem(name: 'Biscuit', price: 60.0, quantity: 1),
  CartItem(name: 'Water', price: 10.0, quantity: 1),
  CartItem(name: 'Mojo', price: 20.0, quantity: 1),
  CartItem(name: 'Noodles', price: 60.0, quantity: 1),
  CartItem(name: 'Rice', price: 1550.0, quantity: 1),
];

class CartItemWidget extends StatelessWidget {
  final String name;
  final double price;
  final int quantity;

  const CartItemWidget({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left section with icon and product info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Product Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Product Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'TK ${price.toStringAsFixed(2)} × $quantity',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add discount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Spacer
          const Spacer(),
          
          // Price display
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(
              'TK ${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ),
          
          // Quantity Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(Icons.remove, size: 12),
                ),
              ),
              SizedBox(
                width: 20,
                child: Center(
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 12),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 16,
              ),
              const SizedBox(width: 2),
            ],
          ),
          
          // Yellow/Black Warning Stripes
          Container(
            width: 20,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                colors: [
                  Colors.yellow,
                  Colors.black,
                  Colors.yellow,
                  Colors.black,
                  Colors.yellow,
                ],
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
