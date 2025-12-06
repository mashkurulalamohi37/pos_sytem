import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async' show unawaited;
import 'dart:math';
import '../../providers/pos_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../../../domain/entities/customer.dart';
import '../../../core/constants.dart';
import '../../widgets/discount_dialog.dart';
import '../../widgets/quick_customer_dialog.dart';
import 'sale_receipt_screen.dart';
import 'cart_item.dart';

class DirectCartScreen extends ConsumerWidget {
  const DirectCartScreen({super.key});
  
  // Method to show overall discount dialog
  void _showOverallDiscountDialog(BuildContext context, WidgetRef ref) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posState = ref.watch(posProvider);
    final authState = ref.watch(authProvider);
    final customersState = ref.watch(customerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: posState.cartItems.length,
                    // Performance: Optimize list rendering
                    cacheExtent: 500,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
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
                            child: DropdownButton<Customer?>(
                              value: null, // Always show "Walk-in Customer"
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                              hint: const Text('Walk-in Customer'),
                              items: [
                                const DropdownMenuItem<Customer?>(
                                  value: null,
                                  child: Text('Walk-in Customer'),
                                ),
                                ...customersState.customers.map((customer) {
                                  return DropdownMenuItem<Customer?>(
                                    value: customer,
                                    child: Text(
                                      customer.name,
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
                          onPressed: () async {
                            final newCustomer = await showDialog<Customer>(
                              context: context,
                              builder: (context) => const QuickCustomerDialog(),
                            );
                            if (newCustomer != null && context.mounted) {
                              ref.read(posProvider.notifier).setCustomer(
                                newCustomer.id != null ? newCustomer.id.toString() : null,
                              );
                              ref.read(customerProvider.notifier).loadCustomers();
                            }
                          },
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
                      Text(
                        'TK ${posState.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Overall Discount
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Overall Discount',
                        style: TextStyle(fontSize: 14),
                      ),
                      // Show discount amount if applied, otherwise show Add button
                      posState.discountAmount > 0
                          ? GestureDetector(
                              onTap: () {
                                _showOverallDiscountDialog(context, ref);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'TK ${posState.discountAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.edit, size: 14, color: Colors.blue),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                _showOverallDiscountDialog(context, ref);
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.add, size: 14, color: Colors.blue),
                                  Text(
                                    ' Add',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                
                // Tax Amount
                if (posState.taxAmount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tax',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'TK ${posState.taxAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Divider
                const Divider(height: 1),
                
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
                        'TK ${posState.totalAmount.toStringAsFixed(2)}',
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
                          Icon(Icons.payment, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 32,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: AppConstants.paymentMethods.map((method) {
                            final isSelected = posState.paymentMethod == method;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(4),
                                  onTap: () {
                                    ref.read(posProvider.notifier).setPaymentMethod(method);
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Colors.blue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isSelected 
                                            ? Colors.blue
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      alignment: Alignment.center,
                                      child: Text(
                                        AppConstants.getPaymentMethodName(method),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.white : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Checkout Button
                Container(
                  width: double.infinity,
                  height: 46,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      // Track checkout loading state
                      bool isCheckingOut = false;
                      
                      return ElevatedButton.icon(
                        icon: isCheckingOut 
                            ? const SizedBox(
                                width: 18, 
                                height: 18, 
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.payment, size: 18),
                        label: Text(
                          isCheckingOut ? 'Processing...' : 'Checkout',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: posState.cartItems.isEmpty || isCheckingOut ? null : () async {
                          final user = authState.user;
                          if (user == null) return;
                          
                          // Set loading state to show indicator
                          setState(() {
                            isCheckingOut = true;
                          });
                          
                          try {
                            // Process payment (optimized method)
                            final sale = await ref.read(posProvider.notifier).processPayment(
                                  user.id!,
                                  1,
                                );

                            if (sale != null && context.mounted) {
                              // Load products in the background instead of waiting
                              unawaited(ref.read(productProvider.notifier).loadProducts());
                              
                              // Immediately navigate to receipt screen
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => SaleReceiptScreen(
                                    sale: sale,
                                    saleItems: sale.items ?? [],
                                  ),
                                  transitionDuration: const Duration(milliseconds: 200),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to process sale'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              // Reset loading state if there was an error
                              setState(() {
                                isCheckingOut = false;
                              });
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              // Reset loading state if there was an error
                              setState(() {
                                isCheckingOut = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Method to apply item discount
void _applyItemDiscount(BuildContext context, WidgetRef ref, CartItem item) {
  DiscountType selectedType = DiscountType.fixed;
  double discountAmount = item.discount;
  
  // Create controllers for both fixed and percentage values
  final fixedController = TextEditingController(
    text: item.discount > 0 ? item.discount.toString() : '',
  );
  final percentageController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text('Discount for ${item.product.name}'),
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
                const SizedBox(height: 16),
                
                // Fixed Amount Input
                if (selectedType == DiscountType.fixed) 
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Amount (TK)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: fixedController,
                    onChanged: (value) {
                      discountAmount = double.tryParse(value) ?? 0.0;
                    },
                    autofocus: true,
                  ),
                
                // Percentage Input
                if (selectedType == DiscountType.percentage)
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Percentage (%)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      prefixIcon: Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: percentageController,
                    onChanged: (value) {
                      double percentage = double.tryParse(value) ?? 0.0;
                      // Convert percentage to actual discount amount
                      if (percentage > 0) {
                        discountAmount = (item.unitPrice * item.quantity) * (percentage / 100);
                      } else {
                        discountAmount = 0.0;
                      }
                    },
                    autofocus: true,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply the discount
                if (selectedType == DiscountType.fixed) {
                  discountAmount = double.tryParse(fixedController.text) ?? 0.0;
                } else {
                  double percentage = double.tryParse(percentageController.text) ?? 0.0;
                  if (percentage > 0) {
                    discountAmount = (item.unitPrice * item.quantity) * (percentage / 100);
                  }
                }
                
                // Validate discount amount
                if (discountAmount < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Discount amount cannot be negative'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                if (selectedType == DiscountType.percentage) {
                  double percentage = double.tryParse(percentageController.text) ?? 0.0;
                  if (percentage < 0 || percentage > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Percentage must be between 0 and 100'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }
                
                ref.read(posProvider.notifier).updateDiscount(
                      item.product.id!,
                      discountAmount,
                    );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 40),
              ),
              child: const Text('Apply'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        );
      },
    ),
  );
}

class CartItemWidget extends ConsumerWidget {
  final CartItem item;
  final Function(int productId, int quantity) onQuantityChanged;
  final Function(int productId) onRemove;
  final Function(int productId, double discount) onDiscountChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main cart item container
          Container(
            height: kIsWeb ? 50 : 55,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F2FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                // Left section with icon and product info
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: kIsWeb ? 6.0 : 8.0, 
                      vertical: 4.0
                    ),
                    child: Row(
                      children: [
                        // Product Icon
                        Container(
                          width: kIsWeb ? 30 : 34,
                          height: kIsWeb ? 30 : 34,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: Colors.white,
                            size: kIsWeb ? 18 : 20,
                          ),
                        ),
                        SizedBox(width: kIsWeb ? 6 : 8),
                        
                        // Product Info - Name and price
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: kIsWeb ? 14 : 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'TK ${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: kIsWeb ? 11 : 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.visible,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Price display - Fixed width to ensure visibility
                Padding(
                  padding: EdgeInsets.only(right: kIsWeb ? 4 : 8),
                  child: SizedBox(
                    width: kIsWeb ? 75 : 85,
                    child: Text(
                      'TK ${(item.unitPrice * item.quantity - item.discount).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: kIsWeb ? 14 : 16,
                        color: Colors.blue,
                      ),
                      overflow: TextOverflow.visible,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                
                // Quantity controls - more compact for web
                if (!kIsWeb) ...[
                  // Minus button
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (item.quantity > 1) {
                          onQuantityChanged(item.product.id!, item.quantity - 1);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  
                  // Quantity display
                  SizedBox(
                    width: 24,
                    child: Center(
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Plus button
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        onQuantityChanged(item.product.id!, item.quantity + 1);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ] else ...[
                  // Web: More compact quantity controls
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () {
                        if (item.quantity > 1) {
                          onQuantityChanged(item.product.id!, item.quantity - 1);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  
                  SizedBox(
                    width: 20,
                    child: Center(
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        onQuantityChanged(item.product.id!, item.quantity + 1);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
                
                // Delete button
                Container(
                  margin: EdgeInsets.only(left: kIsWeb ? 2 : 4),
                  width: kIsWeb ? 26 : 30,
                  height: kIsWeb ? 26 : 30,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: kIsWeb ? 16 : 18,
                    ),
                    onPressed: () {
                      onRemove(item.product.id!);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                
                // Yellow/Black Warning Stripes
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Discount button or discount display
          Padding(
            padding: EdgeInsets.only(left: kIsWeb ? 42.0 : 50.0, top: 2, bottom: 4),
            child: item.discount > 0
                ? TextButton(
                    onPressed: () {
                      _applyItemDiscount(context, ref, item);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'DISCOUNT: TK ${item.discount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: kIsWeb ? 10 : 11,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () {
                      _applyItemDiscount(context, ref, item);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                      backgroundColor: Colors.blue.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'ADD DISCOUNT',
                      style: TextStyle(
                        fontSize: kIsWeb ? 10 : 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleDiscountButton(BuildContext context) {
    print('Handling discount button for product ${item.product.name}');
    
    // Show a simple dialog for adding discount
    DiscountType selectedType = DiscountType.fixed;
    double discountAmount = item.discount;
    
    // Create controllers for both fixed and percentage values
    final fixedController = TextEditingController(
      text: item.discount > 0 ? item.discount.toString() : '',
    );
    final percentageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Discount for ${item.product.name}'),
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
                  const SizedBox(height: 16),
                  
                  // Fixed Amount Input
                  if (selectedType == DiscountType.fixed) 
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Amount (TK)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        prefixIcon: Icon(Icons.currency_exchange),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: fixedController,
                      onChanged: (value) {
                        discountAmount = double.tryParse(value) ?? 0.0;
                      },
                      autofocus: true,
                    ),
                  
                  // Percentage Input
                  if (selectedType == DiscountType.percentage)
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Percentage (%)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        prefixIcon: Icon(Icons.percent),
                        suffixText: '%',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: percentageController,
                      onChanged: (value) {
                        double percentage = double.tryParse(value) ?? 0.0;
                        // Convert percentage to actual discount amount
                        if (percentage > 0) {
                          discountAmount = (item.unitPrice * item.quantity) * (percentage / 100);
                        } else {
                          discountAmount = 0.0;
                        }
                      },
                      autofocus: true,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Apply the discount
                  if (selectedType == DiscountType.fixed) {
                    discountAmount = double.tryParse(fixedController.text) ?? 0.0;
                  } else {
                    double percentage = double.tryParse(percentageController.text) ?? 0.0;
                    if (percentage > 0) {
                      discountAmount = (item.unitPrice * item.quantity) * (percentage / 100);
                    }
                  }
                  
                  // Validate discount amount
                  if (discountAmount < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Discount amount cannot be negative'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  if (selectedType == DiscountType.percentage) {
                    double percentage = double.tryParse(percentageController.text) ?? 0.0;
                    if (percentage < 0 || percentage > 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Percentage must be between 0 and 100'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                  }
                  
                  onDiscountChanged(item.product.id!, discountAmount);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 40),
                ),
                child: const Text('Apply'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          );
        },
      ),
    );
  }
  
  // Keep this for backward compatibility
  Future<void> _showDiscountDialog(BuildContext context) async {
    _handleDiscountButton(context);
  }
}

// Simple painter class (kept for compatibility)
class DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Empty implementation - we're using Container with gradient instead
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}