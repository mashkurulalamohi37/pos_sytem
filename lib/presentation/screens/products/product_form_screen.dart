import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../providers/tax_rate_provider.dart';
import '../../providers/sku_settings_provider.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/category.dart';
import '../../../data/services/sku_generator_service.dart';
import '../../widgets/barcode_scanner_widget.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController();

  int? _selectedCategoryId;
  List<int> _selectedTaxRateIds = [];
  bool _priceIncludesTax = false;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load categories when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadCategories();
      
      // Auto-generate SKU for new products if enabled
      if (widget.product == null) {
        final skuSettings = ref.read(skuSettingsProvider);
        if (skuSettings.autoGenerate) {
          _generateSku();
        }
      }
    });
    
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _skuController.text = widget.product!.sku ?? '';
      _barcodeController.text = widget.product!.barcode ?? '';
      _costPriceController.text = widget.product!.costPrice.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _stockController.text = widget.product!.stockQuantity.toString();
      _lowStockThresholdController.text = widget.product!.lowStockThreshold.toString();
      _descriptionController.text = widget.product!.description ?? '';
      _unitController.text = widget.product!.unit;
      _selectedCategoryId = widget.product!.categoryId;
      _selectedTaxRateIds = List<int>.from(widget.product!.taxRateIds);
      _priceIncludesTax = widget.product!.priceIncludesTax;
      _isActive = widget.product!.isActive;
    } else {
      _lowStockThresholdController.text = '10';
      _unitController.text = 'pcs';
      _stockController.text = '0';
      _costPriceController.text = '0.0';
      _sellingPriceController.text = '0.0';
    }
  }
  
  Future<void> _generateSku() async {
    final skuSettings = ref.read(skuSettingsProvider);
    
    // Get the selected category name if available
    String? categoryPrefix;
    if (_selectedCategoryId != null) {
      final categories = ref.read(productProvider).categories;
      final selectedCategory = categories.firstWhere(
        (category) => category.id == _selectedCategoryId,
        orElse: () => Category(
          name: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      categoryPrefix = selectedCategory.name.isNotEmpty ? selectedCategory.name.substring(0, min(3, selectedCategory.name.length)) : null;
    }
    
    // Get the next sequential number
    final sequentialNumber = await ref.read(skuSettingsProvider.notifier).getNextSequentialNumber();
    
    // Generate the SKU
    final sku = SkuGeneratorService.generateSku(
      pattern: skuSettings.pattern,
      productName: _nameController.text.isNotEmpty ? _nameController.text : 'Product',
      categoryPrefix: categoryPrefix,
      sequentialNumber: sequentialNumber,
    );
    
    setState(() {
      _skuController.text = sku;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<int?>> _buildCategoryItems(List<Category> categories) {
    final items = <DropdownMenuItem<int?>>[];
    
    if (categories.isEmpty) {
      return items; // Return empty list if no categories
    }
    
    // Get parent categories (categories without a parent)
    final parentCategories = categories
        .where((c) => c.parentCategoryId == null && c.id != null)
        .toList();
    
    for (final parent in parentCategories) {
      if (parent.id == null) continue; // Skip if no ID
      
      // Add parent category
      items.add(
        DropdownMenuItem<int?>(
          value: parent.id,
          child: Text(parent.name),
        ),
      );
      
      // Add subcategories under this parent
      final subcategories = categories
          .where((c) => c.parentCategoryId == parent.id && c.id != null)
          .toList();
      
      for (final subcategory in subcategories) {
        if (subcategory.id == null) continue; // Skip if no ID
        
        items.add(
          DropdownMenuItem<int?>(
            value: subcategory.id,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text('  └─ ${subcategory.name}'),
            ),
          ),
        );
      }
    }
    
    return items;
  }

  Future<void> _scanBarcode(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (scannerContext) => BarcodeScannerWidget(
          onBarcodeScanned: (barcode) {
            // Set the barcode in the text field
            setState(() {
              _barcodeController.text = barcode;
            });
            // Close the scanner
            Navigator.pop(scannerContext);
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Barcode scanned: $barcode'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Debug tax rates
    print('DEBUG PRODUCT FORM: Selected tax rate IDs: $_selectedTaxRateIds');
    
    // Debug tax rates in provider
    final taxRateState = ref.read(taxRateProvider);
    print('DEBUG PRODUCT FORM: Available tax rates: ${taxRateState.taxRates.length}');
    for (final rate in taxRateState.taxRates) {
      print('DEBUG PRODUCT FORM: Tax rate: ${rate.id} - ${rate.name} - ${rate.rate}%');
    }

    try {
      // Check SKU uniqueness if provided
      final sku = _skuController.text.trim().isEmpty ? null : _skuController.text.trim();
      if (sku != null) {
        final isUnique = await ref.read(productProvider.notifier).isSkuUnique(
          sku, 
          excludeProductId: widget.product?.id,
        );
        
        if (!isUnique) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: SKU already exists. Please use a different SKU.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }
      
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        sku: sku,
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        costPrice: double.parse(_costPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        categoryId: _selectedCategoryId,
        stockQuantity: int.parse(_stockController.text),
        lowStockThreshold: int.parse(_lowStockThresholdController.text),
        unit: _unitController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: _isActive,
        taxRateIds: _selectedTaxRateIds,
        priceIncludesTax: _priceIncludesTax,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product == null) {
        await ref.read(productProvider.notifier).createProduct(product);
      } else {
        await ref.read(productProvider.notifier).updateProduct(product);
      }

      if (!mounted) return;
      
      Navigator.pop(context);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product == null
              ? 'Product created successfully'
              : 'Product updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(productProvider).categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name *',
                prefixIcon: const Icon(Icons.inventory_2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // SKU and Barcode
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skuController,
                    decoration: InputDecoration(
                      labelText: 'SKU',
                      prefixIcon: const Icon(Icons.qr_code),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _generateSku,
                        tooltip: 'Generate SKU',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // SKU validation will be done asynchronously in _saveProduct
                        if (value.contains(' ')) {
                          return 'SKU should not contain spaces';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: 'Barcode',
                      prefixIcon: const Icon(Icons.qr_code_scanner),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () => _scanBarcode(context),
                        tooltip: 'Scan Barcode',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category (with hierarchical display)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<int?>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: InputBorder.none,
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('No Category'),
                  ),
                  ..._buildCategoryItems(categories),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            // Prices
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costPriceController,
                    decoration: InputDecoration(
                      labelText: 'Cost Price *',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sellingPriceController,
                    decoration: InputDecoration(
                      labelText: 'Selling Price *',
                      prefixIcon: const Icon(Icons.sell),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stock
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: 'Stock Quantity *',
                      prefixIcon: const Icon(Icons.inventory),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lowStockThresholdController,
                    decoration: InputDecoration(
                      labelText: 'Low Stock Threshold',
                      prefixIcon: const Icon(Icons.warning),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Unit
            TextFormField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: 'Unit (pcs, kg, etc.)',
                prefixIcon: const Icon(Icons.straighten),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Tax Rates Selection
            Consumer(
              builder: (context, ref, child) {
                final taxRateState = ref.watch(taxRateProvider);
                return Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Tax Rates'),
                    subtitle: Text(
                      _selectedTaxRateIds.isEmpty
                          ? 'No tax rates selected'
                          : '${_selectedTaxRateIds.length} tax rate(s) selected',
                    ),
                    children: [
                      if (taxRateState.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (taxRateState.taxRates.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'No tax rates available',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Create Tax Rate'),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/tax-rates');
                                },
                              ),
                            ],
                          ),
                        )
                      else
                        ...taxRateState.taxRates.map((taxRate) {
                          final isSelected = _selectedTaxRateIds.contains(taxRate.id);
                          return CheckboxListTile(
                            title: Text(taxRate.name),
                            subtitle: Text('${taxRate.rate.toStringAsFixed(2)}%'),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (taxRate.id != null) {
                                    _selectedTaxRateIds.add(taxRate.id!);
                                  }
                                } else {
                                  _selectedTaxRateIds.remove(taxRate.id);
                                }
                              });
                            },
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Price Includes Tax
            Card(
              child: SwitchListTile(
                title: const Text('Price Includes Tax'),
                subtitle: const Text('Selling price already includes tax'),
                value: _priceIncludesTax,
                onChanged: (value) {
                  setState(() {
                    _priceIncludesTax = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            // Active Status
            Card(
              child: SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Product will be visible in POS'),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
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
                        widget.product == null ? 'Add Product' : 'Save Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

