import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'restore_service_io.dart' if (dart.library.html) 'restore_service_web.dart' as file_impl;

typedef ProgressCallback = void Function(String message, double progress);

class RestoreService {
  final FirebaseFirestore _firestore;

  RestoreService(this._firestore);

  /// Restore data from JSON backup with progress tracking
  Future<void> restoreFromJson(Map<String, dynamic> backup, {ProgressCallback? onProgress}) async {
    try {
      final data = backup['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid backup format: missing data');
      }

      const totalSteps = 10;
      int currentStep = 0;

      // Restore users (handle large batches)
      if (data['users'] != null) {
        onProgress?.call('Restoring users...', currentStep / totalSteps);
        final users = data['users'] as List;
        WriteBatch? currentBatch;
        int userIndex = 0;
        for (final user in users) {
          if (currentBatch == null || userIndex % 500 == 0) {
            if (currentBatch != null) {
              await currentBatch.commit();
            }
            currentBatch = _firestore.batch();
          }
          final userMap = user as Map<String, dynamic>;
          final docId = userMap['id'] as String? ?? userMap['id'].toString();
          userMap.remove('id');
          final convertedUserMap = _convertDatesToTimestamp(userMap);
          currentBatch.set(_firestore.collection('users').doc(docId), convertedUserMap);
          userIndex++;
        }
        if (currentBatch != null) {
          await currentBatch.commit();
        }
      }
      currentStep++;

      // Restore categories (handle large batches)
      if (data['categories'] != null) {
        onProgress?.call('Restoring categories...', currentStep / totalSteps);
        final categories = data['categories'] as List;
        WriteBatch? currentBatch;
        int categoryIndex = 0;
        for (final category in categories) {
          if (currentBatch == null || categoryIndex % 500 == 0) {
            if (currentBatch != null) {
              await currentBatch.commit();
            }
            currentBatch = _firestore.batch();
          }
          final categoryMap = category as Map<String, dynamic>;
          final docId = categoryMap['id'] as String? ?? categoryMap['id'].toString();
          categoryMap.remove('id');
          final convertedCategoryMap = _convertDatesToTimestamp(categoryMap);
          currentBatch.set(_firestore.collection('categories').doc(docId), convertedCategoryMap);
          categoryIndex++;
        }
        if (currentBatch != null) {
          await currentBatch.commit();
        }
      }
      currentStep++;

      // Restore products (handle large batches)
      if (data['products'] != null) {
        onProgress?.call('Restoring products...', currentStep / totalSteps);
        final products = data['products'] as List;
        WriteBatch? currentBatch;
        int productIndex = 0;
        for (final product in products) {
          if (currentBatch == null || productIndex % 500 == 0) {
            if (currentBatch != null) {
              await currentBatch.commit();
            }
            currentBatch = _firestore.batch();
          }
          final productMap = product as Map<String, dynamic>;
          final docId = productMap['id'] as String? ?? productMap['id'].toString();
          productMap.remove('id');
          final convertedProductMap = _convertDatesToTimestamp(productMap);
          currentBatch.set(_firestore.collection('products').doc(docId), convertedProductMap);
          productIndex++;
        }
        if (currentBatch != null) {
          await currentBatch.commit();
        }
      }
      currentStep++;

      // Restore customers (handle large batches)
      if (data['customers'] != null) {
        onProgress?.call('Restoring customers...', currentStep / totalSteps);
        final customers = data['customers'] as List;
        print('Found ${customers.length} customers to restore');
        if (customers.isNotEmpty) {
          WriteBatch? currentBatch;
          int customerIndex = 0;
          for (final customer in customers) {
            try {
              if (currentBatch == null || customerIndex % 500 == 0) {
                if (currentBatch != null) {
                  await currentBatch.commit();
                }
                currentBatch = _firestore.batch();
              }
              final customerMap = customer as Map<String, dynamic>;
              final docId = customerMap['id'] as String? ?? customerMap['id'].toString();
              
              if (docId.isEmpty) {
                // Skip customers without valid IDs
                customerIndex++;
                continue;
              }
              
              customerMap.remove('id');
              final convertedCustomerMap = _convertDatesToTimestamp(customerMap);
              
              // Ensure required fields exist
              if (convertedCustomerMap['name'] == null || convertedCustomerMap['name'].toString().isEmpty) {
                // Skip customers without names
                customerIndex++;
                continue;
              }
              
              currentBatch.set(_firestore.collection('customers').doc(docId), convertedCustomerMap);
              customerIndex++;
            } catch (e) {
              // Log error but continue with other customers
              print('Error restoring customer at index $customerIndex: $e');
              customerIndex++;
            }
          }
          if (currentBatch != null) {
            try {
              await currentBatch.commit();
              print('Successfully restored $customerIndex customers');
            } catch (e) {
              throw Exception('Failed to commit customer batch: $e');
            }
          }
        } else {
          print('No customers to restore (empty list)');
        }
      } else {
        print('No customers found in backup data');
      }
      currentStep++;

      // Restore sales (with items)
      if (data['sales'] != null) {
        onProgress?.call('Restoring sales...', currentStep / totalSteps);
        final sales = data['sales'] as List;
        int saleIndex = 0;
        for (final sale in sales) {
          final saleMap = sale as Map<String, dynamic>;
          final docId = saleMap['id'] as String? ?? saleMap['id'].toString();
          final items = saleMap['items'] as List?;
          saleMap.remove('id');
          saleMap.remove('items');
          
          // Convert date strings back to Timestamp if needed
          final convertedSaleMap = _convertDatesToTimestamp(saleMap);
          
          // Set sale document
          await _firestore.collection('sales').doc(docId).set(convertedSaleMap);
          
          // Set sale items (handle large batches)
          if (items != null && items.isNotEmpty) {
            WriteBatch? itemsBatch;
            int itemIndex = 0;
            for (final item in items) {
              if (itemsBatch == null || itemIndex % 500 == 0) {
                if (itemsBatch != null) {
                  await itemsBatch.commit();
                }
                itemsBatch = _firestore.batch();
              }
              final itemMap = item as Map<String, dynamic>;
              final itemId = itemMap['id'] as String? ?? itemMap['id'].toString();
              itemMap.remove('id');
              final convertedItemMap = _convertDatesToTimestamp(itemMap);
              itemsBatch.set(
                _firestore.collection('sales').doc(docId).collection('items').doc(itemId),
                convertedItemMap,
              );
              itemIndex++;
            }
            if (itemsBatch != null) {
              await itemsBatch.commit();
            }
          }
          
          saleIndex++;
          if (saleIndex % 10 == 0) {
            onProgress?.call('Restoring sales ($saleIndex/${sales.length})...', 
                (currentStep + (saleIndex / sales.length) * 0.5) / totalSteps);
          }
        }
      }
      currentStep++;

      // Restore cash sessions (handle large batches)
      if (data['cashSessions'] != null) {
        onProgress?.call('Restoring cash sessions...', currentStep / totalSteps);
        final cashSessions = data['cashSessions'] as List;
        WriteBatch? currentBatch;
        int sessionIndex = 0;
        for (final session in cashSessions) {
          if (currentBatch == null || sessionIndex % 500 == 0) {
            if (currentBatch != null) {
              await currentBatch.commit();
            }
            currentBatch = _firestore.batch();
          }
          final sessionMap = session as Map<String, dynamic>;
          final docId = sessionMap['id'] as String? ?? sessionMap['id'].toString();
          sessionMap.remove('id');
          final convertedSessionMap = _convertDatesToTimestamp(sessionMap);
          currentBatch.set(_firestore.collection('cashSessions').doc(docId), convertedSessionMap);
          sessionIndex++;
        }
        if (currentBatch != null) {
          await currentBatch.commit();
        }
      }
      currentStep++;

      // Restore stock levels (handle large batches)
      if (data['stockLevels'] != null) {
        onProgress?.call('Restoring stock levels...', currentStep / totalSteps);
        final stockLevels = data['stockLevels'] as List;
        WriteBatch? currentBatch;
        int stockLevelIndex = 0;
        for (final stockLevel in stockLevels) {
          if (currentBatch == null || stockLevelIndex % 500 == 0) {
            if (currentBatch != null) {
              await currentBatch.commit();
            }
            currentBatch = _firestore.batch();
          }
          final stockLevelMap = stockLevel as Map<String, dynamic>;
          final docId = stockLevelMap['id'] as String? ?? stockLevelMap['id'].toString();
          stockLevelMap.remove('id');
          final convertedStockLevelMap = _convertDatesToTimestamp(stockLevelMap);
          currentBatch.set(_firestore.collection('stockLevels').doc(docId), convertedStockLevelMap);
          stockLevelIndex++;
        }
        if (currentBatch != null) {
          await currentBatch.commit();
        }
      }
      currentStep++;

      // Restore stock movements (handle large batches)
      if (data['stockMovements'] != null) {
        onProgress?.call('Restoring stock movements...', currentStep / totalSteps);
        final stockMovements = data['stockMovements'] as List;
        WriteBatch? currentBatch;
        int movementIndex = 0;
        for (final movement in stockMovements) {
          if (currentBatch == null || movementIndex % 500 == 0) {
            if (currentBatch != null) {
              await currentBatch.commit();
            }
            currentBatch = _firestore.batch();
          }
          final movementMap = movement as Map<String, dynamic>;
          final docId = movementMap['id'] as String? ?? movementMap['id'].toString();
          movementMap.remove('id');
          final convertedMovementMap = _convertDatesToTimestamp(movementMap);
          currentBatch.set(_firestore.collection('stockMovements').doc(docId), convertedMovementMap);
          movementIndex++;
        }
        if (currentBatch != null) {
          await currentBatch.commit();
        }
      }
      currentStep++;

      // Restore branches (handle large batches)
      if (data['branches'] != null) {
        onProgress?.call('Restoring branches...', currentStep / totalSteps);
        final branches = data['branches'] as List;
        WriteBatch? currentBatch;
        int branchIndex = 0;
        for (final branch in branches) {
          if (currentBatch == null || branchIndex % 500 == 0) {
            if (currentBatch != null) {
              await currentBatch.commit();
            }
            currentBatch = _firestore.batch();
          }
          final branchMap = branch as Map<String, dynamic>;
          final docId = branchMap['id'] as String? ?? branchMap['id'].toString();
          branchMap.remove('id');
          currentBatch.set(_firestore.collection('branches').doc(docId), branchMap);
          branchIndex++;
        }
        if (currentBatch != null) {
          await currentBatch.commit();
        }
      }
      currentStep++;

      // Restore tax rates (handle large batches)
      if (data['taxRates'] != null) {
        onProgress?.call('Restoring tax rates...', currentStep / totalSteps);
        final taxRates = data['taxRates'] as List;
        WriteBatch? currentBatch;
        int taxRateIndex = 0;
        for (final taxRate in taxRates) {
          if (currentBatch == null || taxRateIndex % 500 == 0) {
            if (currentBatch != null) {
              await currentBatch.commit();
            }
            currentBatch = _firestore.batch();
          }
          final taxRateMap = taxRate as Map<String, dynamic>;
          final docId = taxRateMap['id'] as String? ?? taxRateMap['id'].toString();
          taxRateMap.remove('id');
          currentBatch.set(_firestore.collection('taxRates').doc(docId), taxRateMap);
          taxRateIndex++;
        }
        if (currentBatch != null) {
          await currentBatch.commit();
        }
      }
      currentStep++;

      onProgress?.call('Data restored successfully!', 1.0);
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to restore data: $e');
    }
  }

  /// Convert date strings back to Firestore Timestamps
  Map<String, dynamic> _convertDatesToTimestamp(Map<String, dynamic> data) {
    final converted = Map<String, dynamic>.from(data);
    
    // Convert all fields that might be date strings
    for (final key in converted.keys) {
      final value = converted[key];
      if (value is String) {
        // Try to parse as ISO8601 date string
        try {
          final dateTime = DateTime.parse(value);
          // Only convert if it's a valid date (not just any string)
          // Check if it's in ISO8601 format (contains 'T' or ends with 'Z' or has timezone)
          if (value.contains('T') || value.endsWith('Z') || value.contains('+') || value.contains('-')) {
            converted[key] = Timestamp.fromDate(dateTime);
          }
        } catch (e) {
          // Not a date string, keep original value
        }
      } else if (value is Map<String, dynamic>) {
        // Recursively convert nested maps
        converted[key] = _convertDatesToTimestamp(value);
      } else if (value is List) {
        // Convert lists that might contain date strings
        converted[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _convertDatesToTimestamp(item);
          } else if (item is String) {
            try {
              final dateTime = DateTime.parse(item);
              if (item.contains('T') || item.endsWith('Z') || item.contains('+') || item.contains('-')) {
                return Timestamp.fromDate(dateTime);
              }
            } catch (e) {
              // Not a date string
            }
          }
          return item;
        }).toList();
      }
    }
    
    return converted;
  }

  /// Pick and restore from file with progress tracking
  Future<void> pickAndRestore({ProgressCallback? onProgress}) async {
    try {
      onProgress?.call('Selecting backup file...', 0.0);
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      onProgress?.call('Reading backup file...', 0.05);
      final file = result.files.single;
      
      String jsonString;
      if (kIsWeb) {
        // For web, read from bytes
        if (file.bytes == null) {
          throw Exception('Failed to read file');
        }
        jsonString = String.fromCharCodes(file.bytes!);
      } else {
        // For mobile, read from path
        if (file.path == null) {
          throw Exception('Failed to read file path');
        }
        final filePath = file.path!;
        // Use platform-specific file reading
        jsonString = await file_impl.RestoreServiceFileImpl.readFile(filePath);
      }
      
      onProgress?.call('Parsing backup data...', 0.1);
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;
      
      await restoreFromJson(backup, onProgress: onProgress);
    } catch (e) {
      throw Exception('Failed to pick and restore: $e');
    }
  }
}

