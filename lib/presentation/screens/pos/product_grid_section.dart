import 'package:flutter/material.dart';
import '../../../domain/entities/product.dart';
import 'cart_item.dart';

class ProductGridSection extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;
  final List<CartItem> cartItems;
  final bool isLoading;

  const ProductGridSection({
    super.key,
    required this.products,
    required this.onProductTap,
    this.cartItems = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add products from the Products menu',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Filter out inactive products for POS
    final activeProducts = products.where((p) => p.isActive).toList();
    
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: activeProducts.length,
      itemBuilder: (context, index) {
        final product = activeProducts[index];
        final isOutOfStock = product.stockQuantity <= 0;
        final isLowStock = product.isLowStock && !isOutOfStock;
        
        // Check if product is in cart
        final cartItem = cartItems.firstWhere(
          (item) => item.product.id == product.id,
          orElse: () => CartItem(product: product, quantity: 0),
        );
        final isInCart = cartItem.quantity > 0;
        final cartQuantity = cartItem.quantity;
        
        return Card(
          elevation: isInCart ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isInCart
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: isOutOfStock ? null : () => onProductTap(product),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isOutOfStock
                    ? Colors.grey.shade100
                    : isInCart
                        ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
                        : Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isOutOfStock
                                    ? Colors.grey.shade200
                                    : isLowStock
                                        ? Colors.orange.shade50
                                        : Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                size: 32,
                                color: isOutOfStock
                                    ? Colors.grey.shade400
                                    : isLowStock
                                        ? Colors.orange.shade700
                                        : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          // Cart quantity badge
                          if (isInCart)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$cartQuantity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: isOutOfStock ? Colors.grey.shade600 : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TK ${product.sellingPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isOutOfStock
                            ? Colors.grey.shade500
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Stock quantity - always visible
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? Colors.red.shade50
                            : isLowStock
                                ? Colors.orange.shade50
                                : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isOutOfStock
                            ? 'Out'
                            : 'Stock: ${product.stockQuantity}',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: isOutOfStock
                              ? Colors.red.shade700
                              : isLowStock
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

