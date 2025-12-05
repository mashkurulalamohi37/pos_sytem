import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tax_rate.dart';
import '../../domain/repositories/tax_rate_repository.dart';
import 'firestore_utils.dart';
import 'dart:developer' as developer;

class TaxRateRepositoryFirestoreImpl implements TaxRateRepository {
  final FirebaseFirestore _firestore;

  TaxRateRepositoryFirestoreImpl(this._firestore);

  @override
  Future<List<TaxRate>> getTaxRates() async {
    try {
      final collectionRef = _firestore.collection('taxRates');
      
      final snapshot = await collectionRef
          .where('isActive', isEqualTo: true)
          .get();
      
      final taxRates = snapshot.docs.map((doc) => _toTaxRate(doc)).toList();
      
      // Sort by name in memory
      taxRates.sort((a, b) => a.name.compareTo(b.name));
      return taxRates;
    } catch (e) {
      developer.log('Error getting tax rates: $e');
      return [];
    }
  }

  @override
  Future<TaxRate?> getTaxRateById(int id) async {
    try {
      final doc = await _firestore
          .collection('taxRates')
          .doc(idToDocId(id))
          .get();

      if (!doc.exists) return null;
      
      return _toTaxRate(doc);
    } catch (e) {
      developer.log('Error getting tax rate by ID: $e');
      return null;
    }
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

    try {
      await _firestore.collection('taxRates').doc(idToDocId(id)).set(data);
      return taxRate.copyWith(id: id, createdAt: now, updatedAt: now);
    } catch (e) {
      developer.log('Error creating tax rate: $e');
      throw e;
    }
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
    try {
      final data = doc.data() as Map<String, dynamic>;
      
      // Handle date fields safely
      DateTime createdAt = DateTime.now();
      DateTime updatedAt = DateTime.now();
      
      try {
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is String) {
          // Try to parse the string date
          createdAt = DateTime.parse(data['createdAt'] as String);
        }
      } catch (e) {
        developer.log('Error parsing createdAt: $e');
      }
      
      try {
        if (data['updatedAt'] is Timestamp) {
          updatedAt = (data['updatedAt'] as Timestamp).toDate();
        } else if (data['updatedAt'] is String) {
          // Try to parse the string date
          updatedAt = DateTime.parse(data['updatedAt'] as String);
        }
      } catch (e) {
        developer.log('Error parsing updatedAt: $e');
      }
      
      return TaxRate(
        id: docIdToId(doc.id),
        name: data['name'] as String,
        rate: (data['rate'] is num) ? (data['rate'] as num).toDouble() : 0.0,
        description: data['description'] as String?,
        isActive: data['isActive'] as bool? ?? true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      developer.log('Error in _toTaxRate: $e');
      // Return a default tax rate to avoid crashes
      return TaxRate(
        id: docIdToId(doc.id),
        name: 'Error Tax',
        rate: 0.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
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

