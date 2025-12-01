import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/customer.dart' as domain;
import '../../domain/repositories/customer_repository.dart';
import 'firestore_utils.dart';

class CustomerRepositoryFirestoreImpl implements CustomerRepository {
  final FirebaseFirestore _firestore;

  CustomerRepositoryFirestoreImpl(this._firestore);

  @override
  Future<List<domain.Customer>> getCustomers({String? search}) async {
    Query query = _firestore.collection('customers')
        .where('isActive', isEqualTo: true);

    final snapshot = await query.get();
    var customers = snapshot.docs.map((doc) => _toCustomer(doc)).toList();

    // Filter by search if provided
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      customers = customers.where((c) {
        return c.name.toLowerCase().contains(searchLower) ||
               (c.phone?.toLowerCase().contains(searchLower) ?? false) ||
               (c.email?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    return customers;
  }

  @override
  Future<domain.Customer?> getCustomerById(int id) async {
    final doc = await _firestore.collection('customers').doc(idToDocId(id)).get();
    if (!doc.exists) return null;
    return _toCustomer(doc);
  }

  @override
  Future<domain.Customer> createCustomer(domain.Customer customer) async {
    final docId = customer.id != null ? idToDocId(customer.id!) : generateDocId();
    final now = DateTime.now();

    await _firestore.collection('customers').doc(docId).set({
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phone,
      'address': customer.address,
      'loyaltyPoints': customer.loyaltyPoints,
      'isActive': customer.isActive,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    return customer.copyWith(id: docIdToId(docId), createdAt: now, updatedAt: now);
  }

  @override
  Future<domain.Customer> updateCustomer(domain.Customer customer) async {
    if (customer.id == null) throw Exception('Customer ID is required');

    await _firestore.collection('customers').doc(idToDocId(customer.id!)).update({
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phone,
      'address': customer.address,
      'loyaltyPoints': customer.loyaltyPoints,
      'isActive': customer.isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    return customer;
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await _firestore.collection('customers').doc(idToDocId(id)).update({
      'isActive': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> updateLoyaltyPoints(int customerId, double points) async {
    await _firestore.collection('customers').doc(idToDocId(customerId)).update({
      'loyaltyPoints': points,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  domain.Customer _toCustomer(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return domain.Customer(
      id: docIdToId(doc.id),
      name: data['name'] as String,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      loyaltyPoints: (data['loyaltyPoints'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

