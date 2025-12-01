import 'package:flutter/material.dart';
import '../providers/pos_provider.dart';

class DiscountDialog extends StatefulWidget {
  final DiscountType currentType;
  final double currentValue;

  const DiscountDialog({
    super.key,
    required this.currentType,
    required this.currentValue,
  });

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  late DiscountType _selectedType;
  final _amountController = TextEditingController();
  final _percentageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentType;
    if (_selectedType == DiscountType.fixed) {
      _amountController.text = widget.currentValue > 0 ? widget.currentValue.toStringAsFixed(2) : '';
    } else if (_selectedType == DiscountType.percentage) {
      _percentageController.text = widget.currentValue > 0 ? widget.currentValue.toStringAsFixed(2) : '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  void _applyDiscount() {
    double value = 0.0;
    
    if (_selectedType == DiscountType.fixed) {
      value = double.tryParse(_amountController.text) ?? 0.0;
      if (value < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Discount amount cannot be negative'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_selectedType == DiscountType.percentage) {
      value = double.tryParse(_percentageController.text) ?? 0.0;
      if (value < 0 || value > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Percentage must be between 0 and 100'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    Navigator.pop(context, {
      'type': _selectedType,
      'value': value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Apply Discount'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discount Type Selection
            const Text(
              'Discount Type:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<DiscountType>(
              segments: const [
                ButtonSegment<DiscountType>(
                  value: DiscountType.none,
                  label: Text('None'),
                ),
                ButtonSegment<DiscountType>(
                  value: DiscountType.fixed,
                  label: Text('TK'),
                ),
                ButtonSegment<DiscountType>(
                  value: DiscountType.percentage,
                  label: Text('%'),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<DiscountType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            // Fixed Amount Input
            if (_selectedType == DiscountType.fixed) ...[
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Discount Amount (TK)',
                  prefixIcon: const Icon(Icons.currency_exchange),
                  border: const OutlineInputBorder(),
                  hintText: 'Enter discount amount',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            // Percentage Input
            if (_selectedType == DiscountType.percentage) ...[
              TextField(
                controller: _percentageController,
                decoration: InputDecoration(
                  labelText: 'Discount Percentage (%)',
                  prefixIcon: const Icon(Icons.percent),
                  border: const OutlineInputBorder(),
                  hintText: 'Enter percentage (0-100)',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, {'type': DiscountType.none, 'value': 0.0});
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applyDiscount,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

