import 'package:flutter/material.dart';
import 'cart_item.dart';
import '../../widgets/discount_dialog.dart';
import '../../providers/pos_provider.dart';

class CartItemWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
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
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TK ${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (item.discount > 0) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Discount: -TK ${item.discount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: () async {
                            final result = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => DiscountDialog(
                                currentType: item.discount > 0 ? DiscountType.fixed : DiscountType.none,
                                currentValue: item.discount,
                              ),
                            );
                            if (result != null) {
                              final type = result['type'];
                              final value = result['value'];
                              if (type != null && type is DiscountType) {
                                if (type == DiscountType.none) {
                                  onDiscountChanged(item.product.id!, 0.0);
                                } else if (type == DiscountType.fixed) {
                                  final discountAmount = (value as num?)?.toDouble() ?? 0.0;
                                  final maxDiscount = item.unitPrice * item.quantity;
                                  onDiscountChanged(item.product.id!, discountAmount > maxDiscount ? maxDiscount : discountAmount);
                                } else if (type == DiscountType.percentage) {
                                  final percentage = (value as num?)?.toDouble() ?? 0.0;
                                  final discountAmount = (item.unitPrice * item.quantity) * (percentage / 100);
                                  onDiscountChanged(item.product.id!, discountAmount);
                                }
                              }
                            }
                          },
                          child: Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () async {
                        final result = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => DiscountDialog(
                            currentType: DiscountType.none,
                            currentValue: 0.0,
                          ),
                        );
                        if (result != null) {
                          final type = result['type'];
                          final value = result['value'];
                          if (type != null && type is DiscountType) {
                            if (type == DiscountType.fixed) {
                              final discountAmount = (value as num?)?.toDouble() ?? 0.0;
                              final maxDiscount = item.unitPrice * item.quantity;
                              onDiscountChanged(item.product.id!, discountAmount > maxDiscount ? maxDiscount : discountAmount);
                            } else if (type == DiscountType.percentage) {
                              final percentage = (value as num?)?.toDouble() ?? 0.0;
                              final discountAmount = (item.unitPrice * item.quantity) * (percentage / 100);
                              onDiscountChanged(item.product.id!, discountAmount);
                            }
                          }
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.discount_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Add discount',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'TK ${item.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                        borderRadius: BorderRadius.circular(6),
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
                        borderRadius: BorderRadius.circular(6),
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
                const SizedBox(height: 6),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () {
                    onRemove(item.product.id!);
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
}

