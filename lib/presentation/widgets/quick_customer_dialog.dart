import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/customer_provider.dart';
import '../../domain/entities/customer.dart';

class QuickCustomerDialog extends ConsumerStatefulWidget {
  const QuickCustomerDialog({super.key});

  @override
  ConsumerState<QuickCustomerDialog> createState() => _QuickCustomerDialogState();
}

class _QuickCustomerDialogState extends ConsumerState<QuickCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    // Load customers when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerProvider.notifier).loadCustomers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final customer = Customer(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(customerProvider.notifier).createCustomer(customer);
      
      // Refresh customer list
      await ref.read(customerProvider.notifier).loadCustomers();

      if (mounted) {
        Navigator.pop(context, customer);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer added successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerProvider);
    final customers = customerState.customers;
    
    // Filter customers by search
    final filteredCustomers = _searchController.text.isEmpty
        ? customers
        : customers.where((customer) {
            final searchLower = _searchController.text.toLowerCase();
            return customer.name.toLowerCase().contains(searchLower) ||
                   (customer.phone?.toLowerCase().contains(searchLower) ?? false) ||
                   (customer.email?.toLowerCase().contains(searchLower) ?? false);
          }).toList();

    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _showAddForm ? 'Add New Customer' : 'Select Customer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: _showAddForm
                  ? _buildAddForm()
                  : _buildCustomerList(filteredCustomers),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList(List<Customer> customers) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        // Customer list
        Flexible(
          child: customers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No customers found'
                              : 'No customers match your search',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        customer.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: customer.phone != null
                          ? Text(customer.phone!)
                          : customer.email != null
                              ? Text(customer.email!)
                              : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (customer.id != null) {
                          Navigator.pop(context, customer);
                        }
                      },
                    );
                  },
                ),
        ),
        // Add new customer button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showAddForm = true;
                });
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add New Customer'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showAddForm = false;
                  _nameController.clear();
                  _phoneController.clear();
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to list'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name *',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Optional',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _showAddForm = false;
                            _nameController.clear();
                            _phoneController.clear();
                          });
                        },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createCustomer,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Customer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

