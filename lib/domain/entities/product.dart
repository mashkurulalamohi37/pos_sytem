import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
  final String name;
  final String? sku;
  final String? barcode;
  final double costPrice;
  final double sellingPrice;
  final int? categoryId;
  final int stockQuantity;
  final int lowStockThreshold;
  final String unit;
  final String? description;
  final bool isActive;
  final List<int> taxRateIds; // List of tax rate IDs (for multiple taxes)
  final bool priceIncludesTax; // Whether the selling price includes tax
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.costPrice = 0.0,
    this.sellingPrice = 0.0,
    this.categoryId,
    this.stockQuantity = 0,
    this.lowStockThreshold = 10,
    this.unit = 'pcs',
    this.description,
    this.isActive = true,
    this.taxRateIds = const [],
    this.priceIncludesTax = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => stockQuantity <= lowStockThreshold;
  double get profitMargin => sellingPrice > 0 ? ((sellingPrice - costPrice) / sellingPrice) * 100 : 0;

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        barcode,
        costPrice,
        sellingPrice,
        categoryId,
        stockQuantity,
        lowStockThreshold,
        unit,
        description,
        isActive,
        taxRateIds,
        priceIncludesTax,
        createdAt,
        updatedAt,
      ];
}

