import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/file_helper.dart';

typedef ProgressCallback = void Function(String message, double progress);

class BackupService {
  final FirebaseFirestore _firestore;

  BackupService(this._firestore);

  /// Convert Firestore data to JSON-serializable format
  dynamic _convertToJsonSerializable(dynamic value) {
    if (value == null) return null;
    
    // Handle Timestamp
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    
    // Handle DateTime
    if (value is DateTime) {
      return value.toIso8601String();
    }
    
    // Handle GeoPoint
    if (value is GeoPoint) {
      return {
        'latitude': value.latitude,
        'longitude': value.longitude,
      };
    }
    
    // Handle DocumentReference
    if (value is DocumentReference) {
      return value.path;
    }
    
    // Handle Map
    if (value is Map) {
      return value.map((key, val) => MapEntry(
        key.toString(),
        _convertToJsonSerializable(val),
      ));
    }
    
    // Handle List
    if (value is List) {
      return value.map((item) => _convertToJsonSerializable(item)).toList();
    }
    
    // Handle other types (String, int, double, bool, etc.)
    return value;
  }

  /// Backup all data from Firestore to JSON with progress tracking
  Future<Map<String, dynamic>> backupAllData({ProgressCallback? onProgress}) async {
    final backup = <String, dynamic>{
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'data': <String, dynamic>{},
    };

    try {
      const totalSteps = 10;
      int currentStep = 0;

      // Backup users
      onProgress?.call('Backing up users...', currentStep / totalSteps);
      final usersSnapshot = await _firestore.collection('users').get();
      backup['data']['users'] = usersSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
            };
          })
          .toList();
      currentStep++;

      // Backup categories
      onProgress?.call('Backing up categories...', currentStep / totalSteps);
      final categoriesSnapshot = await _firestore.collection('categories').get();
      backup['data']['categories'] = categoriesSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
            };
          })
          .toList();
      currentStep++;

      // Backup products
      onProgress?.call('Backing up products...', currentStep / totalSteps);
      final productsSnapshot = await _firestore.collection('products').get();
      backup['data']['products'] = productsSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
            };
          })
          .toList();
      currentStep++;

      // Backup customers
      onProgress?.call('Backing up customers...', currentStep / totalSteps);
      try {
        final customersSnapshot = await _firestore.collection('customers').get();
        final customersList = customersSnapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
              };
            })
            .toList();
        backup['data']['customers'] = customersList;
        print('Backed up ${customersList.length} customers');
      } catch (e) {
        print('Error backing up customers: $e');
        // Continue with empty list rather than failing completely
        backup['data']['customers'] = <Map<String, dynamic>>[];
      }
      currentStep++;

      // Backup sales (with items)
      onProgress?.call('Backing up sales...', currentStep / totalSteps);
      final salesSnapshot = await _firestore.collection('sales').get();
      final sales = <Map<String, dynamic>>[];
      int saleIndex = 0;
      for (final saleDoc in salesSnapshot.docs) {
        final saleDocData = saleDoc.data();
        final saleData = {
          'id': saleDoc.id,
          ...saleDocData.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
        };
        
        // Get sale items
        final itemsSnapshot = await saleDoc.reference.collection('items').get();
        saleData['items'] = itemsSnapshot.docs
            .map((itemDoc) {
              final itemData = itemDoc.data();
              return {
                'id': itemDoc.id,
                ...itemData.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
              };
            })
            .toList();
        
        sales.add(saleData);
        saleIndex++;
        if (saleIndex % 10 == 0) {
          onProgress?.call('Backing up sales ($saleIndex/${salesSnapshot.docs.length})...', 
              (currentStep + (saleIndex / salesSnapshot.docs.length) * 0.5) / totalSteps);
        }
      }
      backup['data']['sales'] = sales;
      currentStep++;

      // Backup cash sessions
      onProgress?.call('Backing up cash sessions...', currentStep / totalSteps);
      final cashSessionsSnapshot = await _firestore.collection('cashSessions').get();
      backup['data']['cashSessions'] = cashSessionsSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
            };
          })
          .toList();
      currentStep++;

      // Backup stock levels
      onProgress?.call('Backing up stock levels...', currentStep / totalSteps);
      final stockLevelsSnapshot = await _firestore.collection('stockLevels').get();
      backup['data']['stockLevels'] = stockLevelsSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
            };
          })
          .toList();
      currentStep++;

      // Backup stock movements
      onProgress?.call('Backing up stock movements...', currentStep / totalSteps);
      final stockMovementsSnapshot = await _firestore.collection('stockMovements').get();
      backup['data']['stockMovements'] = stockMovementsSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
            };
          })
          .toList();
      currentStep++;

      // Backup branches
      onProgress?.call('Backing up branches...', currentStep / totalSteps);
      final branchesSnapshot = await _firestore.collection('branches').get();
      backup['data']['branches'] = branchesSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
            };
          })
          .toList();
      currentStep++;

      // Backup tax rates
      onProgress?.call('Backing up tax rates...', currentStep / totalSteps);
      final taxRatesSnapshot = await _firestore.collection('taxRates').get();
      backup['data']['taxRates'] = taxRatesSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data.map((key, value) => MapEntry(key, _convertToJsonSerializable(value))),
            };
          })
          .toList();
      currentStep++;

      onProgress?.call('Preparing backup file...', 1.0);
      return backup;
    } catch (e) {
      throw Exception('Failed to backup data: $e');
    }
  }

  /// Export backup to file with progress tracking
  Future<void> exportBackup({ProgressCallback? onProgress}) async {
    try {
      // Create backup data with progress
      final backup = await backupAllData(onProgress: onProgress);
      
      onProgress?.call('Converting to JSON...', 0.95);
      
      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      
      // Generate filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'aronium_backup_$timestamp.json';
      
      onProgress?.call('Exporting file...', 0.98);
      
      // Export file
      await FileHelper.saveAndShare(
        content: jsonString,
        fileName: fileName,
        subject: 'Aronium POS Backup',
      );
      
      onProgress?.call('Backup completed!', 1.0);
      
      // Small delay to show completion
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to export backup: $e');
    }
  }
}

