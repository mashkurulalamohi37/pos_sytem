import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sale.dart' as domain;
import '../../domain/entities/sale_item.dart' as domain;
import '../../domain/repositories/sale_repository.dart';
import 'firestore_utils.dart';

class SaleRepositoryFirestoreImpl implements SaleRepository {
  final FirebaseFirestore _firestore;

  SaleRepositoryFirestoreImpl(this._firestore);

  @override
  Future<domain.Sale> createSale(domain.Sale sale, List<domain.SaleItem> items) async {
    final saleNumber = sale.saleNumber.isEmpty
        ? 'SALE-${DateTime.now().millisecondsSinceEpoch}'
        : sale.saleNumber;
    
    final saleId = sale.id != null ? idToDocId(sale.id!) : generateDocId();
    final now = DateTime.now();

    // Create sale document
    await _firestore.collection('sales').doc(saleId).set({
      'saleNumber': saleNumber,
      'customerId': sale.customerId,
      'userId': sale.userId,
      'branchId': sale.branchId,
      'subtotal': sale.subtotal,
      'discountAmount': sale.discountAmount,
      'taxAmount': sale.taxAmount,
      'totalAmount': sale.totalAmount,
      'paymentMethod': sale.paymentMethod,
      'status': sale.status,
      'createdAt': Timestamp.fromDate(now),
    });

    // Create sale items as subcollection
    final itemsCollection = _firestore.collection('sales').doc(saleId).collection('items');
    for (final item in items) {
      final itemId = item.id != null ? idToDocId(item.id!) : generateDocId();
      await itemsCollection.doc(itemId).set({
        'productId': item.productId,
        'productName': item.productName,
        'unitPrice': item.unitPrice,
        'quantity': item.quantity,
        'discount': item.discount,
        'taxAmount': item.taxAmount,
        'total': item.total,
        'createdAt': Timestamp.fromDate(now),
      });
    }

    return sale.copyWith(id: docIdToId(saleId), saleNumber: saleNumber, createdAt: now);
  }

  @override
  Future<List<domain.Sale>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    int? branchId,
  }) async {
    Query query = _firestore.collection('sales');

    // Firestore requires composite indexes for multiple where clauses with orderBy
    // To avoid index requirements, we'll fetch all sales and filter in memory
    // This works fine for small to medium datasets
    
    // If we only have one filter, we can use it in the query
    if (startDate != null && endDate == null && userId == null && branchId == null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      query = query.orderBy('createdAt', descending: true);
    } else if (endDate != null && startDate == null && userId == null && branchId == null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      query = query.orderBy('createdAt', descending: true);
    } else {
      // For multiple filters, just order by createdAt and filter in memory
      query = query.orderBy('createdAt', descending: true);
    }

    final snapshot = await query.get();
    var sales = snapshot.docs.map((doc) => _toSale(doc)).toList();

    // Filter in memory for all other cases
    if (startDate != null) {
      sales = sales.where((s) => s.createdAt.isAfter(startDate.subtract(const Duration(seconds: 1)))).toList();
    }
    if (endDate != null) {
      sales = sales.where((s) => s.createdAt.isBefore(endDate.add(const Duration(days: 1)))).toList();
    }
    if (userId != null) {
      sales = sales.where((s) => s.userId == userId).toList();
    }
    if (branchId != null) {
      sales = sales.where((s) => s.branchId == branchId).toList();
    }

    return sales;
  }

  @override
  Future<domain.Sale?> getSaleById(int id) async {
    final doc = await _firestore.collection('sales').doc(idToDocId(id)).get();
    if (!doc.exists) return null;
    return _toSale(doc);
  }

  @override
  Future<domain.Sale?> getSaleByNumber(String saleNumber) async {
    final snapshot = await _firestore.collection('sales')
        .where('saleNumber', isEqualTo: saleNumber)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return _toSale(snapshot.docs.first);
  }

  @override
  Future<List<domain.SaleItem>> getSaleItems(int saleId) async {
    final snapshot = await _firestore
        .collection('sales')
        .doc(idToDocId(saleId))
        .collection('items')
        .get();
    
    return snapshot.docs.map((doc) => _toSaleItem(doc, saleId)).toList();
  }

  @override
  Future<void> deleteSale(int id) async {
    // Delete sale items subcollection
    final itemsSnapshot = await _firestore
        .collection('sales')
        .doc(idToDocId(id))
        .collection('items')
        .get();
    
    final batch = _firestore.batch();
    for (final doc in itemsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete sale document
    batch.delete(_firestore.collection('sales').doc(idToDocId(id)));
    
    await batch.commit();
  }

  domain.Sale _toSale(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return domain.Sale(
      id: docIdToId(doc.id),
      saleNumber: data['saleNumber'] as String,
      customerId: (data['customerId'] as num?)?.toInt(),
      userId: (data['userId'] as num?)?.toInt() ?? 0,
      branchId: (data['branchId'] as num?)?.toInt() ?? 0,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (data['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['paymentMethod'] as String? ?? 'cash',
      status: data['status'] as String? ?? 'completed',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  domain.SaleItem _toSaleItem(DocumentSnapshot doc, int saleId) {
    final data = doc.data() as Map<String, dynamic>;
    return domain.SaleItem(
      id: docIdToId(doc.id),
      saleId: saleId,
      productId: (data['productId'] as num?)?.toInt() ?? 0,
      productName: data['productName'] as String,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (data['taxAmount'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

extension SaleCopyWith on domain.Sale {
  domain.Sale copyWith({
    int? id,
    String? saleNumber,
    int? customerId,
    int? userId,
    int? branchId,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    List<domain.SaleItem>? items,
  }) {
    return domain.Sale(
      id: id ?? this.id,
      saleNumber: saleNumber ?? this.saleNumber,
      customerId: customerId ?? this.customerId,
      userId: userId ?? this.userId,
      branchId: branchId ?? this.branchId,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

