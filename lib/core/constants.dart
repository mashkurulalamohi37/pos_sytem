class AppConstants {
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleCashier = 'cashier';

  // Sale Status
  static const String saleStatusCompleted = 'completed';
  static const String saleStatusRefunded = 'refunded';

  // Cash Session Status
  static const String sessionStatusOpen = 'open';
  static const String sessionStatusClosed = 'closed';

  // Stock Movement Types
  static const String stockMovementSale = 'sale';
  static const String stockMovementPurchase = 'purchase';
  static const String stockMovementAdjustment = 'adjustment';
  static const String stockMovementTransfer = 'transfer';

  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentMobile = 'mobile';
  static const String paymentOther = 'other';

  // Loyalty Points
  // Points earned per TK spent (e.g., 0.01 means 1 point per 100 TK)
  static const double loyaltyPointsRate = 0.01; // 1 point per 100 TK
}

