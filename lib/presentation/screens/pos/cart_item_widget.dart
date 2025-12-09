import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' show SystemMouseCursors;
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
                            // Show discount if applied, otherwise show "Add discount"
                            if (item.discount > 0)
                              if (kIsWeb)
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    bool isHovered = false;
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      onEnter: (_) => setState(() => isHovered = true),
                                      onExit: (_) => setState(() => isHovered = false),
                                      child: GestureDetector(
                                        onTap: () => _showDiscountDialog(context),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isHovered ? Colors.red.shade100 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isHovered ? Colors.red.shade400 : Colors.red.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.discount,
                                                size: 12,
                                                color: Colors.red.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Discount: TK ${item.discount.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                GestureDetector(
                                  onTap: () => _showDiscountDialog(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.discount,
                                          size: 12,
                                          color: Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Discount: TK ${item.discount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            else
                              if (kIsWeb)
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    bool isHovered = false;
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      onEnter: (_) => setState(() => isHovered = true),
                                      onExit: (_) => setState(() => isHovered = false),
                                      child: GestureDetector(
                                        onTap: () => _showDiscountDialog(context),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isHovered ? Colors.blue.shade50 : Colors.transparent,
                                            borderRadius: BorderRadius.circular(4),
                                            border: isHovered
                                                ? Border.all(
                                                    color: Colors.blue.shade300,
                                                    width: 1,
                                                  )
                                                : null,
                                          ),
                                          child: Text(
                                            'Add discount',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isHovered ? Colors.blue.shade700 : Colors.blue,
                                              decoration: TextDecoration.underline,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                GestureDetector(
                                  onTap: () => _showDiscountDialog(context),
                                  child: Text(
                                    'Add discount',
                                    style: TextStyle(
                                      fontSize: 12,
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
            // Web: Enhanced larger controls with hover effects
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minus button with hover
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      bool isHovered = false;
                      return GestureDetector(
                        onTap: () {
                          if (item.quantity > 1) {
                            onQuantityChanged(item.product.id!, item.quantity - 1);
                          }
                        },
                        child: MouseRegion(
                          onEnter: (_) => setState(() => isHovered = true),
                          onExit: (_) => setState(() => isHovered = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isHovered ? Colors.grey.shade200 : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isHovered ? Colors.grey.shade400 : Colors.grey.shade300,
                                width: isHovered ? 1.5 : 1,
                              ),
                              boxShadow: isHovered
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: const Icon(
                              Icons.remove,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Plus button with hover
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      bool isHovered = false;
                      return GestureDetector(
                        onTap: () {
                          onQuantityChanged(item.product.id!, item.quantity + 1);
                        },
                        child: MouseRegion(
                          onEnter: (_) => setState(() => isHovered = true),
                          onExit: (_) => setState(() => isHovered = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isHovered ? Colors.blue.shade200 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isHovered ? Colors.blue.shade400 : Colors.blue.shade300,
                                width: isHovered ? 1.5 : 1,
                              ),
                              boxShadow: isHovered
                                  ? [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button with hover
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      bool isHovered = false;
                      return GestureDetector(
                        onTap: () {
                          onRemove(item.product.id!);
                        },
                        child: MouseRegion(
                          onEnter: (_) => setState(() => isHovered = true),
                          onExit: (_) => setState(() => isHovered = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isHovered ? Colors.red.shade50 : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: isHovered
                                  ? Border.all(
                                      color: Colors.red.shade300,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: isHovered ? Colors.red.shade700 : Colors.red,
                              size: isHovered ? 22 : 20,
                            ),
                          ),
                        ),
                      );
                    },
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