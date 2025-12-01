import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/stock_movement.dart';
import '../../../domain/entities/product.dart';
import 'stock_adjustment_screen.dart';
import 'branch_form_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);
    final authState = ref.watch(authProvider);
    final canEdit = (authState.user?.isAdmin ?? false) || (authState.user?.isManager ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        elevation: 0,
        actions: [
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.store),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BranchFormScreen()),
                );
              },
              tooltip: 'Manage Branches',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StockAdjustmentScreen()),
                ).then((_) => ref.read(inventoryProvider.notifier).loadMovements());
              },
              tooltip: 'Stock Adjustment',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Branch Filter
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<int?>(
                value: _selectedBranchId,
                hint: const Text('All Branches'),
                isExpanded: true,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Branches'),
                  ),
                  ...inventoryState.branches.map((branch) {
                    return DropdownMenuItem<int?>(
                      value: branch.id,
                      child: Text(branch.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBranchId = value;
                  });
                  ref.read(inventoryProvider.notifier).loadMovements(branchId: value);
                },
              ),
            ),
          ),
          // Movements List
          Expanded(
            child: inventoryState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : inventoryState.movements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No stock movements found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: inventoryState.movements.length,
                        itemBuilder: (context, index) {
                          final movement = inventoryState.movements[index];
                          return _buildMovementCard(movement);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementCard(StockMovement movement) {
    final isPositive = movement.quantity > 0;
    final productsState = ref.watch(productProvider);
    Product? product;
    try {
      product = productsState.products.firstWhere(
        (p) => p.id == movement.productId,
      );
    } catch (e) {
      product = null;
    }
    final productName = product?.name ?? 'Product #${movement.productId}';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (movement.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      movement.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : ''}${movement.quantity}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                Text(
                  movement.createdAt.toString().substring(0, 10),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
