import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tax_rate_provider.dart';
import '../../../domain/entities/tax_rate.dart';

class TaxRateFormScreen extends ConsumerStatefulWidget {
  final TaxRate? taxRate;

  const TaxRateFormScreen({super.key, this.taxRate});

  @override
  ConsumerState<TaxRateFormScreen> createState() => _TaxRateFormScreenState();
}

class _TaxRateFormScreenState extends ConsumerState<TaxRateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.taxRate != null) {
      _nameController.text = widget.taxRate!.name;
      _rateController.text = widget.taxRate!.rate.toString();
      _descriptionController.text = widget.taxRate!.description ?? '';
      _isActive = widget.taxRate!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    print('DEBUG TaxRateForm: Saving tax rate');
    if (!_formKey.currentState!.validate()) {
      print('DEBUG TaxRateForm: Form validation failed');
      return;
    }

    if (_isLoading) {
      print('DEBUG TaxRateForm: Already loading, preventing double submission');
      return;
    }

    final rate = double.tryParse(_rateController.text);
    print('DEBUG TaxRateForm: Parsed rate: $rate');
    
    if (rate == null || rate < 0) {
      print('DEBUG TaxRateForm: Invalid rate value');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid tax rate'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    print('DEBUG TaxRateForm: Form validated, proceeding to save');

    try {
      final now = DateTime.now();
      final taxRate = TaxRate(
        id: widget.taxRate?.id,
        name: _nameController.text.trim(),
        rate: rate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: _isActive,
        createdAt: widget.taxRate?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.taxRate == null) {
        await ref.read(taxRateProvider.notifier).createTaxRate(taxRate);
      } else {
        await ref.read(taxRateProvider.notifier).updateTaxRate(taxRate);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.taxRate == null
                ? 'Tax rate created successfully'
                : 'Tax rate updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving tax rate: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taxRate == null ? 'Add Tax Rate' : 'Edit Tax Rate'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tax Name *',
                  hintText: 'e.g., VAT, GST, Sales Tax',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter tax name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Rate
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Tax Rate (%) *',
                  hintText: 'e.g., 15.0 for 15%',
                  prefixIcon: Icon(Icons.percent),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter tax rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0) {
                    return 'Please enter a valid tax rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Active Toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Active'),
                  subtitle: const Text('Tax rate will be available for products'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.taxRate == null ? 'Create Tax Rate' : 'Update Tax Rate',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

