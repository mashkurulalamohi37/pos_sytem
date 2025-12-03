import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tax_rate_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/tax_rate.dart';
import 'tax_rate_form_screen.dart';

class TaxRatesScreen extends ConsumerStatefulWidget {
  const TaxRatesScreen({super.key});

  @override
  ConsumerState<TaxRatesScreen> createState() => _TaxRatesScreenState();
}

class _TaxRatesScreenState extends ConsumerState<TaxRatesScreen> {
  @override
  void initState() {
    super.initState();
    // Load tax rates when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taxRateProvider.notifier).loadTaxRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taxRateState = ref.watch(taxRateProvider);
    final authState = ref.watch(authProvider);
    final canEdit = (authState.user?.isAdmin ?? false) || (authState.user?.isManager ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Rates'),
        elevation: 0,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TaxRateFormScreen()),
                ).then((_) => ref.read(taxRateProvider.notifier).loadTaxRates());
              },
              tooltip: 'Add Tax Rate',
            ),
        ],
      ),
      body: taxRateState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taxRateState.taxRates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tax rates found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add tax rates to assign them to products',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: taxRateState.taxRates.length,
                  itemBuilder: (context, index) {
                    final taxRate = taxRateState.taxRates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          taxRate.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Rate: ${taxRate.rate.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            if (taxRate.description != null && taxRate.description!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                taxRate.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: canEdit
                            ? PopupMenuButton(
                                icon: const Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                    onTap: () {
                                      Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => TaxRateFormScreen(taxRate: taxRate),
                                            ),
                                          ).then((_) => ref.read(taxRateProvider.notifier).loadTaxRates());
                                        },
                                      );
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red.shade700),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Tax Rate'),
                                              content: Text('Are you sure you want to delete "${taxRate.name}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await ref.read(taxRateProvider.notifier).deleteTaxRate(taxRate.id!);
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Tax rate deleted'),
                                                          backgroundColor: Colors.green,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(color: Colors.red.shade700),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}

