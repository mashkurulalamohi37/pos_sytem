import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/category.dart';
import 'product_form_screen.dart';
import 'category_form_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    // Load all products including inactive when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts(includeInactive: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productProvider);
    final authState = ref.watch(authProvider);
    final canEdit = (authState.user?.isAdmin ?? false) || (authState.user?.isManager ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        elevation: 0,
        actions: [
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryFormScreen()),
                );
              },
              tooltip: 'Manage Categories',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductFormScreen(),
                  ),
                ).then((_) => ref.read(productProvider.notifier).loadProducts(includeInactive: true));
              },
              tooltip: 'Add Product',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    ref.read(productProvider.notifier).search(value);
                  },
                ),
                const SizedBox(height: 8),
                
                // Category and Filter
                Row(
                  children: [
                    // Category Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: productsState.selectedCategoryId,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                            items: _buildCategoryDropdownItems(productsState.categories),
                            selectedItemBuilder: (context) {
                              return [
                                const Text('No Category'),
                                ...productsState.categories.map((category) {
                                  return Text(category.name);
                                }),
                              ];
                            },
                            onChanged: (int? value) {
                              ref.read(productProvider.notifier).filterByCategory(value);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Low Stock Filter
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showLowStockOnly = !_showLowStockOnly;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showLowStockOnly 
                            ? Theme.of(context).colorScheme.primary 
                            : Colors.grey.shade100,
                        foregroundColor: _showLowStockOnly 
                            ? Colors.white 
                            : Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Low Stock'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: productsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProductsList(productsState, canEdit),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductState state, bool canEdit) {
    var products = state.filteredProducts;
    if (_showLowStockOnly) {
      products = products.where((p) => p.isLowStock).toList();
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: products.length,
      // Performance: Add cache extent for better scrolling
      cacheExtent: 500,
      // Performance: Use addAutomaticKeepAlives to preserve state
      addAutomaticKeepAlives: false,
      // Performance: Use addRepaintBoundaries for better performance
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, canEdit);
      },
    );
  }

  Widget _buildProductCard(Product product, bool canEdit) {
    // Check if running on web for enhanced buttons
    final isWeb = MediaQuery.of(context).size.width > 600;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: canEdit && !isWeb
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormScreen(product: product),
                  ),
                ).then((_) => ref.read(productProvider.notifier).loadProducts(includeInactive: true));
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: product.isLowStock
                      ? Colors.blue.shade100
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.isLowStock 
                                ? Colors.orange.shade50 
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: product.isLowStock 
                                  ? Colors.orange.shade200 
                                  : Colors.green.shade200,
                            ),
                          ),
                          child: Text(
                            'Stock: ${product.stockQuantity}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: product.isLowStock ? Colors.orange.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Price and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TK ${product.sellingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cost: TK ${product.costPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (canEdit) ...[ 
                    const SizedBox(height: 12),
                    // Enhanced buttons for web, compact for mobile
                    isWeb 
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit Button - Enhanced for Web
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductFormScreen(product: product),
                                      ),
                                    ).then((_) => ref.read(productProvider.notifier).loadProducts(includeInactive: true));
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit, size: 16, color: Colors.blue.shade700),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Delete Button - Enhanced for Web
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _confirmDelete(product),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.delete, size: 16, color: Colors.red.shade700),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductFormScreen(product: product),
                                    ),
                                  ).then((_) => ref.read(productProvider.notifier).loadProducts(includeInactive: true));
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                onPressed: () => _confirmDelete(product),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<DropdownMenuItem<int?>> _buildCategoryDropdownItems(List<Category> categories) {
    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('No Category'),
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

  Future<void> _confirmDelete(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      try {
        await ref.read(productProvider.notifier).deleteProduct(product.id!);
        // Reload products with includeInactive to match the screen's initial load
        await ref.read(productProvider.notifier).loadProducts(includeInactive: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}