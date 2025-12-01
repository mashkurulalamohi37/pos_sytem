import '../entities/product.dart';
import '../entities/category.dart';

abstract class ProductRepository {
  // Products
  Future<List<Product>> getProducts({int? categoryId, String? search, bool includeInactive = false});
  Future<Product?> getProductById(int id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<List<Product>> getLowStockProducts();

  // Categories
  Future<List<Category>> getCategories();
  Future<Category?> getCategoryById(int id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(int id);
}

