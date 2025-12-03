import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final double discount;
  final List<double> taxRates; // Tax rates for this product

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0.0,
    this.taxRates = const [],
  });

  double get unitPrice => product.sellingPrice;
  
  // Calculate net price (price without tax) if price includes tax
  double get netUnitPrice {
    if (!product.priceIncludesTax || taxRates.isEmpty) {
      return unitPrice;
    }
    // Sum all tax rates
    final totalTaxRate = taxRates.fold(0.0, (sum, rate) => sum + rate);
    // Net price = Price / (1 + total tax rate)
    return unitPrice / (1 + (totalTaxRate / 100));
  }
  
  // Calculate tax amount per unit
  double get unitTaxAmount {
    if (taxRates.isEmpty) return 0.0;
    
    if (product.priceIncludesTax) {
      // Tax is included in price, so calculate: Tax = Price - Net Price
      return unitPrice - netUnitPrice;
    } else {
      // Tax is exclusive, so calculate: Tax = Net Price × Tax Rate
      final totalTaxRate = taxRates.fold(0.0, (sum, rate) => sum + rate);
      return netUnitPrice * (totalTaxRate / 100);
    }
  }
  
  // Total tax for this item (quantity × unit tax)
  double get totalTaxAmount => unitTaxAmount * quantity;
  
  // Subtotal before tax
  double get subtotal => netUnitPrice * quantity;
  
  // Total after discount and tax
  double get total {
    final afterDiscount = subtotal - discount;
    if (product.priceIncludesTax) {
      // If price includes tax, total is just price - discount
      return afterDiscount;
    } else {
      // If price excludes tax, add tax
      return afterDiscount + totalTaxAmount;
    }
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? discount,
    List<double>? taxRates,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      taxRates: taxRates ?? this.taxRates,
    );
  }

  @override
  List<Object> get props => [product, quantity, discount, taxRates];
}

