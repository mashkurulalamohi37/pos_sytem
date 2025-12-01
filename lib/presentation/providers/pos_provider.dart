import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/entities/stock_movement.dart';
import '../../core/constants.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';
import '../screens/pos/cart_item.dart';

enum DiscountType {
  none,
  fixed,
  percentage,
}

class PosState {
  final List<CartItem> cartItems;
  final DiscountType discountType;
  final double discountValue; // Fixed amount in TK or percentage
  final double taxRate;
  final String? selectedCustomerId;
  final String paymentMethod;

  PosState({
    this.cartItems = const [],
    this.discountType = DiscountType.none,
    this.discountValue = 0.0,
    this.taxRate = 0.0,
    this.selectedCustomerId,
    this.paymentMethod = AppConstants.paymentCash,
  });

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double get discountAmount {
    if (discountType == DiscountType.none) return 0.0;
    if (discountType == DiscountType.fixed) {
      // Fixed amount discount (in TK)
      return discountValue;
    } else {
      // Percentage discount
      return subtotal * (discountValue / 100);
    }
  }

  double get subtotalAfterDiscount {
    return subtotal - discountAmount;
  }

  double get taxAmount {
    // Tax is calculated on subtotal after discount
    return subtotalAfterDiscount * (taxRate / 100);
  }

  double get totalAmount {
    return subtotalAfterDiscount + taxAmount;
  }

  PosState copyWith({
    List<CartItem>? cartItems,
    DiscountType? discountType,
    double? discountValue,
    double? taxRate,
    String? selectedCustomerId,
    String? paymentMethod,
  }) {
    return PosState(
      cartItems: cartItems ?? this.cartItems,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      taxRate: taxRate ?? this.taxRate,
      selectedCustomerId: selectedCustomerId ?? this.selectedCustomerId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class PosNotifier extends StateNotifier<PosState> {
  final ProductRepository _productRepository;
  final SaleRepository _saleRepository;
  final InventoryRepository _inventoryRepository;

  PosNotifier(
    this._productRepository,
    this._saleRepository,
    this._inventoryRepository,
  ) : super(PosState());

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = state.cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final existingItem = state.cartItems[existingIndex];
      final updatedItems = List<CartItem>.from(state.cartItems);
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      state = state.copyWith(cartItems: updatedItems);
    } else {
      state = state.copyWith(
        cartItems: [...state.cartItems, CartItem(product: product, quantity: quantity)],
      );
    }
  }

  void removeFromCart(int productId) {
    state = state.copyWith(
      cartItems: state.cartItems.where((item) => item.product.id != productId).toList(),
    );
  }

  void toggleProductInCart(Product product) {
    final existingIndex = state.cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Product is in cart, remove it
      removeFromCart(product.id!);
    } else {
      // Product is not in cart, add it with quantity 1
      addToCart(product, quantity: 1);
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final updatedItems = state.cartItems.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(cartItems: updatedItems);
  }

  void updateDiscount(int productId, double discount) {
    final updatedItems = state.cartItems.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(discount: discount);
      }
      return item;
    }).toList();

    state = state.copyWith(cartItems: updatedItems);
  }

  void setDiscount(DiscountType type, double value) {
    state = state.copyWith(
      discountType: type,
      discountValue: value,
    );
  }

  void clearDiscount() {
    state = state.copyWith(
      discountType: DiscountType.none,
      discountValue: 0.0,
    );
  }

  void setTaxRate(double rate) {
    state = state.copyWith(taxRate: rate);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setCustomer(String? customerId) {
    state = state.copyWith(selectedCustomerId: customerId);
  }

  void clearCart() {
    state = PosState(
      taxRate: state.taxRate,
      paymentMethod: state.paymentMethod,
      discountType: DiscountType.none,
      discountValue: 0.0,
    );
  }

  Future<bool> processPayment(int userId, int branchId) async {
    if (state.cartItems.isEmpty) return false;

    try {
      // Create sale items
      final saleItems = state.cartItems.map((cartItem) {
        return SaleItem(
          saleId: 0, // Will be set after sale creation
          productId: cartItem.product.id!,
          productName: cartItem.product.name,
          unitPrice: cartItem.unitPrice,
          quantity: cartItem.quantity,
          discount: cartItem.discount,
          total: cartItem.total,
          createdAt: DateTime.now(),
        );
      }).toList();

      // Create sale
      final sale = Sale(
        saleNumber: '',
        customerId: state.selectedCustomerId != null
            ? int.tryParse(state.selectedCustomerId!)
            : null,
        userId: userId,
        branchId: branchId,
        subtotal: state.subtotal,
        discountAmount: state.discountAmount,
        taxAmount: state.taxAmount,
        totalAmount: state.totalAmount,
        paymentMethod: state.paymentMethod,
        status: AppConstants.saleStatusCompleted,
        createdAt: DateTime.now(),
      );

      await _saleRepository.createSale(sale, saleItems);

      // Update stock levels
      for (final cartItem in state.cartItems) {
        await _inventoryRepository.createStockMovement(
          StockMovement(
            productId: cartItem.product.id!,
            branchId: branchId,
            type: AppConstants.stockMovementSale,
            quantity: -cartItem.quantity, // Negative for sale
            unitCost: cartItem.product.costPrice,
            reference: sale.saleNumber,
            createdAt: DateTime.now(),
            userId: userId,
          ),
        );
        
        // Update product's stockQuantity field
        final currentProduct = await _productRepository.getProductById(cartItem.product.id!);
        if (currentProduct != null) {
          final newStockQuantity = (currentProduct.stockQuantity - cartItem.quantity).clamp(0, double.infinity).toInt();
          await _productRepository.updateProduct(
            Product(
              id: currentProduct.id,
              name: currentProduct.name,
              sku: currentProduct.sku,
              barcode: currentProduct.barcode,
              costPrice: currentProduct.costPrice,
              sellingPrice: currentProduct.sellingPrice,
              categoryId: currentProduct.categoryId,
              stockQuantity: newStockQuantity,
              lowStockThreshold: currentProduct.lowStockThreshold,
              unit: currentProduct.unit,
              description: currentProduct.description,
              isActive: currentProduct.isActive,
              createdAt: currentProduct.createdAt,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      clearCart();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final posProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final productRepo = ref.watch(productRepositoryProvider);
  final saleRepo = ref.watch(saleRepositoryProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  return PosNotifier(productRepo, saleRepo, inventoryRepo);
});

