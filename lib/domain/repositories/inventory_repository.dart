import '../entities/stock_movement.dart';
import '../entities/product.dart';
import '../entities/branch.dart';

abstract class InventoryRepository {
  // Stock Levels
  Future<int> getStockLevel(int productId, int branchId);
  Future<void> updateStockLevel(int productId, int branchId, int quantity);
  Future<Map<int, int>> getStockLevelsByBranch(int branchId);

  // Stock Movements
  Future<StockMovement> createStockMovement(StockMovement movement);
  Future<List<StockMovement>> getStockMovements({
    int? productId,
    int? branchId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Branches
  Future<List<Branch>> getBranches();
  Future<Branch?> getBranchById(int id);
  Future<Branch> createBranch(Branch branch);
  Future<Branch> updateBranch(Branch branch);
  Future<void> deleteBranch(int id);
}

