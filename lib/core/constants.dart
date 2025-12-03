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
  static const String paymentBkash = 'bkash';
  static const String paymentNagad = 'nagad';
  static const String paymentRocket = 'rocket';
  static const String paymentAdvance = 'advance';
  static const String paymentDue = 'due';
  
  // List of all payment methods
  static const List<String> paymentMethods = [
    paymentCash,
    paymentCard,
    paymentBkash,
    paymentNagad,
    paymentRocket,
    paymentAdvance,
    paymentDue,
  ];
  
  // Payment method display names
  static String getPaymentMethodName(String method) {
    switch (method) {
      case paymentCash:
        return 'Cash';
      case paymentCard:
        return 'Card';
      case paymentBkash:
        return 'bKash';
      case paymentNagad:
        return 'Nagad';
      case paymentRocket:
        return 'Rocket';
      case paymentAdvance:
        return 'Advance';
      case paymentDue:
        return 'Due';
      default:
        return method.toUpperCase();
    }
  }

  // Loyalty Points
  // Points earned per TK spent (e.g., 0.01 means 1 point per 100 TK)
  static const double loyaltyPointsRate = 0.01; // 1 point per 100 TK

  // Company/Store Information (for receipts and invoices)
  static const String companyName = 'ARONIUM POS';
  static const String companyAddress = '123 Business Street, City, Country';
  static const String companyPhone = '+880 1234 567890';
  static const String companyEmail = 'info@aronium.com';
  static const String companyTaxNumber = 'TAX-123456789'; // GST/VAT/Tax ID
  static const String companyRegistrationNumber = 'REG-123456';
}

