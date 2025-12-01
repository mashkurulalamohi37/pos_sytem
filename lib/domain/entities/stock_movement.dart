import 'package:equatable/equatable.dart';

class StockMovement extends Equatable {
  final int? id;
  final int productId;
  final int branchId;
  final String type; // sale, purchase, adjustment, transfer
  final int quantity; // positive for in, negative for out
  final double? unitCost;
  final String? reference; // sale_id, purchase_id, etc.
  final String? notes;
  final DateTime createdAt;
  final int? userId;

  const StockMovement({
    this.id,
    required this.productId,
    required this.branchId,
    required this.type,
    required this.quantity,
    this.unitCost,
    this.reference,
    this.notes,
    required this.createdAt,
    this.userId,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        branchId,
        type,
        quantity,
        unitCost,
        reference,
        notes,
        createdAt,
        userId,
      ];
}

