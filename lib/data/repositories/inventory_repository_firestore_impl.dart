import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/stock_movement.dart' as domain;
import '../../domain/entities/branch.dart' as domain;
import '../../domain/repositories/inventory_repository.dart';
import 'firestore_utils.dart';

class InventoryRepositoryFirestoreImpl implements InventoryRepository {
  final FirebaseFirestore _firestore;

  InventoryRepositoryFirestoreImpl(this._firestore);

  @override
  Future<int> getStockLevel(int productId, int branchId) async {
    final doc = await _firestore
        .collection('stockLevels')
        .doc('${idToDocId(productId)}_${idToDocId(branchId)}')
        .get();
    
    if (!doc.exists) return 0;
    final data = doc.data()!;
    return (data['quantity'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> updateStockLevel(int productId, int branchId, int quantity) async {
    final docId = '${idToDocId(productId)}_${idToDocId(branchId)}';
    await _firestore.collection('stockLevels').doc(docId).set({
      'productId': productId,
      'branchId': branchId,
      'quantity': quantity,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  @override
  Future<Map<int, int>> getStockLevelsByBranch(int branchId) async {
    final snapshot = await _firestore.collection('stockLevels')
        .where('branchId', isEqualTo: branchId)
        .get();
    
    final Map<int, int> result = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final productId = (data['productId'] as num?)?.toInt();
      final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
      if (productId != null) {
        result[productId] = quantity;
      }
    }
    return result;
  }

  @override
  Future<domain.StockMovement> createStockMovement(domain.StockMovement movement) async {
    final docId = movement.id != null ? idToDocId(movement.id!) : generateDocId();
    final now = DateTime.now();

    await _firestore.collection('stockMovements').doc(docId).set({
      'productId': movement.productId,
      'branchId': movement.branchId,
      'type': movement.type,
      'quantity': movement.quantity,
      'unitCost': movement.unitCost,
      'reference': movement.reference,
      'notes': movement.notes,
      'userId': movement.userId,
      'createdAt': Timestamp.fromDate(now),
    });

    // Update stock level
    final currentStock = await getStockLevel(movement.productId, movement.branchId);
    await updateStockLevel(
      movement.productId,
      movement.branchId,
      currentStock + movement.quantity,
    );

    return movement.copyWith(id: docIdToId(docId), createdAt: now);
  }

  @override
  Future<List<domain.StockMovement>> getStockMovements({
    int? productId,
    int? branchId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore.collection('stockMovements');

    if (productId != null) {
      query = query.where('productId', isEqualTo: productId);
    }
    if (branchId != null) {
      query = query.where('branchId', isEqualTo: branchId);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    query = query.orderBy('createdAt', descending: true);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _toStockMovement(doc)).toList();
  }

  // Branches
  @override
  Future<List<domain.Branch>> getBranches() async {
    final snapshot = await _firestore.collection('branches').get();
    return snapshot.docs.map((doc) => _toBranch(doc)).toList();
  }

  @override
  Future<domain.Branch?> getBranchById(int id) async {
    final doc = await _firestore.collection('branches').doc(idToDocId(id)).get();
    if (!doc.exists) return null;
    return _toBranch(doc);
  }

  @override
  Future<domain.Branch> createBranch(domain.Branch branch) async {
    final docId = branch.id != null ? idToDocId(branch.id!) : generateDocId();
    final now = DateTime.now();

    await _firestore.collection('branches').doc(docId).set({
      'name': branch.name,
      'address': branch.address,
      'phone': branch.phone,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    return branch.copyWith(id: docIdToId(docId), createdAt: now, updatedAt: now);
  }

  @override
  Future<domain.Branch> updateBranch(domain.Branch branch) async {
    if (branch.id == null) throw Exception('Branch ID is required');

    await _firestore.collection('branches').doc(idToDocId(branch.id!)).update({
      'name': branch.name,
      'address': branch.address,
      'phone': branch.phone,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    return branch;
  }

  @override
  Future<void> deleteBranch(int id) async {
    await _firestore.collection('branches').doc(idToDocId(id)).delete();
  }

  domain.StockMovement _toStockMovement(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return domain.StockMovement(
      id: docIdToId(doc.id),
      productId: (data['productId'] as num?)?.toInt() ?? 0,
      branchId: (data['branchId'] as num?)?.toInt() ?? 0,
      type: data['type'] as String,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitCost: (data['unitCost'] as num?)?.toDouble(),
      reference: data['reference'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: (data['userId'] as num?)?.toInt(),
    );
  }

  domain.Branch _toBranch(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return domain.Branch(
      id: docIdToId(doc.id),
      name: data['name'] as String,
      address: data['address'] as String?,
      phone: data['phone'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

