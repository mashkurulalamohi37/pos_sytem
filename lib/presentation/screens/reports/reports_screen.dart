import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/sale_provider.dart';
import '../../providers/product_provider.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/sale_item.dart';
import '../../../domain/entities/product.dart';
import '../../../core/file_helper.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedReport = 'sales';
  Map<int, List<SaleItem>> _saleItemsMap = {}; // Cache for sale items
  bool _isLoadingSaleItems = false;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(saleProvider.notifier).loadSales(
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  Future<void> _loadSaleItemsForProfitReport() async {
    if (_isLoadingSaleItems) return;
    
    setState(() {
      _isLoadingSaleItems = true;
    });

    try {
      final salesState = ref.read(saleProvider);
      final sales = salesState.sales;
      
      // Load sale items for all sales
      final Map<int, List<SaleItem>> itemsMap = {};
      for (final sale in sales) {
        if (sale.id != null) {
          try {
            final items = await ref.read(saleProvider.notifier).getSaleItems(sale.id!);
            itemsMap[sale.id!] = items;
          } catch (e) {
            // If loading fails for a sale, continue with others
            print('Error loading items for sale ${sale.id}: $e');
          }
        }
      }
      
      setState(() {
        _saleItemsMap = itemsMap;
        _isLoadingSaleItems = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSaleItems = false;
      });
      print('Error loading sale items: $e');
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _saleItemsMap = {}; // Clear cached items when date range changes
      });
      _loadData();
      // Reload sale items if profit report is selected
      if (_selectedReport == 'profit') {
        _loadSaleItemsForProfitReport();
      }
    }
  }

  Future<void> _exportToCSV() async {
    try {
      final salesState = ref.read(saleProvider);
      final productsState = ref.read(productProvider);
      final sales = salesState.sales;
      
      String csvString;
      String fileName;
      String subject;
      
      switch (_selectedReport) {
        case 'sales':
          csvString = _exportSalesReport(sales);
          fileName = 'sales_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
          subject = 'Sales Report';
          break;
        case 'products':
          csvString = _exportProductsReport(productsState.products);
          fileName = 'products_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
          subject = 'Products Report';
          break;
        case 'profit':
          csvString = await _exportProfitReport(salesState, productsState);
          fileName = 'profit_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
          subject = 'Profit Report';
          break;
        default:
          csvString = _exportSalesReport(sales);
          fileName = 'report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
          subject = 'Report';
      }

      // Use FileHelper for platform-agnostic file sharing
      await FileHelper.saveAndShare(
        content: csvString,
        fileName: fileName,
        subject: subject,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$subject exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _exportSalesReport(List<Sale> sales) {
    final csvData = [
      ['Sale Number', 'Date', 'Time', 'Subtotal', 'Discount', 'Tax', 'Total', 'Payment Method'],
      ...sales.map((sale) => [
            sale.saleNumber,
            DateFormat('dd-MMM-yyyy').format(sale.createdAt),
            DateFormat('HH:mm').format(sale.createdAt),
            sale.subtotal.toStringAsFixed(2),
            sale.discountAmount.toStringAsFixed(2),
            sale.taxAmount.toStringAsFixed(2),
            sale.totalAmount.toStringAsFixed(2),
            sale.paymentMethod,
          ]),
    ];
    
    // Add summary row
    final totalSales = sales.length;
    final totalAmount = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    final totalSubtotal = sales.fold(0.0, (sum, sale) => sum + sale.subtotal);
    final totalDiscount = sales.fold(0.0, (sum, sale) => sum + sale.discountAmount);
    final totalTax = sales.fold(0.0, (sum, sale) => sum + sale.taxAmount);
    
    csvData.add([]); // Empty row
    csvData.add(['Summary', '', '', '', '', '', '', '']);
    csvData.add(['Total Sales', totalSales.toString(), '', '', '', '', '', '']);
    csvData.add(['Total Subtotal', '', '', totalSubtotal.toStringAsFixed(2), '', '', '', '']);
    csvData.add(['Total Discount', '', '', '', totalDiscount.toStringAsFixed(2), '', '', '']);
    csvData.add(['Total Tax', '', '', '', '', totalTax.toStringAsFixed(2), '', '']);
    csvData.add(['Total Amount', '', '', '', '', '', totalAmount.toStringAsFixed(2), '']);
    
    return const ListToCsvConverter().convert(csvData);
  }

  String _exportProductsReport(List<Product> products) {
    final csvData = [
      ['Product Name', 'SKU', 'Barcode', 'Category ID', 'Stock Quantity', 'Cost Price', 'Selling Price', 'Unit', 'Status'],
      ...products.map((product) => [
            product.name,
            product.sku ?? '',
            product.barcode ?? '',
            product.categoryId?.toString() ?? '',
            product.stockQuantity.toString(),
            product.costPrice.toStringAsFixed(2),
            product.sellingPrice.toStringAsFixed(2),
            product.unit,
            product.isActive ? 'Active' : 'Inactive',
          ]),
    ];
    
    // Add summary
    final activeProducts = products.where((p) => p.isActive).length;
    final totalStock = products.fold(0, (sum, p) => sum + p.stockQuantity);
    final totalValue = products.fold(0.0, (sum, p) => sum + (p.stockQuantity * p.costPrice));
    
    csvData.add([]); // Empty row
    csvData.add(['Summary', '', '', '', '', '', '', '', '']);
    csvData.add(['Total Products', products.length.toString(), '', '', '', '', '', '', '']);
    csvData.add(['Active Products', activeProducts.toString(), '', '', '', '', '', '', '']);
    csvData.add(['Total Stock', '', '', '', totalStock.toString(), '', '', '', '']);
    csvData.add(['Total Inventory Value', '', '', '', '', totalValue.toStringAsFixed(2), '', '', '']);
    
    return const ListToCsvConverter().convert(csvData);
  }

  Future<String> _exportProfitReport(SaleState salesState, ProductState productsState) async {
    final sales = salesState.sales;
    
    // Load sale items if not already loaded
    if (_saleItemsMap.isEmpty && !_isLoadingSaleItems) {
      await _loadSaleItemsForProfitReport();
    }
    
    // Create a map of productId -> costPrice for quick lookup
    final productCostMap = <int, double>{};
    for (final product in productsState.products) {
      if (product.id != null) {
        productCostMap[product.id!] = product.costPrice;
      }
    }
    
    final csvData = [
      ['Sale Number', 'Date', 'Revenue', 'Cost', 'Profit', 'Margin %'],
    ];
    
    double totalRevenue = 0.0;
    double totalCost = 0.0;
    
    for (final sale in sales) {
      double saleCost = 0.0;
      if (sale.id != null && _saleItemsMap.containsKey(sale.id)) {
        final items = _saleItemsMap[sale.id]!;
        for (final item in items) {
          final costPrice = productCostMap[item.productId] ?? 0.0;
          saleCost += costPrice * item.quantity;
        }
      }
      
      final saleRevenue = sale.totalAmount;
      final saleProfit = saleRevenue - saleCost;
      final saleMargin = saleRevenue > 0 ? (saleProfit / saleRevenue) * 100 : 0;
      
      totalRevenue += saleRevenue;
      totalCost += saleCost;
      
      csvData.add([
        sale.saleNumber,
        DateFormat('dd-MMM-yyyy').format(sale.createdAt),
        saleRevenue.toStringAsFixed(2),
        saleCost.toStringAsFixed(2),
        saleProfit.toStringAsFixed(2),
        saleMargin.toStringAsFixed(2),
      ]);
    }
    
    // Add summary
    final totalProfit = totalRevenue - totalCost;
    final totalMargin = totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0;
    
    csvData.add([]); // Empty row
    csvData.add(['Summary', '', '', '', '', '']);
    csvData.add(['Total Revenue', '', totalRevenue.toStringAsFixed(2), '', '', '']);
    csvData.add(['Total Cost', '', '', totalCost.toStringAsFixed(2), '', '']);
    csvData.add(['Total Profit', '', '', '', totalProfit.toStringAsFixed(2), '']);
    csvData.add(['Total Margin', '', '', '', '', totalMargin.toStringAsFixed(2) + '%']);
    
    return const ListToCsvConverter().convert(csvData);
  }

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(saleProvider);
    final productsState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: _exportToCSV,
              tooltip: 'Export to CSV',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Range and Report Type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => _selectDateRange(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From: ${_startDate != null ? DateFormat('MMM dd, yyyy').format(_startDate!) : 'Select'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'To: ${_endDate != null ? DateFormat('MMM dd, yyyy').format(_endDate!) : 'Select'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'sales',
                      label: Text('Sales'),
                      icon: Icon(Icons.receipt, size: 16),
                    ),
                    ButtonSegment(
                      value: 'products',
                      label: Text('Products'),
                      icon: Icon(Icons.inventory_2, size: 16),
                    ),
                    ButtonSegment(
                      value: 'profit',
                      label: Text('Profit'),
                      icon: Icon(Icons.trending_up, size: 16),
                    ),
                  ],
                  selected: {_selectedReport},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedReport = newSelection.first;
                    });
                    // Load sale items when profit report is selected
                    if (newSelection.first == 'profit') {
                      _loadSaleItemsForProfitReport();
                    }
                  },
                  style: SegmentedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          // Report Content
          Expanded(
            child: salesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : salesState.sales.isEmpty && _startDate != null && _endDate != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.assessment_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No sales data found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different date range',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildReportContent(salesState, productsState),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(SaleState salesState, ProductState productsState) {
    switch (_selectedReport) {
      case 'sales':
        return _buildSalesReport(salesState);
      case 'products':
        return _buildProductsReport(salesState, productsState);
      case 'profit':
        return _buildProfitReport(salesState, productsState);
      default:
        return const Center(child: Text('Unknown report type'));
    }
  }

  Widget _buildSalesReport(SaleState salesState) {
    final sales = salesState.sales;
    final totalSales = sales.length;
    final totalAmount = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    final totalSubtotal = sales.fold(0.0, (sum, sale) => sum + sale.subtotal);
    final totalDiscount = sales.fold(0.0, (sum, sale) => sum + sale.discountAmount);
    final totalTax = sales.fold(0.0, (sum, sale) => sum + sale.taxAmount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Sales',
                  totalSales.toString(),
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Amount',
                  'TK ${totalAmount.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Subtotal',
                  'TK ${totalSubtotal.toStringAsFixed(2)}',
                  Icons.calculate,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Tax',
                  'TK ${totalTax.toStringAsFixed(2)}',
                  Icons.receipt_long,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Discount',
                  'TK ${totalDiscount.toStringAsFixed(2)}',
                  Icons.discount,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsReport(SaleState salesState, ProductState productsState) {
    // Calculate top products (simplified - would need sale items)
    final topProducts = productsState.products.take(10).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Top Products',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...topProducts.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text('${index + 1}'),
              ),
              title: Text(product.name),
              subtitle: Text('Stock: ${product.stockQuantity}'),
              trailing: Text(
                'TK ${product.sellingPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProfitReport(SaleState salesState, ProductState productsState) {
    // Calculate actual profit from sale items and product costs
    final sales = salesState.sales;
    final totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    
    // Show loading indicator if sale items are being loaded
    if (_isLoadingSaleItems) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Create a map of productId -> costPrice for quick lookup
    final productCostMap = <int, double>{};
    for (final product in productsState.products) {
      if (product.id != null) {
        productCostMap[product.id!] = product.costPrice;
      }
    }
    
    // Calculate total cost from sale items
    double totalCost = 0.0;
    for (final sale in sales) {
      if (sale.id != null && _saleItemsMap.containsKey(sale.id)) {
        // Use cached sale items
        final items = _saleItemsMap[sale.id]!;
        for (final item in items) {
          final costPrice = productCostMap[item.productId] ?? 0.0;
          totalCost += costPrice * item.quantity;
        }
      }
    }
    
    final profit = totalRevenue - totalCost;
    final margin = totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            'Total Revenue',
            'TK ${totalRevenue.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Total Cost',
            'TK ${totalCost.toStringAsFixed(2)}',
            Icons.trending_down,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Profit',
            'TK ${profit.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Margin',
            '${margin.toStringAsFixed(2)}%',
            Icons.percent,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
