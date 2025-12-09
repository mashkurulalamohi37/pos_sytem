import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' show SystemMouseCursors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pos_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../../domain/entities/customer.dart';
import '../../../core/constants.dart';
import 'sale_receipt_screen.dart';
import '../../widgets/discount_dialog.dart';
import '../../widgets/quick_customer_dialog.dart';
import 'cart_item_widget.dart';

class CartSidebar extends ConsumerStatefulWidget {
  const CartSidebar({super.key});

  @override
  ConsumerState<CartSidebar> createState() => _CartSidebarState();
}

class _CartSidebarState extends ConsumerState<CartSidebar> {
  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posProvider);
    final authState = ref.watch(authProvider);
    final customersState = ref.watch(customerProvider);

    return Container(
      width: kIsWeb ? 450 : 400,
      constraints: kIsWeb 
          ? const BoxConstraints(maxWidth: 450, minWidth: 400)
          : const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Cart Header
          Container(
            padding: EdgeInsets.all(kIsWeb ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      Text(
                        '${posState.cartItems.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Cart Items
          Expanded(
            child: posState.cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cart is empty',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add products to get started',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(kIsWeb ? 12 : 16),
                    itemCount: posState.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = posState.cartItems[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: kIsWeb ? 8 : 12),
                        child: CartItemWidget(
                          item: item,
                          onQuantityChanged: (productId, quantity) {
                            ref.read(posProvider.notifier).updateQuantity(productId, quantity);
                          },
                          onRemove: (productId) {
                            ref.read(posProvider.notifier).removeFromCart(productId);
                          },
                          onDiscountChanged: (productId, discount) {
                            ref.read(posProvider.notifier).updateDiscount(productId, discount);
                          },
                        ),
                      );
                    },
                  ),
          ),
          // Totals and Checkout
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Customer Selection
                if (authState.user?.isAdmin == true || authState.user?.isManager == true)
                  Container(
                    padding: EdgeInsets.all(kIsWeb ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final selectedCustomer = posState.selectedCustomerId != null
                                      ? customersState.customers.firstWhere(
                                          (c) => c.id != null && c.id.toString() == posState.selectedCustomerId,
                                          orElse: () => Customer(name: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
                                        )
                                      : null;
                                  
                                  return selectedCustomer != null && selectedCustomer.name.isNotEmpty
                                      ? Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.person, size: 20, color: Colors.grey.shade600),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  selectedCustomer.name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close, size: 18),
                                                onPressed: () {
                                                  ref.read(posProvider.notifier).setCustomer(null);
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        )
                                      : ElevatedButton.icon(
                                          onPressed: () async {
                                            final customer = await showDialog<Customer>(
                                              context: context,
                                              builder: (context) => const QuickCustomerDialog(),
                                            );
                                            if (customer != null && customer.id != null && mounted) {
                                              ref.read(posProvider.notifier).setCustomer(customer.id.toString());
                                              ref.read(customerProvider.notifier).loadCustomers();
                                            }
                                          },
                                          icon: const Icon(Icons.person_add, size: 18),
                                          label: const Text('Select Customer'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.grey.shade700,
                                            elevation: 0,
                                            side: BorderSide(color: Colors.grey.shade300),
                                          ),
                                        );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                // Overall Discount Section
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 16 : 20, 
                    vertical: kIsWeb ? 10 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overall Discount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      // Show discount amount if applied, otherwise show Add button
                      posState.discountAmount > 0
                          ? GestureDetector(
                              onTap: () => _showOverallDiscountDialog(context),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'TK ${posState.discountAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.edit, size: 14, color: Colors.blue.shade700),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () => _showOverallDiscountDialog(context),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add, size: 16, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Add',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                // Totals
                Padding(
                  padding: EdgeInsets.all(kIsWeb ? 16 : 20),
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal', posState.subtotal, false),
                      if (posState.discountAmount > 0)
                        _buildTotalRow('Discount', -posState.discountAmount, false),
                      if (posState.taxAmount > 0)
                        _buildTotalRow('Tax', posState.taxAmount, false),
                      const Divider(height: 24),
                      _buildTotalRow('Total', posState.totalAmount, true),
                    ],
                  ),
                ),
                // Checkout Button
                Container(
                  padding: EdgeInsets.all(kIsWeb ? 12 : 16),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: posState.cartItems.isEmpty
                          ? null
                          : () async {
                              final user = authState.user;
                              if (user == null || user.id == null) return;
                              
                              final paymentMethod = await _showPaymentMethodDialog(context);
                              if (paymentMethod != null && mounted) {
                                ref.read(posProvider.notifier).setPaymentMethod(paymentMethod);
                                final sale = await ref.read(posProvider.notifier).processPayment(
                                  user.id!,
                                  1, // branchId - using default branch
                                );
                                if (sale != null && mounted) {
                                  // Navigate to receipt screen
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SaleReceiptScreen(
                                        sale: sale,
                                        saleItems: sale.items ?? [],
                                      ),
                                    ),
                                  );
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to process sale'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Checkout - TK ${posState.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTotalRow(String label, double amount, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            'TK ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPaymentMethodDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.paymentMethods.map((method) {
            return ListTile(
              leading: Icon(_getPaymentIcon(method)),
              title: Text(method),
              onTap: () => Navigator.pop(context, method),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'mobile payment':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  void _showOverallDiscountDialog(BuildContext context) {
    final posState = ref.read(posProvider);
    DiscountType selectedType = posState.discountType;
    final amountController = TextEditingController(
      text: posState.discountType == DiscountType.fixed && posState.discountValue > 0
          ? posState.discountValue.toString()
          : '',
    );
    final percentageController = TextEditingController(
      text: posState.discountType == DiscountType.percentage && posState.discountValue > 0
          ? posState.discountValue.toString()
          : '',
    );
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Apply Overall Discount'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discount Type Selection
                  const Text(
                    'Discount Type:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<DiscountType>(
                    segments: const [
                      ButtonSegment<DiscountType>(
                        value: DiscountType.none,
                        label: Text('None'),
                      ),
                      ButtonSegment<DiscountType>(
                        value: DiscountType.fixed,
                        label: Text('TK'),
                      ),
                      ButtonSegment<DiscountType>(
                        value: DiscountType.percentage,
                        label: Text('%'),
                      ),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (Set<DiscountType> newSelection) {
                      setState(() {
                        selectedType = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Fixed Amount Input
                  if (selectedType == DiscountType.fixed) ...[
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount Amount (TK)',
                        prefixIcon: Icon(Icons.currency_exchange),
                        border: OutlineInputBorder(),
                        hintText: 'Enter discount amount',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                  // Percentage Input
                  if (selectedType == DiscountType.percentage) ...[
                    TextField(
                      controller: percentageController,
                      decoration: const InputDecoration(
                        labelText: 'Discount Percentage (%)',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                        hintText: 'Enter percentage (0-100)',
                        suffixText: '%',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  double value = 0.0;
                  
                  if (selectedType == DiscountType.fixed) {
                    value = double.tryParse(amountController.text) ?? 0.0;
                    if (value < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Discount amount cannot be negative'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                  } else if (selectedType == DiscountType.percentage) {
                    value = double.tryParse(percentageController.text) ?? 0.0;
                    if (value < 0 || value > 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Percentage must be between 0 and 100'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                  }
                  
                  ref.read(posProvider.notifier).setDiscount(selectedType, value);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}

