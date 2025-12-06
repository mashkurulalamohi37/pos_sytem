import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async' show unawaited;
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/tax_rate_repository.dart';
import '../../domain/repositories/cash_session_repository.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/entities/stock_movement.dart';
import '../../core/constants.dart';
import 'repository_providers.dart';
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
  final String? selectedCustomerId;
  final String paymentMethod;

  PosState({
    this.cartItems = const [],
    this.discountType = DiscountType.none,
    this.discountValue = 0.0,
    this.selectedCustomerId,
    this.paymentMethod = AppConstants.paymentCash,
  });

  // Subtotal before overall discount (sum of all item subtotals after individual item discounts)
  // This includes individual item discounts but not the overall discount
  double get subtotal {
    // Sum of (item subtotal - item discount) for each item
    return cartItems.fold(0.0, (sum, item) => sum + (item.subtotal - item.discount));
  }

  // Total tax from all items
  double get taxAmount {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalTaxAmount);
  }

  // Individual item discounts total
  double get itemDiscountsTotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.discount);
  }

  // Discount amount (overall discount only, not individual item discounts)
  double get discountAmount {
    if (discountType == DiscountType.none) return 0.0;
    if (discountType == DiscountType.fixed) {
      // Fixed amount discount (in TK)
      return discountValue;
    } else {
      // Percentage discount on subtotal (which already has individual discounts applied)
      return subtotal * (discountValue / 100);
    }
  }

  // Subtotal after overall discount (individual item discounts already applied in subtotal)
  double get subtotalAfterDiscount {
    return subtotal - discountAmount;
  }

  // Total amount (subtotal after overall discount + tax)
  double get totalAmount {
    return subtotalAfterDiscount + taxAmount;
  }

  PosState copyWith({
    List<CartItem>? cartItems,
    DiscountType? discountType,
    double? discountValue,
    String? selectedCustomerId,
    String? paymentMethod,
  }) {
    return PosState(
      cartItems: cartItems ?? this.cartItems,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      selectedCustomerId: selectedCustomerId ?? this.selectedCustomerId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class PosNotifier extends StateNotifier<PosState> {
  final ProductRepository _productRepository;
  final SaleRepository _saleRepository;
  final InventoryRepository _inventoryRepository;
  final CustomerRepository _customerRepository;
  final TaxRateRepository _taxRateRepository;
  final CashSessionRepository? _cashSessionRepository;

  PosNotifier(
    this._productRepository,
    this._saleRepository,
    this._inventoryRepository,
    this._customerRepository,
    this._taxRateRepository,
    this._cashSessionRepository,
  ) : super(PosState());

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    // Load tax rates for this product
    List<double> taxRates = [];
    
    if (product.taxRateIds.isNotEmpty) {
      for (final taxRateId in product.taxRateIds) {
        final taxRate = await _taxRateRepository.getTaxRateById(taxRateId);
        if (taxRate != null) {
          taxRates.add(taxRate.rate);
        }
      }
    }

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
        cartItems: [...state.cartItems, CartItem(
          product: product, 
          quantity: quantity,
          taxRates: taxRates,
        )],
      );
    }
  }

  void removeFromCart(int productId) {
    state = state.copyWith(
      cartItems: state.cartItems.where((item) => item.product.id != productId).toList(),
    );
  }

  Future<void> toggleProductInCart(Product product) async {
    final existingIndex = state.cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Product is in cart, remove it
      removeFromCart(product.id!);
    } else {
      // Product is not in cart, add it with quantity 1
      await addToCart(product, quantity: 1);
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
  
  // Method to update all cart items at once
  void updateCartItems(List<CartItem> items) {
    state = state.copyWith(cartItems: items);
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


  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setCustomer(String? customerId) {
    state = state.copyWith(selectedCustomerId: customerId);
  }

  void clearCart() {
    state = PosState(
      paymentMethod: state.paymentMethod,
      discountType: DiscountType.none,
      discountValue: 0.0,
    );
  }

  // Optimized and faster payment processing
  Future<Sale?> processPayment(int userId, int branchId) async {
    if (state.cartItems.isEmpty) return null;

    try {
      // Create sale items efficiently in one go
      final saleItems = state.cartItems.map((cartItem) {
        return SaleItem(
          saleId: 0, // Will be set after sale creation
          productId: cartItem.product.id!,
          productName: cartItem.product.name,
          unitPrice: cartItem.unitPrice,
          quantity: cartItem.quantity,
          discount: cartItem.discount,
          taxAmount: cartItem.totalTaxAmount,
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

      // Create sale first - this is the most critical operation
      final createdSale = await _saleRepository.createSale(sale, saleItems);
      
      // Prepare a list of all inventory updates to be done in parallel
      List<Future> inventoryUpdates = [];
      
      // Add stock movement operations to our parallel tasks list
      for (final cartItem in state.cartItems) {
        inventoryUpdates.add(
          _inventoryRepository.createStockMovement(
            StockMovement(
              productId: cartItem.product.id!,
              branchId: branchId,
              type: AppConstants.stockMovementSale,
              quantity: -cartItem.quantity, // Negative for sale
              unitCost: cartItem.product.costPrice,
              reference: createdSale.saleNumber,
              createdAt: DateTime.now(),
              userId: userId,
            ),
          )
        );
      }
      
      // Add product stock quantity updates to our parallel tasks list
      for (final cartItem in state.cartItems) {
        inventoryUpdates.add(_updateProductStock(cartItem.product.id!, cartItem.quantity));
      }
      
      // Add cash session update to our parallel tasks list if needed
      if (createdSale.paymentMethod == AppConstants.paymentCash && _cashSessionRepository != null) {
        inventoryUpdates.add(_updateCashSession(createdSale));
      }
      
      // Add loyalty points update to our parallel tasks list if needed
      if (createdSale.customerId != null) {
        inventoryUpdates.add(_updateLoyaltyPoints(createdSale));
      }
      
      // Execute all updates in parallel for maximum speed
      // We don't need to wait for these to complete before showing receipt
      // These will continue in background after receipt is shown
      unawaited(Future.wait(inventoryUpdates).catchError((e) {
        print('Error during inventory updates: $e');
        // Non-critical errors, we can continue
      }));

      // Create sale with items for return
      final saleWithItems = Sale(
        id: createdSale.id,
        saleNumber: createdSale.saleNumber,
        customerId: createdSale.customerId,
        userId: createdSale.userId,
        branchId: createdSale.branchId,
        subtotal: createdSale.subtotal,
        discountAmount: createdSale.discountAmount,
        taxAmount: createdSale.taxAmount,
        totalAmount: createdSale.totalAmount,
        paymentMethod: createdSale.paymentMethod,
        status: createdSale.status,
        createdAt: createdSale.createdAt,
        items: saleItems,
      );
      
      // Clear cart immediately to give the user instant feedback
      clearCart();
      return saleWithItems;
    } catch (e) {
      print('Error processing payment: $e');
      return null;
    }
  }
  
  // Helper methods for parallel processing
  
  // Update product stock levels
  Future<void> _updateProductStock(int productId, int quantitySold) async {
    try {
      final currentProduct = await _productRepository.getProductById(productId);
      if (currentProduct != null) {
        final newStockQuantity = (currentProduct.stockQuantity - quantitySold).clamp(0, double.infinity).toInt();
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
    } catch (e) {
      print('Error updating product stock: $e');
    }
  }
  
  // Update cash session
  Future<void> _updateCashSession(Sale sale) async {
    try {
      final currentSession = await _cashSessionRepository!.getCurrentSession(sale.userId, sale.branchId);
      if (currentSession != null) {
        final newExpectedCash = currentSession.expectedCash + sale.totalAmount;
        await _cashSessionRepository!.updateExpectedCash(currentSession.id!, newExpectedCash);
      }
    } catch (e) {
      print('Error updating cash session: $e');
    }
  }
  
  // Update loyalty points
  Future<void> _updateLoyaltyPoints(Sale sale) async {
    try {
      final customer = await _customerRepository.getCustomerById(sale.customerId!);
      if (customer != null) {
        final pointsEarned = sale.totalAmount * AppConstants.loyaltyPointsRate;
        final newLoyaltyPoints = customer.loyaltyPoints + pointsEarned;
        await _customerRepository.updateLoyaltyPoints(sale.customerId!, newLoyaltyPoints);
      }
    } catch (e) {
      print('Error updating loyalty points: $e');
    }
  }
}

final posProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final productRepo = ref.watch(productRepositoryProvider);
  final saleRepo = ref.watch(saleRepositoryProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  final customerRepo = ref.watch(customerRepositoryProvider);
  final taxRateRepo = ref.watch(taxRateRepositoryProvider);
  final cashSessionRepo = ref.watch(cashSessionRepositoryProvider);
  return PosNotifier(productRepo, saleRepo, inventoryRepo, customerRepo, taxRateRepo, cashSessionRepo);
});

