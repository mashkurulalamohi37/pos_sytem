import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../providers/sale_provider.dart';
import '../../providers/product_provider.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/product.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedReport = 'sales';

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
      });
      _loadData();
    }
  }

  Future<void> _exportToCSV() async {
    try {
      final salesState = ref.read(saleProvider);
      final sales = salesState.sales;

      final csvData = [
        ['Sale Number', 'Date', 'Time', 'Subtotal', 'Discount', 'Tax', 'Total', 'Payment Method'],
        ...sales.map((sale) => [
              sale.saleNumber,
              DateFormat('dd-MMM-yyyy').format(sale.createdAt), // Format: 01-Jan-2024
              DateFormat('HH:mm').format(sale.createdAt),
              sale.subtotal.toStringAsFixed(2),
              sale.discountAmount.toStringAsFixed(2),
              sale.taxAmount.toStringAsFixed(2),
              sale.totalAmount.toStringAsFixed(2),
              sale.paymentMethod,
            ]),
      ];

      final csvString = const ListToCsvConverter().convert(csvData);
      final fileName = 'sales_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sales Report',
      );
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

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(saleProvider);
    final productsState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCSV,
            tooltip: 'Export to CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Range and Report Type
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
            child: Column(
              children: [
                InkWell(
                  onTap: () => _selectDateRange(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From: ${_startDate != null ? DateFormat('MMM dd, yyyy').format(_startDate!) : 'Select'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'To: ${_endDate != null ? DateFormat('MMM dd, yyyy').format(_endDate!) : 'Select'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'sales', label: Text('Sales')),
                    ButtonSegment(value: 'products', label: Text('Products')),
                    ButtonSegment(value: 'profit', label: Text('Profit')),
                  ],
                  selected: {_selectedReport},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedReport = newSelection.first;
                    });
                  },
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
                            Icon(
                              Icons.assessment_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sales data found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different date range',
                              style: TextStyle(
                                fontSize: 12,
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
          _buildSummaryCard(
            'Total Discount',
            'TK ${totalDiscount.toStringAsFixed(2)}',
            Icons.discount,
            Colors.red,
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
    // Simplified profit calculation
    final sales = salesState.sales;
    final totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    // Would need to calculate actual cost from sale items
    final estimatedCost = totalRevenue * 0.6; // Placeholder
    final profit = totalRevenue - estimatedCost;
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
            'TK ${estimatedCost.toStringAsFixed(2)}',
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
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
