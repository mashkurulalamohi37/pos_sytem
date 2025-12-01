import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers({String? search});
  Future<Customer?> getCustomerById(int id);
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(int id);
  Future<void> updateLoyaltyPoints(int customerId, double points);
}

