import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/branch.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'repository_providers.dart';

class InventoryState {
  final List<Branch> branches;
  final List<StockMovement> movements;
  final bool isLoading;
  final int? selectedBranchId;

  InventoryState({
    this.branches = const [],
    this.movements = const [],
    this.isLoading = false,
    this.selectedBranchId,
  });

  InventoryState copyWith({
    List<Branch>? branches,
    List<StockMovement>? movements,
    bool? isLoading,
    int? selectedBranchId,
  }) {
    return InventoryState(
      branches: branches ?? this.branches,
      movements: movements ?? this.movements,
      isLoading: isLoading ?? this.isLoading,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final InventoryRepository _inventoryRepository;

  InventoryNotifier(this._inventoryRepository) : super(InventoryState()) {
    loadBranches();
    loadMovements();
  }

  Future<void> loadBranches() async {
    try {
      final branches = await _inventoryRepository.getBranches();
      state = state.copyWith(branches: branches);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadMovements({int? branchId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final movements = await _inventoryRepository.getStockMovements(branchId: branchId);
      state = state.copyWith(
        movements: movements,
        isLoading: false,
        selectedBranchId: branchId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> createBranch(Branch branch) async {
    try {
      await _inventoryRepository.createBranch(branch);
      await loadBranches();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBranch(Branch branch) async {
    try {
      await _inventoryRepository.updateBranch(branch);
      await loadBranches();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> adjustStock(int productId, int branchId, int quantity, String reason, int userId) async {
    try {
      await _inventoryRepository.createStockMovement(
        StockMovement(
          productId: productId,
          branchId: branchId,
          type: 'adjustment',
          quantity: quantity,
          notes: reason,
          createdAt: DateTime.now(),
          userId: userId,
        ),
      );
      await loadMovements(branchId: branchId);
    } catch (e) {
      rethrow;
    }
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  return InventoryNotifier(inventoryRepo);
});

