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
    
    // Responsive grid based on screen size
    final crossAxisCount = MediaQuery.of(context).size.width > 1200 ? 6 : 
                          MediaQuery.of(context).size.width > 900 ? 5 : 
                          MediaQuery.of(context).size.width > 600 ? 4 : 3;
    
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.62, // Further reduced to prevent overflow
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: activeProducts.length,
      // Performance: Optimize grid rendering
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
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
          elevation: isInCart ? 6 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isInCart
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.5,
                  )
                : BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: InkWell(
            onTap: isOutOfStock ? null : () => onProductTap(product),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isOutOfStock
                    ? null
                    : isInCart
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15),
                              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.05),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.grey.shade50,
                            ],
                          ),
                color: isOutOfStock ? Colors.grey.shade100 : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon section with fixed height - reduced
                    SizedBox(
                      height: 65,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isOutOfStock
                                    ? Colors.grey.shade200
                                    : isLowStock
                                        ? Colors.orange.shade50
                                        : Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isOutOfStock
                                            ? Colors.grey.shade300
                                            : isLowStock
                                                ? Colors.orange.shade200
                                                : Theme.of(context).colorScheme.primary.withOpacity(0.2))
                                        .withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                size: 28,
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
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$cartQuantity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Product name - constrained height
                    SizedBox(
                      height: 28,
                      child: Center(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: isOutOfStock ? Colors.grey.shade600 : Colors.black87,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Price - fixed height
                    Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? Colors.grey.shade200
                            : Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'TK ${product.sellingPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isOutOfStock
                                ? Colors.grey.shade600
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Stock quantity - fixed height
                    Container(
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? Colors.red.shade50
                            : isLowStock
                                ? Colors.orange.shade50
                                : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

