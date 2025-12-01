import '../../domain/entities/customer.dart' as domain;
import '../../domain/repositories/customer_repository.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final AppDatabase _db;

  CustomerRepositoryImpl(this._db);

  @override
  Future<List<domain.Customer>> getCustomers({String? search}) async {
    var query = _db.select(_db.customers)..where((c) => c.isActive.equals(true));

    final customers = await query.get();
    var result = customers.map((c) => _toCustomer(c)).toList();
    
    // Filter by search if provided
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(searchLower) ||
               (c.phone?.toLowerCase().contains(searchLower) ?? false) ||
               (c.email?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }
    
    return result;
  }

  @override
  Future<domain.Customer?> getCustomerById(int id) async {
    final customer = await (_db.select(_db.customers)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return customer != null ? _toCustomer(customer) : null;
  }

  @override
  Future<domain.Customer> createCustomer(domain.Customer customer) async {
    final companion = CustomersCompanion(
      name: Value(customer.name),
      email: Value(customer.email),
      phone: Value(customer.phone),
      address: Value(customer.address),
      loyaltyPoints: Value(customer.loyaltyPoints),
      isActive: Value(customer.isActive),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.customers).insert(companion);
    return customer.copyWith(id: id);
  }

  @override
  Future<domain.Customer> updateCustomer(domain.Customer customer) async {
    if (customer.id == null) throw Exception('Customer ID is required');

    await (_db.update(_db.customers)..where((c) => c.id.equals(customer.id!)))
        .write(CustomersCompanion(
      name: Value(customer.name),
      email: Value(customer.email),
      phone: Value(customer.phone),
      address: Value(customer.address),
      loyaltyPoints: Value(customer.loyaltyPoints),
      isActive: Value(customer.isActive),
      updatedAt: Value(DateTime.now()),
    ));

    return customer;
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await (_db.update(_db.customers)..where((c) => c.id.equals(id)))
        .write(const CustomersCompanion(isActive: Value(false)));
  }

  @override
  Future<void> updateLoyaltyPoints(int customerId, double points) async {
    final customer = await getCustomerById(customerId);
    if (customer != null) {
      await updateCustomer(customer.copyWith(loyaltyPoints: points));
    }
  }

  domain.Customer _toCustomer(Customer dbCustomer) {
    return domain.Customer(
      id: dbCustomer.id,
      name: dbCustomer.name,
      email: dbCustomer.email,
      phone: dbCustomer.phone,
      address: dbCustomer.address,
      loyaltyPoints: dbCustomer.loyaltyPoints,
      isActive: dbCustomer.isActive,
      createdAt: dbCustomer.createdAt,
      updatedAt: dbCustomer.updatedAt,
    );
  }
}

extension CustomerCopyWith on domain.Customer {
  domain.Customer copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    double? loyaltyPoints,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return domain.Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

