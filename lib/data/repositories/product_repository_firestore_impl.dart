import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart' as domain;
import '../../domain/entities/category.dart' as domain;
import '../../domain/repositories/product_repository.dart';
import 'firestore_utils.dart';

class ProductRepositoryFirestoreImpl implements ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepositoryFirestoreImpl(this._firestore);

  @override
  Future<List<domain.Product>> getProducts({int? categoryId, String? search, bool includeInactive = false}) async {
    Query query = _firestore.collection('products');
    
    // Only filter by isActive if we don't want to include inactive products
    if (!includeInactive) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    final snapshot = await query.get();
    var products = snapshot.docs.map((doc) => _toProduct(doc)).toList();

    // Filter by search if provided
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      products = products.where((p) {
        return p.name.toLowerCase().contains(searchLower) ||
               (p.barcode?.toLowerCase().contains(searchLower) ?? false) ||
               (p.sku?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    return products;
  }

  @override
  Future<domain.Product?> getProductById(int id) async {
    final doc = await _firestore.collection('products').doc(idToDocId(id)).get();
    if (!doc.exists) return null;
    return _toProduct(doc);
  }

  @override
  Future<domain.Product?> getProductByBarcode(String barcode) async {
    final snapshot = await _firestore.collection('products')
        .where('barcode', isEqualTo: barcode)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return _toProduct(snapshot.docs.first);
  }

  @override
  Future<domain.Product> createProduct(domain.Product product) async {
    final docId = product.id != null ? idToDocId(product.id!) : generateDocId();
    final now = DateTime.now();
    
    await _firestore.collection('products').doc(docId).set({
      'name': product.name,
      'sku': product.sku,
      'barcode': product.barcode,
      'costPrice': product.costPrice,
      'sellingPrice': product.sellingPrice,
      'categoryId': product.categoryId,
      'stockQuantity': product.stockQuantity,
      'lowStockThreshold': product.lowStockThreshold,
      'unit': product.unit,
      'description': product.description,
      'isActive': product.isActive,
      'createdAt': Timestamp.fromDate(product.createdAt),
      'updatedAt': Timestamp.fromDate(now),
    });

    return product.copyWith(id: docIdToId(docId), updatedAt: now);
  }

  @override
  Future<domain.Product> updateProduct(domain.Product product) async {
    if (product.id == null) throw Exception('Product ID is required');

    await _firestore.collection('products').doc(idToDocId(product.id!)).update({
      'name': product.name,
      'sku': product.sku,
      'barcode': product.barcode,
      'costPrice': product.costPrice,
      'sellingPrice': product.sellingPrice,
      'categoryId': product.categoryId,
      'stockQuantity': product.stockQuantity,
      'lowStockThreshold': product.lowStockThreshold,
      'unit': product.unit,
      'description': product.description,
      'isActive': product.isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _firestore.collection('products').doc(idToDocId(id)).update({
      'isActive': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<List<domain.Product>> getLowStockProducts() async {
    final snapshot = await _firestore.collection('products')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => _toProduct(doc))
        .where((p) => p.stockQuantity <= p.lowStockThreshold)
        .toList();
  }

  // Categories
  @override
  Future<List<domain.Category>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => _toCategory(doc)).toList();
  }

  @override
  Future<domain.Category?> getCategoryById(int id) async {
    final doc = await _firestore.collection('categories').doc(idToDocId(id)).get();
    if (!doc.exists) return null;
    return _toCategory(doc);
  }

  @override
  Future<domain.Category> createCategory(domain.Category category) async {
    final docId = category.id != null ? idToDocId(category.id!) : generateDocId();
    final now = DateTime.now();
    
    await _firestore.collection('categories').doc(docId).set({
      'name': category.name,
      'description': category.description,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    return category.copyWith(id: docIdToId(docId), createdAt: now, updatedAt: now);
  }

  @override
  Future<domain.Category> updateCategory(domain.Category category) async {
    if (category.id == null) throw Exception('Category ID is required');

    await _firestore.collection('categories').doc(idToDocId(category.id!)).update({
      'name': category.name,
      'description': category.description,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    return category;
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _firestore.collection('categories').doc(idToDocId(id)).delete();
  }

  domain.Product _toProduct(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return domain.Product(
      id: docIdToId(doc.id),
      name: data['name'] as String,
      sku: data['sku'] as String?,
      barcode: data['barcode'] as String?,
      costPrice: (data['costPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (data['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      categoryId: (data['categoryId'] as num?)?.toInt(),
      stockQuantity: (data['stockQuantity'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 10,
      unit: data['unit'] as String? ?? 'pcs',
      description: data['description'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  domain.Category _toCategory(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return domain.Category(
      id: docIdToId(doc.id),
      name: data['name'] as String,
      description: data['description'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

