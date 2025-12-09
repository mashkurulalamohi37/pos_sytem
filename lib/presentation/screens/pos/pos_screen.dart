import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/pos_provider.dart';
import '../../providers/product_provider.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/category.dart';
import '../../widgets/barcode_scanner_widget.dart';
import '../../widgets/barcode_scanner_settings_widget.dart';
import 'product_grid_section.dart';
import 'cart_screen.dart';
import 'cart_sidebar.dart';
import 'direct_cart_screen.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<int?>> _buildCategoryDropdownItems(List<Category> categories) {
    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('All Categories'),
      ),
    ];
    
    // Get parent categories (categories without a parent)
    final parentCategories = categories
        .where((c) => c.parentCategoryId == null && c.id != null)
        .toList();
    
    for (final parent in parentCategories) {
      if (parent.id == null) continue; // Skip if no ID
      
      // Add parent category
      items.add(
        DropdownMenuItem<int?>(
          value: parent.id,
          child: Text(parent.name),
        ),
      );
      
      // Add subcategories under this parent
      final subcategories = categories
          .where((c) => c.parentCategoryId == parent.id && c.id != null)
          .toList();
      
      for (final subcategory in subcategories) {
        if (subcategory.id == null) continue; // Skip if no ID
        
        items.add(
          DropdownMenuItem<int?>(
            value: subcategory.id,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Row(
                children: [
                  // L-shaped line
                  Text(
                    '└─ ',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      subcategory.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posProvider);
    final productsState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.point_of_sale,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Point of Sale',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        actions: [
          if (kIsWeb) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  _showScannerSettings(context);
                },
                tooltip: 'Scanner Settings',
                color: Colors.grey.shade700,
              ),
            ),
          ],
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                _showBarcodeScanner(context);
              },
              tooltip: 'Scan Barcode',
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          final isWeb = kIsWeb && constraints.maxWidth >= 900;
          
          if (isMobile) {
            // Mobile: Stack vertically with keyboard handling
            return Column(
              children: [
                // Search and Category Filter
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          ref.read(productProvider.notifier).search(value);
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: _selectedCategoryId,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                            items: _buildCategoryDropdownItems(productsState.categories),
                            selectedItemBuilder: (context) {
                              return [
                                const Text('All Categories'),
                                ...productsState.categories.map((category) {
                                  return Text(category.name);
                                }),
                              ];
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                              ref.read(productProvider.notifier).filterByCategory(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Product Grid
                Expanded(
                  child: ProductGridSection(
                    products: productsState.filteredProducts,
                    isLoading: productsState.isLoading,
                    cartItems: posState.cartItems,
                    onProductTap: (product) async {
                      await ref.read(posProvider.notifier).toggleProductInCart(product);
                    },
                  ),
                ),
                // Next Button (shows when cart has items)
                if (posState.cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DirectCartScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Cart (${posState.cartItems.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else if (isWeb) {
            // Web: Split view with cart sidebar
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Grid Section
                Expanded(
                  child: Column(
                    children: [
                      // Enhanced Search and Category Filter
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search products by name or barcode...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                                onChanged: (value) {
                                  ref.read(productProvider.notifier).search(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int?>(
                                    value: _selectedCategoryId,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                    items: _buildCategoryDropdownItems(productsState.categories),
                                    selectedItemBuilder: (context) {
                                      return [
                                        const Text('All Categories'),
                                        ...productsState.categories.map((category) {
                                          return Text(category.name);
                                        }),
                                      ];
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategoryId = value;
                                      });
                                      ref.read(productProvider.notifier).filterByCategory(value);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Product Grid
                      Expanded(
                        child: Container(
                          color: Colors.grey.shade50,
                          child: ProductGridSection(
                            products: productsState.filteredProducts,
                            isLoading: productsState.isLoading,
                            cartItems: posState.cartItems,
                            onProductTap: (product) async {
                              await ref.read(posProvider.notifier).toggleProductInCart(product);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Cart Sidebar
                const CartSidebar(),
              ],
            );
          } else {
            // Tablet: Side by side
            return Row(
              children: [
                // Product Grid Section
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Search and Category Filter
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search products...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onChanged: (value) {
                                  ref.read(productProvider.notifier).search(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  value: _selectedCategoryId,
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                  items: _buildCategoryDropdownItems(productsState.categories),
                                  selectedItemBuilder: (context) {
                                    return [
                                      const Text('All Categories'),
                                      ...productsState.categories.map((category) {
                                        return Text(category.name);
                                      }),
                                    ];
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategoryId = value;
                                    });
                                    ref.read(productProvider.notifier).filterByCategory(value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Product Grid
                      Expanded(
                        child: ProductGridSection(
                          products: productsState.filteredProducts,
                          isLoading: productsState.isLoading,
                          cartItems: posState.cartItems,
                          onProductTap: (product) async {
                            await ref.read(posProvider.notifier).toggleProductInCart(product);
                          },
                        ),
                      ),
                      // Next Button (shows when cart has items)
                      if (posState.cartItems.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade300, width: 1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DirectCartScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Cart (${posState.cartItems.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> _showBarcodeScanner(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (scannerContext) => BarcodeScannerWidget(
          onBarcodeScanned: (barcode) async {
            // Look up product by barcode
            final product = await ref.read(productProvider.notifier).getProductByBarcode(barcode);
            
            if (product != null) {
              // Add product to cart
              await ref.read(posProvider.notifier).addToCart(product);
              
              // Close scanner and show success message
              if (scannerContext.mounted) {
                Navigator.pop(scannerContext);
                // Show success message in the original context
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            } else {
              // Product not found - show error but keep scanner open
              if (scannerContext.mounted) {
                ScaffoldMessenger.of(scannerContext).showSnackBar(
                  SnackBar(
                    content: Text('Product with barcode $barcode not found'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _showScannerSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerSettingsWidget(),
      ),
    );
  }
}