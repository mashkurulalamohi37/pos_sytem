import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../providers/sale_provider.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/sale_item.dart';

class SaleDetailScreen extends ConsumerStatefulWidget {
  final Sale sale;

  const SaleDetailScreen({super.key, required this.sale});

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  List<SaleItem>? _saleItems;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaleItems();
  }

  Future<void> _loadSaleItems() async {
    final items = await ref.read(saleProvider.notifier).getSaleItems(widget.sale.id!);
    setState(() {
      _saleItems = items;
      _isLoading = false;
    });
  }

  Future<void> _printReceipt() async {
    if (_saleItems == null) return;

    // Calculate totals
    final subtotalBeforeDiscounts = _saleItems!.fold<double>(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
    final itemDiscountsTotal = _saleItems!.fold<double>(
      0.0,
      (sum, item) => sum + item.discount,
    );
    final subtotalAfterItemDiscounts = subtotalBeforeDiscounts - itemDiscountsTotal;
    final overallDiscount = widget.sale.discountAmount - itemDiscountsTotal;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80, double.infinity, marginAll: 4),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'ARONIUM POS',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // Sale Info
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Sale:',
                      style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF616161)),
                    ),
                    pw.Text(
                      widget.sale.saleNumber,
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(widget.sale.createdAt)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      DateFormat('HH:mm').format(widget.sale.createdAt),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // Items
              ..._saleItems!.map((item) {
                final itemSubtotal = item.unitPrice * item.quantity;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.productName,
                        style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.quantity} × TK ${item.unitPrice.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            'TK ${itemSubtotal.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                      if (item.discount > 0) ...[
                        pw.SizedBox(height: 2),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Discount:',
                              style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFFC62828)),
                            ),
                            pw.Text(
                              '-TK ${item.discount.toStringAsFixed(2)}',
                              style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFFC62828)),
                            ),
                          ],
                        ),
                      ],
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.SizedBox(),
                          pw.Text(
                            'TK ${item.total.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // Totals
              if (itemDiscountsTotal > 0 || overallDiscount > 0) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Subtotal (before discounts):',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      'TK ${subtotalBeforeDiscounts.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
                if (itemDiscountsTotal > 0) ...[
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Item Discounts:',
                        style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFC62828)),
                      ),
                      pw.Text(
                        '-TK ${itemDiscountsTotal.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFC62828)),
                      ),
                    ],
                  ),
                ],
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Subtotal:',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      'TK ${subtotalAfterItemDiscounts.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
                if (overallDiscount > 0) ...[
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Overall Discount:',
                        style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFC62828)),
                      ),
                      pw.Text(
                        '-TK ${overallDiscount.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFC62828)),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Subtotal:',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      'TK ${widget.sale.subtotal.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ],
              
              if (widget.sale.taxAmount > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Tax:',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
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
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'TK ${widget.sale.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // Payment
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Payment:',
                      style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF616161)),
                    ),
                    pw.Text(
                      widget.sale.paymentMethod.toUpperCase(),
                      style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Thank you!',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sale ${widget.sale.saleNumber}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReceipt,
            tooltip: 'Print Receipt',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sale Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.sale.saleNumber,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.sale.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Date', DateFormat('MMM dd, yyyy • HH:mm').format(widget.sale.createdAt)),
                          _buildInfoRow('Payment Method', widget.sale.paymentMethod.toUpperCase()),
                          const Divider(height: 24),
                          _buildInfoRow('Subtotal', 'TK ${widget.sale.subtotal.toStringAsFixed(2)}'),
                          if (widget.sale.discountAmount > 0)
                            _buildInfoRow('Discount', '-TK ${widget.sale.discountAmount.toStringAsFixed(2)}'),
                          if (widget.sale.taxAmount > 0)
                            _buildInfoRow('Tax', 'TK ${widget.sale.taxAmount.toStringAsFixed(2)}'),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'TK ${widget.sale.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Items List
                  Text(
                    'Items (${_saleItems?.length ?? 0})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(_saleItems ?? []).map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${item.quantity} × TK ${item.unitPrice.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          'TK ${item.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

