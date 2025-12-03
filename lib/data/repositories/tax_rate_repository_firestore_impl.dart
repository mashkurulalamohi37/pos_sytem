import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tax_rate.dart';
import '../../domain/repositories/tax_rate_repository.dart';
import 'firestore_utils.dart';

class TaxRateRepositoryFirestoreImpl implements TaxRateRepository {
  final FirebaseFirestore _firestore;

  TaxRateRepositoryFirestoreImpl(this._firestore);

  @override
  Future<List<TaxRate>> getTaxRates() async {
    final snapshot = await _firestore
        .collection('taxRates')
        .where('isActive', isEqualTo: true)
        .get();

    final taxRates = snapshot.docs.map((doc) => _toTaxRate(doc)).toList();
    // Sort by name in memory
    taxRates.sort((a, b) => a.name.compareTo(b.name));
    return taxRates;
  }

  @override
  Future<TaxRate?> getTaxRateById(int id) async {
    final doc = await _firestore
        .collection('taxRates')
        .doc(idToDocId(id))
        .get();

    if (!doc.exists) return null;
    return _toTaxRate(doc);
  }

  @override
  Future<TaxRate> createTaxRate(TaxRate taxRate) async {
    final now = DateTime.now();
    final id = DateTime.now().millisecondsSinceEpoch;
    
    final data = {
      'name': taxRate.name,
      'rate': taxRate.rate,
      'description': taxRate.description,
      'isActive': taxRate.isActive,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    await _firestore.collection('taxRates').doc(idToDocId(id)).set(data);

    return taxRate.copyWith(id: id, createdAt: now, updatedAt: now);
  }

  @override
  Future<TaxRate> updateTaxRate(TaxRate taxRate) async {
    if (taxRate.id == null) throw Exception('Tax rate ID is required');

    await _firestore.collection('taxRates').doc(idToDocId(taxRate.id!)).update({
      'name': taxRate.name,
      'rate': taxRate.rate,
      'description': taxRate.description,
      'isActive': taxRate.isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    return taxRate;
  }

  @override
  Future<void> deleteTaxRate(int id) async {
    await _firestore.collection('taxRates').doc(idToDocId(id)).update({
      'isActive': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  TaxRate _toTaxRate(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaxRate(
      id: docIdToId(doc.id),
      name: data['name'] as String,
      rate: (data['rate'] as num).toDouble(),
      description: data['description'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

extension TaxRateCopyWith on TaxRate {
  TaxRate copyWith({
    int? id,
    String? name,
    double? rate,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxRate(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

