import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'cart_item.dart';
import '../../widgets/discount_dialog.dart';
import '../../providers/pos_provider.dart';

// This file is kept for backward compatibility
// The main implementation is now in cart_screen.dart

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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left section with icon and product info
          Flexible(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(kIsWeb ? 6.0 : 8.0),
              child: Row(
                children: [
                  // Product Icon
                  Container(
                    width: kIsWeb ? 28 : 32,
                    height: kIsWeb ? 28 : 32,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: Colors.white,
                      size: kIsWeb ? 16 : 18,
                    ),
                  ),
                  SizedBox(width: kIsWeb ? 8 : 12),
                  
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: kIsWeb ? 13 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        // Use Wrap to prevent overflow
                        Wrap(
                          spacing: kIsWeb ? 4 : 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'TK ${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
                                style: TextStyle(
                                  fontSize: kIsWeb ? 10 : 12,
                                  color: Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showDiscountDialog(context),
                              child: Text(
                                'Add discount',
                                style: TextStyle(
                                  fontSize: kIsWeb ? 10 : 12,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Price display - Flexible for web
          Flexible(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 2.0 : 4.0),
              child: Text(
                'TK ${(item.unitPrice * item.quantity - item.discount).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: kIsWeb ? 12 : 14,
                  color: Colors.blue,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          
          // Quantity Controls - more compact for web
          if (!kIsWeb) ...[
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
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.remove, size: 12),
                      onPressed: () {
                        if (item.quantity > 1) {
                          onQuantityChanged(item.product.id!, item.quantity - 1);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Center(
                    child: Text(
                      '${item.quantity}',
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
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 12),
                      onPressed: () {
                        onQuantityChanged(item.product.id!, item.quantity + 1);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    onRemove(item.product.id!);
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 2),
              ],
            ),
          ] else ...[
            // Web: More compact controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.remove, size: 10),
                      onPressed: () {
                        if (item.quantity > 1) {
                          onQuantityChanged(item.product.id!, item.quantity - 1);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 18,
                  child: Center(
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 10),
                      onPressed: () {
                        onQuantityChanged(item.product.id!, item.quantity + 1);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: () {
                    onRemove(item.product.id!);
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 14,
                  ),
                ),
              ],
            ),
          ],
          
          // Yellow/Black Warning Stripes
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Container(
              width: kIsWeb ? 12 : 15,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.yellow,
                    Colors.black,
                    Colors.yellow,
                    Colors.black,
                    Colors.yellow,
                  ],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  tileMode: TileMode.repeated,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDiscountDialog(BuildContext context) async {
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
          onDiscountChanged(
            item.product.id!,
            discountAmount > maxDiscount ? maxDiscount : discountAmount,
          );
        } else if (type == DiscountType.percentage) {
          final percentage = (value as num?)?.toDouble() ?? 0.0;
          final discountAmount = (item.unitPrice * item.quantity) * (percentage / 100);
          onDiscountChanged(item.product.id!, discountAmount);
        }
      }
    }
  }
}