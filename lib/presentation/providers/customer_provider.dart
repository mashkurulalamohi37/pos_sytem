import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import 'repository_providers.dart';

class CustomerState {
  final List<Customer> customers;
  final bool isLoading;
  final String searchQuery;

  CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.searchQuery = '',
  });

  CustomerState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? searchQuery,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  final CustomerRepository _customerRepository;

  CustomerNotifier(this._customerRepository) : super(CustomerState()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true);
    try {
      final customers = await _customerRepository.getCustomers();
      state = state.copyWith(
        customers: customers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  List<Customer> get filteredCustomers {
    if (state.searchQuery.isEmpty) {
      return state.customers;
    }
    final query = state.searchQuery.toLowerCase();
    return state.customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          (customer.email?.toLowerCase().contains(query) ?? false) ||
          (customer.phone?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> createCustomer(Customer customer) async {
    try {
      await _customerRepository.createCustomer(customer);
      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customerRepository.updateCustomer(customer);
      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _customerRepository.deleteCustomer(id);
      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }
}

final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  final customerRepo = ref.watch(customerRepositoryProvider);
  return CustomerNotifier(customerRepo);
});

