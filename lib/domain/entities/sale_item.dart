import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final int? id;
  final int saleId;
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double discount;
  final double taxAmount; // Tax amount for this item
  final double total;
  final DateTime createdAt;

  const SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.discount = 0.0,
    this.taxAmount = 0.0,
    required this.total,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        saleId,
        productId,
        productName,
        unitPrice,
        quantity,
        discount,
        taxAmount,
        total,
        createdAt,
      ];
}

