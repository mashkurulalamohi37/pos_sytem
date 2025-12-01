import 'package:equatable/equatable.dart';
import 'sale_item.dart';

class Sale extends Equatable {
  final int? id;
  final String saleNumber;
  final int? customerId;
  final int userId;
  final int branchId;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final List<SaleItem>? items;

  const Sale({
    this.id,
    required this.saleNumber,
    this.customerId,
    required this.userId,
    required this.branchId,
    this.subtotal = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    required this.paymentMethod,
    this.status = 'completed',
    required this.createdAt,
    this.items,
  });

  @override
  List<Object?> get props => [
        id,
        saleNumber,
        customerId,
        userId,
        branchId,
        subtotal,
        discountAmount,
        taxAmount,
        totalAmount,
        paymentMethod,
        status,
        createdAt,
        items,
      ];
}

