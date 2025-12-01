import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pos_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../../../domain/entities/customer.dart';
import '../../widgets/discount_dialog.dart';
import '../../widgets/quick_customer_dialog.dart';
import 'cart_item_widget.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posProvider);
    final authState = ref.watch(authProvider);
    final customersState = ref.watch(customerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Cart Items List
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
                          'Add products from the POS screen',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: posState.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = posState.cartItems[index];
                      return CartItemWidget(
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
                      );
                    },
                  ),
          ),
          // Totals and Checkout Section
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Customer Selection
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                          ),
                          child: DropdownButton<Customer?>(
                            value: posState.selectedCustomerId != null
                                ? (() {
                                    try {
                                      return customersState.customers.firstWhere(
                                        (c) => c.id != null && c.id.toString() == posState.selectedCustomerId,
                                      );
                                    } catch (e) {
                                      return null;
                                    }
                                  })()
                                : null,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: Text(
                              'Walk-in Customer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<Customer?>(
                                value: null,
                                child: Text(
                                  'Walk-in Customer',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              ...customersState.customers.map((customer) {
                                return DropdownMenuItem<Customer?>(
                                  value: customer,
                                  child: Text(
                                    customer.name,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (customer) {
                              ref.read(posProvider.notifier).setCustomer(
                                customer?.id != null ? customer!.id.toString() : null,
                              );
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return [
                                const Text(
                                  'Walk-in Customer',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                ...customersState.customers.map((customer) {
                                  return Text(
                                    customer.name,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }),
                              ];
                            },
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () async {
                          final newCustomer = await showDialog<Customer>(
                            context: context,
                            builder: (context) => const QuickCustomerDialog(),
                          );
                          if (newCustomer != null) {
                            ref.read(posProvider.notifier).setCustomer(
                              newCustomer.id != null ? newCustomer.id.toString() : null,
                            );
                            // Refresh customer list
                            ref.read(customerProvider.notifier).loadCustomers();
                          }
                        },
                        tooltip: 'Add New Customer',
                      ),
                    ],
                  ),
                ),
                // Totals
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Calculate individual item discounts total
                      Builder(
                        builder: (context) {
                          final individualDiscountsTotal = posState.cartItems.fold(
                            0.0,
                            (sum, item) => sum + item.discount,
                          );
                          final subtotalBeforeDiscounts = posState.cartItems.fold(
                            0.0,
                            (sum, item) => sum + (item.unitPrice * item.quantity),
                          );
                          if (individualDiscountsTotal > 0) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Subtotal (before discounts)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        'TK ${subtotalBeforeDiscounts.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Item Discounts',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '-TK ${individualDiscountsTotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      _buildTotalRow('Subtotal', posState.subtotal),
                      if (posState.discountAmount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Discount',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  if (posState.discountType == DiscountType.percentage)
                                    Text(
                                      ' (${posState.discountValue.toStringAsFixed(1)}%)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '-TK ${posState.discountAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () async {
                                      final result = await showDialog<Map<String, dynamic>>(
                                        context: context,
                                        builder: (context) => DiscountDialog(
                                          currentType: posState.discountType,
                                          currentValue: posState.discountValue,
                                        ),
                                      );
                                      if (result != null) {
                                        final type = result['type'];
                                        final value = result['value'];
                                        if (type != null && type is DiscountType) {
                                          ref.read(posProvider.notifier).setDiscount(
                                            type,
                                            (value as num?)?.toDouble() ?? 0.0,
                                          );
                                        }
                                      }
                                    },
                                    tooltip: 'Edit Discount',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () async {
                                  final result = await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (context) => DiscountDialog(
                                      currentType: posState.discountType,
                                      currentValue: posState.discountValue,
                                    ),
                                  );
                                  if (result != null) {
                                    final type = result['type'];
                                    final value = result['value'];
                                    if (type != null && type is DiscountType) {
                                      ref.read(posProvider.notifier).setDiscount(
                                        type,
                                        (value as num?)?.toDouble() ?? 0.0,
                                      );
                                    }
                                  }
                                },
                                tooltip: 'Add Discount',
                              ),
                            ],
                          ),
                        ),
                      if (posState.taxAmount > 0) _buildTotalRow('Tax', posState.taxAmount),
                      const Divider(height: 16, thickness: 1),
                      // Total Row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildTotalRow(
                          'Total',
                          posState.totalAmount,
                          isTotal: true,
                        ),
                      ),
                    ],
                  ),
                ),
                // Checkout Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: posState.cartItems.isEmpty ? null : () async {
                        final user = authState.user;
                        if (user == null) return;

                        final success = await ref.read(posProvider.notifier).processPayment(
                              user.id!,
                              1,
                            );

                        if (success && mounted) {
                          // Refresh products to show updated stock
                          ref.read(productProvider.notifier).loadProducts();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sale completed successfully!'),
                              backgroundColor: Colors.green,
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
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.payment, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Checkout',
                            style: TextStyle(
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

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          Text(
            'TK ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

