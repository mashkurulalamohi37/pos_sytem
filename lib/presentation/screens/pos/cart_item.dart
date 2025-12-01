import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final double discount;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0.0,
  });

  double get unitPrice => product.sellingPrice;
  double get total => (unitPrice * quantity) - discount;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? discount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  @override
  List<Object> get props => [product, quantity, discount];
}

