import '../../domain/entities/sale.dart' as domain;
import '../../domain/entities/sale_item.dart' as domain;
import '../../domain/repositories/sale_repository.dart';
import '../database/app_database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

class SaleRepositoryImpl implements SaleRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SaleRepositoryImpl(this._db);

  @override
  Future<domain.Sale> createSale(domain.Sale sale, List<domain.SaleItem> items) async {
    // Generate sale number if not provided
    final saleNumber = sale.saleNumber.isEmpty
        ? 'SALE-${DateTime.now().millisecondsSinceEpoch}'
        : sale.saleNumber;

    final saleCompanion = SalesCompanion(
      saleNumber: Value(saleNumber),
      customerId: Value(sale.customerId),
      userId: Value(sale.userId),
      branchId: Value(sale.branchId),
      subtotal: Value(sale.subtotal),
      discountAmount: Value(sale.discountAmount),
      taxAmount: Value(sale.taxAmount),
      totalAmount: Value(sale.totalAmount),
      paymentMethod: Value(sale.paymentMethod),
      status: Value(sale.status),
      createdAt: Value(DateTime.now()),
    );

    final saleId = await _db.into(_db.sales).insert(saleCompanion);

    // Insert sale items
    for (final item in items) {
      await _db.into(_db.saleItems).insert(SaleItemsCompanion(
            saleId: Value(saleId),
            productId: Value(item.productId),
            productName: Value(item.productName),
            unitPrice: Value(item.unitPrice),
            quantity: Value(item.quantity),
            discount: Value(item.discount),
            total: Value(item.total),
            createdAt: Value(DateTime.now()),
          ));
    }

    return sale.copyWith(id: saleId, saleNumber: saleNumber);
  }

  @override
  Future<List<domain.Sale>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    int? branchId,
  }) async {
    var query = _db.select(_db.sales);

    if (startDate != null) {
      query = query..where((s) => s.createdAt.isBiggerOrEqual(Constant(startDate)));
    }
    if (endDate != null) {
      query = query..where((s) => s.createdAt.isSmallerOrEqual(Constant(endDate)));
    }
    if (userId != null) {
      query = query..where((s) => s.userId.equals(userId));
    }
    if (branchId != null) {
      query = query..where((s) => s.branchId.equals(branchId));
    }

    query = query..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);

    final sales = await query.get();
    return sales.map((s) => _toSale(s)).toList();
  }

  @override
  Future<domain.Sale?> getSaleById(int id) async {
    final sale = await (_db.select(_db.sales)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    return sale != null ? _toSale(sale) : null;
  }

  @override
  Future<domain.Sale?> getSaleByNumber(String saleNumber) async {
    final sale = await (_db.select(_db.sales)
          ..where((s) => s.saleNumber.equals(saleNumber)))
        .getSingleOrNull();
    return sale != null ? _toSale(sale) : null;
  }

  @override
  Future<List<domain.SaleItem>> getSaleItems(int saleId) async {
    final items = await (_db.select(_db.saleItems)
          ..where((si) => si.saleId.equals(saleId)))
        .get();
    return items.map((i) => _toSaleItem(i)).toList();
  }

  @override
  Future<void> deleteSale(int id) async {
    // Delete sale items first
    await (_db.delete(_db.saleItems)..where((si) => si.saleId.equals(id))).go();
    // Delete sale
    await (_db.delete(_db.sales)..where((s) => s.id.equals(id))).go();
  }

  domain.Sale _toSale(Sale dbSale) {
    return domain.Sale(
      id: dbSale.id,
      saleNumber: dbSale.saleNumber,
      customerId: dbSale.customerId,
      userId: dbSale.userId,
      branchId: dbSale.branchId,
      subtotal: dbSale.subtotal,
      discountAmount: dbSale.discountAmount,
      taxAmount: dbSale.taxAmount,
      totalAmount: dbSale.totalAmount,
      paymentMethod: dbSale.paymentMethod,
      status: dbSale.status,
      createdAt: dbSale.createdAt,
    );
  }

  domain.SaleItem _toSaleItem(SaleItem dbItem) {
    return domain.SaleItem(
      id: dbItem.id,
      saleId: dbItem.saleId,
      productId: dbItem.productId,
      productName: dbItem.productName,
      unitPrice: dbItem.unitPrice,
      quantity: dbItem.quantity,
      discount: dbItem.discount,
      total: dbItem.total,
      createdAt: dbItem.createdAt,
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

