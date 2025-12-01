import '../../domain/entities/stock_movement.dart' as domain;
import '../../domain/entities/branch.dart' as domain;
import '../../domain/repositories/inventory_repository.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase _db;

  InventoryRepositoryImpl(this._db);

  @override
  Future<int> getStockLevel(int productId, int branchId) async {
    final stock = await (_db.select(_db.stockLevels)
          ..where((sl) => sl.productId.equals(productId))
          ..where((sl) => sl.branchId.equals(branchId)))
        .getSingleOrNull();
    return stock?.quantity ?? 0;
  }

  @override
  Future<void> updateStockLevel(int productId, int branchId, int quantity) async {
    final existing = await (_db.select(_db.stockLevels)
          ..where((sl) => sl.productId.equals(productId))
          ..where((sl) => sl.branchId.equals(branchId)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.stockLevels)
            ..where((sl) => sl.productId.equals(productId))
            ..where((sl) => sl.branchId.equals(branchId)))
          .write(StockLevelsCompanion(
            quantity: Value(quantity),
            updatedAt: Value(DateTime.now()),
          ));
    } else {
      await _db.into(_db.stockLevels).insert(StockLevelsCompanion(
            productId: Value(productId),
            branchId: Value(branchId),
            quantity: Value(quantity),
            updatedAt: Value(DateTime.now()),
          ));
    }
  }

  @override
  Future<Map<int, int>> getStockLevelsByBranch(int branchId) async {
    final stocks = await (_db.select(_db.stockLevels)
          ..where((sl) => sl.branchId.equals(branchId)))
        .get();
    return {for (var s in stocks) s.productId: s.quantity};
  }

  @override
  Future<domain.StockMovement> createStockMovement(domain.StockMovement movement) async {
    final companion = StockMovementsCompanion(
      productId: Value(movement.productId),
      branchId: Value(movement.branchId),
      type: Value(movement.type),
      quantity: Value(movement.quantity),
      unitCost: Value(movement.unitCost),
      reference: Value(movement.reference),
      notes: Value(movement.notes),
      createdAt: Value(DateTime.now()),
      userId: Value(movement.userId),
    );

    final id = await _db.into(_db.stockMovements).insert(companion);

    // Update stock level
    final currentStock = await getStockLevel(movement.productId, movement.branchId);
    await updateStockLevel(
      movement.productId,
      movement.branchId,
      currentStock + movement.quantity,
    );

    return movement.copyWith(id: id);
  }

  @override
  Future<List<domain.StockMovement>> getStockMovements({
    int? productId,
    int? branchId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _db.select(_db.stockMovements);

    if (productId != null) {
      query = query..where((sm) => sm.productId.equals(productId));
    }
    if (branchId != null) {
      query = query..where((sm) => sm.branchId.equals(branchId));
    }
    if (type != null) {
      query = query..where((sm) => sm.type.equals(type));
    }
    if (startDate != null) {
      query = query..where((sm) => sm.createdAt.isBiggerOrEqual(Constant(startDate)));
    }
    if (endDate != null) {
      query = query..where((sm) => sm.createdAt.isSmallerOrEqual(Constant(endDate)));
    }

    query = query..orderBy([(sm) => OrderingTerm.desc(sm.createdAt)]);

    final movements = await query.get();
    return movements.map((m) => _toStockMovement(m)).toList();
  }

  // Branches
  @override
  Future<List<domain.Branch>> getBranches() async {
    final branches = await _db.select(_db.branches).get();
    return branches.map((b) => _toBranch(b)).toList();
  }

  @override
  Future<domain.Branch?> getBranchById(int id) async {
    final branch = await (_db.select(_db.branches)..where((b) => b.id.equals(id)))
        .getSingleOrNull();
    return branch != null ? _toBranch(branch) : null;
  }

  @override
  Future<domain.Branch> createBranch(domain.Branch branch) async {
    final companion = BranchesCompanion(
      name: Value(branch.name),
      address: Value(branch.address),
      phone: Value(branch.phone),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.branches).insert(companion);
    return branch.copyWith(id: id);
  }

  @override
  Future<domain.Branch> updateBranch(domain.Branch branch) async {
    if (branch.id == null) throw Exception('Branch ID is required');

    await (_db.update(_db.branches)..where((b) => b.id.equals(branch.id!)))
        .write(BranchesCompanion(
      name: Value(branch.name),
      address: Value(branch.address),
      phone: Value(branch.phone),
      updatedAt: Value(DateTime.now()),
    ));

    return branch;
  }

  @override
  Future<void> deleteBranch(int id) async {
    await (_db.delete(_db.branches)..where((b) => b.id.equals(id))).go();
  }

  domain.StockMovement _toStockMovement(StockMovement dbMovement) {
    return domain.StockMovement(
      id: dbMovement.id,
      productId: dbMovement.productId,
      branchId: dbMovement.branchId,
      type: dbMovement.type,
      quantity: dbMovement.quantity,
      unitCost: dbMovement.unitCost,
      reference: dbMovement.reference,
      notes: dbMovement.notes,
      createdAt: dbMovement.createdAt,
      userId: dbMovement.userId,
    );
  }

  domain.Branch _toBranch(Branche dbBranch) {
    return domain.Branch(
      id: dbBranch.id,
      name: dbBranch.name,
      address: dbBranch.address,
      phone: dbBranch.phone,
      createdAt: dbBranch.createdAt,
      updatedAt: dbBranch.updatedAt,
    );
  }
}

extension StockMovementCopyWith on domain.StockMovement {
  domain.StockMovement copyWith({
    int? id,
    int? productId,
    int? branchId,
    String? type,
    int? quantity,
    double? unitCost,
    String? reference,
    String? notes,
    DateTime? createdAt,
    int? userId,
  }) {
    return domain.StockMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      branchId: branchId ?? this.branchId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}

extension BranchCopyWith on domain.Branch {
  domain.Branch copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return domain.Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

