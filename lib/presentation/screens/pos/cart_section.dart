import 'package:flutter/material.dart';
import '../../../domain/entities/customer.dart';
import '../../providers/pos_provider.dart';
import '../../widgets/discount_dialog.dart';
import '../../widgets/quick_customer_dialog.dart';
import 'cart_item.dart';

class CartSection extends StatelessWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final DiscountType discountType;
  final double discountValue;
  final Customer? selectedCustomer;
  final List<Customer> customers;
  final Function(int productId, int quantity) onQuantityChanged;
  final Function(int productId) onRemoveItem;
  final Function(DiscountType type, double value) onDiscountChanged;
  final Function(Customer? customer) onCustomerChanged;
  final VoidCallback onCheckout;

  const CartSection({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.discountType,
    required this.discountValue,
    this.selectedCustomer,
    this.customers = const [],
    required this.onQuantityChanged,
    required this.onRemoveItem,
    required this.onDiscountChanged,
    required this.onCustomerChanged,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cart Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Cart (${cartItems.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Cart Items
        Flexible(
          flex: 1,
          child: cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 24,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cart is empty',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildCartItem(context, item);
                  },
                ),
        ),
        // Totals Section - Compact and Elegant
        Container(
          constraints: const BoxConstraints(maxHeight: 160),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Customer Selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: DropdownButton<Customer?>(
                          value: selectedCustomer,
                          isExpanded: true,
                          underline: const SizedBox(),
                          isDense: true,
                          iconSize: 16,
                          hint: Text(
                            'Walk-in Customer',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<Customer?>(
                              value: null,
                              child: Text(
                                'Walk-in Customer',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                            ...customers.map((customer) {
                              return DropdownMenuItem<Customer?>(
                                value: customer,
                                child: Text(
                                  customer.name,
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (customer) {
                            onCustomerChanged(customer);
                          },
                          selectedItemBuilder: (BuildContext context) {
                            return [
                              const Text(
                                'Walk-in Customer',
                                style: TextStyle(fontSize: 11, color: Colors.black87),
                              ),
                              ...customers.map((customer) {
                                return Text(
                                  customer.name,
                                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }),
                            ];
                          },
                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        final newCustomer = await showDialog<Customer>(
                          context: context,
                          builder: (context) => const QuickCustomerDialog(),
                        );
                        if (newCustomer != null) {
                          onCustomerChanged(newCustomer);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      tooltip: 'Add New Customer',
                    ),
                  ],
                ),
              ),
              // Totals
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTotalRow('Subtotal', subtotal),
                    if (discountAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Discount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                if (discountType == DiscountType.percentage)
                                  Text(
                                    ' (${discountValue.toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '-TK ${discountAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () async {
                                    final result = await showDialog<Map<String, dynamic>>(
                                      context: context,
                                      builder: (context) => DiscountDialog(
                                        currentType: discountType,
                                        currentValue: discountValue,
                                      ),
                                    );
                                    if (result != null) {
                                      final type = result['type'];
                                      final value = result['value'];
                                      if (type != null && type is DiscountType) {
                                        onDiscountChanged(
                                          type,
                                          (value as num?)?.toDouble() ?? 0.0,
                                        );
                                      }
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  tooltip: 'Edit Discount',
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () async {
                                final result = await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (context) => DiscountDialog(
                                    currentType: discountType,
                                    currentValue: discountValue,
                                  ),
                                );
                                if (result != null) {
                                  final type = result['type'];
                                  final value = result['value'];
                                  if (type != null && type is DiscountType) {
                                    onDiscountChanged(
                                      type,
                                      (value as num?)?.toDouble() ?? 0.0,
                                    );
                                  }
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              tooltip: 'Add Discount',
                            ),
                          ],
                        ),
                      ),
                    if (taxAmount > 0) _buildTotalRow('Tax', taxAmount),
                    const Divider(height: 2, thickness: 0.5),
                    // Total Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _buildTotalRow(
                        'Total',
                        totalAmount,
                        isTotal: true,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty ? null : onCheckout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.payment, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 13,
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
        ),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Product Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.inventory_2,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'TK ${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'TK ${item.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: () {
                          onQuantityChanged(item.product.id!, item.quantity - 1);
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Container(
                      width: 32,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () {
                          onQuantityChanged(item.product.id!, item.quantity + 1);
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () {
                    onRemoveItem(item.product.id!);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  color: Colors.red.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 13 : 11,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          Text(
            'TK ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 14 : 11,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
