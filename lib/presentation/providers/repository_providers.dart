import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_firestore_impl.dart';
import '../../data/repositories/product_repository_firestore_impl.dart';
import '../../data/repositories/sale_repository_firestore_impl.dart';
import '../../data/repositories/inventory_repository_firestore_impl.dart';
import '../../data/repositories/customer_repository_firestore_impl.dart';
import '../../data/repositories/cash_session_repository_firestore_impl.dart';
import '../../data/repositories/user_repository_firestore_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/cash_session_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/tax_rate_repository.dart';
import '../../data/repositories/tax_rate_repository_firestore_impl.dart';
import 'firebase_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRepositoryFirestoreImpl(auth, firestore);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ProductRepositoryFirestoreImpl(firestore);
});

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return SaleRepositoryFirestoreImpl(firestore);
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return InventoryRepositoryFirestoreImpl(firestore);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return CustomerRepositoryFirestoreImpl(firestore);
});

final cashSessionRepositoryProvider = Provider<CashSessionRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return CashSessionRepositoryFirestoreImpl(firestore);
});

final taxRateRepositoryProvider = Provider<TaxRateRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return TaxRateRepositoryFirestoreImpl(firestore);
});

