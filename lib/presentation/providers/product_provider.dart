import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';
import 'repository_providers.dart';

class ProductState {
  final List<Product> products;
  final List<Category> categories;
  final List<Product> filteredProducts;
  final String searchQuery;
  final int? selectedCategoryId;
  final bool isLoading;

  ProductState({
    this.products = const [],
    this.categories = const [],
    this.filteredProducts = const [],
    this.searchQuery = '',
    this.selectedCategoryId,
    this.isLoading = false,
  });

  ProductState copyWith({
    List<Product>? products,
    List<Category>? categories,
    List<Product>? filteredProducts,
    String? searchQuery,
    Object? selectedCategoryId = _sentinel,
    bool? isLoading,
  }) {
    return ProductState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId == _sentinel ? this.selectedCategoryId : selectedCategoryId as int?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  static const Object _sentinel = Object();
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _productRepository;

  ProductNotifier(this._productRepository) : super(ProductState()) {
    // Load only active products by default (for POS)
    loadProducts(includeInactive: false);
    loadCategories();
  }

  Future<void> loadProducts({bool includeInactive = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      final products = await _productRepository.getProducts(includeInactive: includeInactive);
      state = state.copyWith(
        products: products,
        isLoading: false,
      );
      // Reapply filters after loading products
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        filteredProducts: [],
      );
    }
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _productRepository.getCategories();
      state = state.copyWith(categories: categories);
    } catch (e) {
      // Handle error
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void filterByCategory(int? categoryId) {
    // Explicitly set selectedCategoryId (even if null) to show all categories
    // When categoryId is null, it means "All Categories" - show all products
    final newState = state.copyWith(selectedCategoryId: categoryId);
    state = newState;
    _applyFilters();
  }

  void _applyFilters() {
    // Start with all products
    var filtered = List<Product>.from(state.products);

    // Apply category filter only if a category is selected
    // When selectedCategoryId is null, show ALL products (no category filtering)
    if (state.selectedCategoryId != null) {
      filtered = filtered.where((p) => p.categoryId == state.selectedCategoryId).toList();
    }

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.barcode?.toLowerCase().contains(query) ?? false) ||
            (p.sku?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Always update filteredProducts, even if it's the same as products
    state = state.copyWith(filteredProducts: filtered);
  }

  Future<void> createProduct(Product product) async {
    try {
      final created = await _productRepository.createProduct(product);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _productRepository.updateProduct(product);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _productRepository.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createCategory(Category category) async {
    try {
      await _productRepository.createCategory(category);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _productRepository.updateCategory(category);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _productRepository.deleteCategory(id);
      await loadCategories();
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      return await _productRepository.getProductByBarcode(barcode);
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> isSkuUnique(String sku, {int? excludeProductId}) async {
    try {
      // Check if any product has this SKU
      final products = state.products.where((p) => 
        p.sku?.toLowerCase() == sku.toLowerCase() && 
        p.id != excludeProductId
      ).toList();
      
      return products.isEmpty;
    } catch (e) {
      // In case of error, assume it's not unique to be safe
      return false;
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final productRepo = ref.watch(productRepositoryProvider);
  return ProductNotifier(productRepo);
});

