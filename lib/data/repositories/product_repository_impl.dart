import '../../domain/entities/product.dart' as domain;
import '../../domain/entities/category.dart' as domain;
import '../../domain/repositories/product_repository.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;

  ProductRepositoryImpl(this._db);

  @override
  Future<List<domain.Product>> getProducts({int? categoryId, bool includeInactive = false, String? search}) async {
    var query = _db.select(_db.products);
    
    // Only filter by active status if we don't want inactive products
    if (!includeInactive) {
      query = query..where((p) => p.isActive.equals(true));
    }

    if (categoryId != null) {
      query = query..where((p) => p.categoryId.equals(categoryId));
    }

    if (search != null && search.isNotEmpty) {
      // Simple search - filter in memory for now
      // TODO: Implement proper SQL LIKE search
    }

    final products = await query.get();
    var result = products.map((p) => _toProduct(p)).toList();
    
    // Filter by search if provided
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(searchLower) ||
               (p.barcode?.toLowerCase().contains(searchLower) ?? false) ||
               (p.sku?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }
    
    return result;
  }

  @override
  Future<domain.Product?> getProductById(int id) async {
    final product = await (_db.select(_db.products)
          ..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return product != null ? _toProduct(product) : null;
  }

  @override
  Future<domain.Product?> getProductByBarcode(String barcode) async {
    final product = await (_db.select(_db.products)
          ..where((p) => p.barcode.equals(barcode))
          ..where((p) => p.isActive.equals(true)))
        .getSingleOrNull();
    return product != null ? _toProduct(product) : null;
  }

  @override
  Future<domain.Product> createProduct(domain.Product product) async {
    final companion = ProductsCompanion(
      name: Value(product.name),
      sku: Value(product.sku),
      barcode: Value(product.barcode),
      costPrice: Value(product.costPrice),
      sellingPrice: Value(product.sellingPrice),
      categoryId: Value(product.categoryId),
      stockQuantity: Value(product.stockQuantity),
      lowStockThreshold: Value(product.lowStockThreshold),
      unit: Value(product.unit),
      description: Value(product.description),
      isActive: Value(product.isActive),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.products).insert(companion);
    return product.copyWith(id: id);
  }

  @override
  Future<domain.Product> updateProduct(domain.Product product) async {
    if (product.id == null) throw Exception('Product ID is required');

    await (_db.update(_db.products)..where((p) => p.id.equals(product.id!)))
        .write(ProductsCompanion(
      name: Value(product.name),
      sku: Value(product.sku),
      barcode: Value(product.barcode),
      costPrice: Value(product.costPrice),
      sellingPrice: Value(product.sellingPrice),
      categoryId: Value(product.categoryId),
      stockQuantity: Value(product.stockQuantity),
      lowStockThreshold: Value(product.lowStockThreshold),
      unit: Value(product.unit),
      description: Value(product.description),
      isActive: Value(product.isActive),
      updatedAt: Value(DateTime.now()),
    ));

    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await (_db.update(_db.products)..where((p) => p.id.equals(id)))
        .write(const ProductsCompanion(isActive: Value(false)));
  }

  @override
  Future<List<domain.Product>> getLowStockProducts() async {
    final products = await (_db.select(_db.products)
          ..where((p) => p.isActive.equals(true)))
        .get();

    return products
        .where((p) => p.stockQuantity <= p.lowStockThreshold)
        .map((p) => _toProduct(p))
        .toList();
  }

  // Categories
  @override
  Future<List<domain.Category>> getCategories() async {
    final categories = await _db.select(_db.categories).get();
    return categories.map((c) => _toCategory(c)).toList();
  }

  @override
  Future<domain.Category?> getCategoryById(int id) async {
    final category = await (_db.select(_db.categories)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return category != null ? _toCategory(category) : null;
  }

  @override
  Future<domain.Category> createCategory(domain.Category category) async {
    final companion = CategoriesCompanion(
      name: Value(category.name),
      description: Value(category.description),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.categories).insert(companion);
    return category.copyWith(id: id);
  }

  @override
  Future<domain.Category> updateCategory(domain.Category category) async {
    if (category.id == null) throw Exception('Category ID is required');

    await (_db.update(_db.categories)..where((c) => c.id.equals(category.id!)))
        .write(CategoriesCompanion(
      name: Value(category.name),
      description: Value(category.description),
      updatedAt: Value(DateTime.now()),
    ));

    return category;
  }

  @override
  Future<void> deleteCategory(int id) async {
    (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }

  domain.Product _toProduct(Product dbProduct) {
    return domain.Product(
      id: dbProduct.id,
      name: dbProduct.name,
      sku: dbProduct.sku,
      barcode: dbProduct.barcode,
      costPrice: dbProduct.costPrice,
      sellingPrice: dbProduct.sellingPrice,
      categoryId: dbProduct.categoryId,
      stockQuantity: dbProduct.stockQuantity,
      lowStockThreshold: dbProduct.lowStockThreshold,
      unit: dbProduct.unit,
      description: dbProduct.description,
      isActive: dbProduct.isActive,
      createdAt: dbProduct.createdAt,
      updatedAt: dbProduct.updatedAt,
    );
  }

  domain.Category _toCategory(Category dbCategory) {
    return domain.Category(
      id: dbCategory.id,
      name: dbCategory.name,
      description: dbCategory.description,
      createdAt: dbCategory.createdAt,
      updatedAt: dbCategory.updatedAt,
    );
  }
}

// Extension to add copyWith to Product
extension ProductCopyWith on domain.Product {
  domain.Product copyWith({
    int? id,
    String? name,
    String? sku,
    String? barcode,
    double? costPrice,
    double? sellingPrice,
    int? categoryId,
    int? stockQuantity,
    int? lowStockThreshold,
    String? unit,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return domain.Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      categoryId: categoryId ?? this.categoryId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Extension to add copyWith to Category
extension CategoryCopyWith on domain.Category {
  domain.Category copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return domain.Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

