import '../../../domain/entities/product.dart';
import 'cart_item.dart';

class TestCartData {
  static List<CartItem> getSampleCartItems() {
    return [
      CartItem(
        product: Product(
          id: 1,
          name: 'Ohi',
          sku: 'OHI001',
          barcode: '123456789',
          sellingPrice: 500.00,
          costPrice: 400.00,
          stockQuantity: 10,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 1,
        discount: 0.0,
      ),
      CartItem(
        product: Product(
          id: 2,
          name: 'Biscuit',
          sku: 'BIS001',
          barcode: '223456789',
          sellingPrice: 60.00,
          costPrice: 40.00,
          stockQuantity: 50,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 1,
        discount: 0.0,
      ),
      CartItem(
        product: Product(
          id: 3,
          name: 'Water',
          sku: 'WAT001',
          barcode: '323456789',
          sellingPrice: 10.00,
          costPrice: 5.00,
          stockQuantity: 100,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 1,
        discount: 0.0,
      ),
      CartItem(
        product: Product(
          id: 4,
          name: 'Mojo',
          sku: 'MOJ001',
          barcode: '423456789',
          sellingPrice: 20.00,
          costPrice: 15.00,
          stockQuantity: 30,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 1,
        discount: 0.0,
      ),
      CartItem(
        product: Product(
          id: 5,
          name: 'Noodles',
          sku: 'NOO001',
          barcode: '523456789',
          sellingPrice: 60.00,
          costPrice: 45.00,
          stockQuantity: 40,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 1,
        discount: 0.0,
      ),
      CartItem(
        product: Product(
          id: 6,
          name: 'Rice',
          sku: 'RIC001',
          barcode: '623456789',
          sellingPrice: 1550.00,
          costPrice: 380.00,
          stockQuantity: 25,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 1,
        discount: 0.0,
      ),
    ];
  }
}
