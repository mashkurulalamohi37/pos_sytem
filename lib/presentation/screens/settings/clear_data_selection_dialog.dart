import 'package:flutter/material.dart';
import '../../../data/services/clear_data_service.dart';

class ClearDataSelectionDialog extends StatefulWidget {
  const ClearDataSelectionDialog({super.key});

  @override
  State<ClearDataSelectionDialog> createState() => _ClearDataSelectionDialogState();
}

class _ClearDataSelectionDialogState extends State<ClearDataSelectionDialog> {
  final Set<DataCollectionType> _selectedCollections = {};

  String _getCollectionName(DataCollectionType type) {
    switch (type) {
      case DataCollectionType.products:
        return 'Products';
      case DataCollectionType.sales:
        return 'Sales';
      case DataCollectionType.inventory:
        return 'Inventory (Stock Levels & Movements)';
      case DataCollectionType.customers:
        return 'Customers';
      case DataCollectionType.cashSessions:
        return 'Cash Sessions';
      case DataCollectionType.categories:
        return 'Product Categories';
      case DataCollectionType.taxRates:
        return 'Tax Rates';
      case DataCollectionType.branches:
        return 'Branches';
    }
  }

  IconData _getCollectionIcon(DataCollectionType type) {
    switch (type) {
      case DataCollectionType.products:
        return Icons.inventory_2;
      case DataCollectionType.sales:
        return Icons.receipt_long;
      case DataCollectionType.inventory:
        return Icons.warehouse;
      case DataCollectionType.customers:
        return Icons.people;
      case DataCollectionType.cashSessions:
        return Icons.account_balance_wallet;
      case DataCollectionType.categories:
        return Icons.category;
      case DataCollectionType.taxRates:
        return Icons.percent;
      case DataCollectionType.branches:
        return Icons.store;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Data to Clear'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select the data collections you want to delete:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...DataCollectionType.values.map((type) {
              final isSelected = _selectedCollections.contains(type);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedCollections.add(type);
                    } else {
                      _selectedCollections.remove(type);
                    }
                  });
                },
                title: Text(_getCollectionName(type)),
                secondary: Icon(_getCollectionIcon(type)),
                dense: true,
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'User accounts (admin, manager, cashier) will always be preserved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedCollections.isEmpty
              ? null
              : () => Navigator.pop(context, _selectedCollections),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

