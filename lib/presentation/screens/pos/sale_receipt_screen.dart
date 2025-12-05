import 'dart:typed_data';
import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/sale_item.dart';
import '../../providers/repository_providers.dart';

class SaleReceiptScreen extends ConsumerStatefulWidget {
  final Sale sale;
  final List<SaleItem> saleItems;

  const SaleReceiptScreen({
    super.key,
    required this.sale,
    required this.saleItems,
  });

  @override
  ConsumerState<SaleReceiptScreen> createState() => _SaleReceiptScreenState();
}

class _SaleReceiptScreenState extends ConsumerState<SaleReceiptScreen> {
  String? _customerName;

  @override
  void initState() {
    super.initState();
    // Load customer in the background without blocking
    unawaited(_loadCustomer());
  }

  Future<void> _loadCustomer() async {
    if (widget.sale.customerId == null) return;
    
    try {
      final customerRepo = ref.read(customerRepositoryProvider);
      final customer = await customerRepo.getCustomerById(widget.sale.customerId!);
      if (mounted) {
        setState(() {
          _customerName = customer?.name;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _printReceipt() async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16, 
              height: 16, 
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Preparing receipt...'),
          ],
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
    
    try {
      // Generate PDF in background thread to avoid UI blocking
      final pdf = await compute(_generateReceiptPDFIsolate, {
        'saleNumber': widget.sale.saleNumber,
        'saleDate': widget.sale.createdAt.toString(),
        'customerName': _customerName,
        'subtotal': widget.sale.subtotal,
        'discountAmount': widget.sale.discountAmount,
        'taxAmount': widget.sale.taxAmount,
        'totalAmount': widget.sale.totalAmount,
        'paymentMethod': widget.sale.paymentMethod,
        'items': widget.saleItems.map((item) => {
          'productName': item.productName,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'discount': item.discount,
          'taxAmount': item.taxAmount,
          'total': item.total,
        }).toList(),
      });
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing receipt: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Static method that can run in an isolate
  static Future<Uint8List> _generateReceiptPDFIsolate(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    final saleDate = DateTime.parse(data['saleDate']);
    final customerName = data['customerName'] as String?;
    final items = List<Map<String, dynamic>>.from(data['items'] as List);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * 2.83465, double.infinity, marginAll: 4 * 2.83465), // 80mm width, 4mm margins
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'ARONIUM POS',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Thank you for your purchase!',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 6),
              
              // Sale Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Sale #:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    data['saleNumber'],
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    dateFormat.format(saleDate),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Time:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    timeFormat.format(saleDate),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              
              // Customer
              if (customerName != null) ...[
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer:', style: pw.TextStyle(fontSize: 9)),
                    pw.Text(
                      customerName,
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
              
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // Items Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('Item', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('Qty', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Price', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),
              
              // Items
              ...items.map((item) {
                return pw.Column(
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            item['productName'] as String,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            '${item['quantity']}',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'TK ${(item['total'] as num).toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    if ((item['discount'] as num) > 0 || (item['taxAmount'] as num) > 0) ...[
                      pw.SizedBox(height: 1),
                      pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.SizedBox()),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                if ((item['discount'] as num) > 0)
                                  pw.Text(
                                    'Discount: TK ${(item['discount'] as num).toStringAsFixed(2)}',
                                    style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                                  ),
                                if ((item['taxAmount'] as num) > 0)
                                  pw.Text(
                                    'Tax: TK ${(item['taxAmount'] as num).toStringAsFixed(2)}',
                                    style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    pw.SizedBox(height: 3),
                  ],
                );
              }),
              
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    'TK ${(data['subtotal'] as num).toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              if ((data['discountAmount'] as num) > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:', style: pw.TextStyle(fontSize: 9)),
                    pw.Text(
                      '-TK ${(data['discountAmount'] as num).toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.red),
                    ),
                  ],
                ),
              ],
              if ((data['taxAmount'] as num) > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tax:', style: pw.TextStyle(fontSize: 9)),
                    pw.Text(
                      'TK ${(data['taxAmount'] as num).toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'TK ${(data['totalAmount'] as num).toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Payment:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    (data['paymentMethod'] as String).toUpperCase(),
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Thank you for shopping with us!',
                  style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> _generateReceiptPDF() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * 2.83465, double.infinity, marginAll: 4 * 2.83465), // 80mm width, 4mm margins
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'ARONIUM POS',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Thank you for your purchase!',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 6),
              
              // Sale Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Sale #:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    widget.sale.saleNumber,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    dateFormat.format(widget.sale.createdAt),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Time:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    timeFormat.format(widget.sale.createdAt),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              
              // Customer
              if (_customerName != null) ...[
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer:', style: pw.TextStyle(fontSize: 9)),
                    pw.Text(
                      _customerName!,
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
              
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // Items Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('Item', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('Qty', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Price', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),
              
              // Items
              ...widget.saleItems.map((item) {
                return pw.Column(
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            item.productName,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            '${item.quantity}',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'TK ${item.total.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    if (item.discount > 0 || item.taxAmount > 0) ...[
                      pw.SizedBox(height: 1),
                      pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.SizedBox()),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                if (item.discount > 0)
                                  pw.Text(
                                    'Discount: TK ${item.discount.toStringAsFixed(2)}',
                                    style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                                  ),
                                if (item.taxAmount > 0)
                                  pw.Text(
                                    'Tax: TK ${item.taxAmount.toStringAsFixed(2)}',
                                    style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    pw.SizedBox(height: 3),
                  ],
                );
              }),
              
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    'TK ${widget.sale.subtotal.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              if (widget.sale.discountAmount > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:', style: pw.TextStyle(fontSize: 9)),
                    pw.Text(
                      '-TK ${widget.sale.discountAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.red),
                    ),
                  ],
                ),
              ],
              if (widget.sale.taxAmount > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tax:', style: pw.TextStyle(fontSize: 9)),
                    pw.Text(
                      'TK ${widget.sale.taxAmount.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'TK ${widget.sale.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Payment:', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    widget.sale.paymentMethod.toUpperCase(),
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Thank you for shopping with us!',
                  style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReceipt,
            tooltip: 'Print Receipt',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        'ARONIUM POS',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thank you for your purchase!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                // Sale Info
                _buildInfoRow('Sale Number', widget.sale.saleNumber),
                _buildInfoRow('Date', DateFormat('MMM dd, yyyy').format(widget.sale.createdAt)),
                _buildInfoRow('Time', DateFormat('HH:mm').format(widget.sale.createdAt)),
                
                // Customer
                if (_customerName != null) ...[
                  const Divider(height: 24),
                  _buildInfoRow('Customer', _customerName!),
                ],
                
                const Divider(height: 24),
                
                // Items
                Text(
                  'Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...widget.saleItems.map((item) => _buildItemRow(item)),
                
                const Divider(height: 24),
                
                // Totals
                _buildInfoRow('Subtotal', 'TK ${widget.sale.subtotal.toStringAsFixed(2)}'),
                if (widget.sale.discountAmount > 0)
                  _buildInfoRow('Discount', '-TK ${widget.sale.discountAmount.toStringAsFixed(2)}', isDiscount: true),
                if (widget.sale.taxAmount > 0)
                  _buildInfoRow('Tax', 'TK ${widget.sale.taxAmount.toStringAsFixed(2)}'),
                const Divider(height: 16),
                _buildInfoRow(
                  'TOTAL',
                  'TK ${widget.sale.totalAmount.toStringAsFixed(2)}',
                  isTotal: true,
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Payment Method', widget.sale.paymentMethod.toUpperCase()),
                
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Thank you for shopping with us!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _printReceipt,
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(SaleItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${item.quantity} x TK ${item.unitPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'TK ${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (item.discount > 0 || item.taxAmount > 0) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Wrap(
                spacing: 12,
                children: [
                  if (item.discount > 0)
                    Text(
                      'Discount: TK ${item.discount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                      ),
                    ),
                  if (item.taxAmount > 0)
                    Text(
                      'Tax: TK ${item.taxAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

