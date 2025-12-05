import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';

typedef ProgressCallback = void Function(String message, double progress);

enum DataCollectionType {
  products,
  sales,
  inventory,
  customers,
  cashSessions,
  categories,
  taxRates,
  branches,
}

class ClearDataService {
  final FirebaseFirestore _firestore;

  ClearDataService(this._firestore);

  /// Clear selected data collections with progress tracking
  Future<void> clearSelectedData({
    required Set<DataCollectionType> collectionsToClear,
    ProgressCallback? onProgress,
  }) async {
    if (collectionsToClear.isEmpty) {
      throw Exception('No collections selected to clear');
    }

    try {
      // Calculate total steps based on selected collections
      int totalSteps = collectionsToClear.length;
      if (collectionsToClear.contains(DataCollectionType.sales)) {
        totalSteps += 1; // Extra step for sale items
      }
      if (collectionsToClear.contains(DataCollectionType.inventory)) {
        totalSteps += 1; // Extra steps for stock levels and movements
      }
      
      int currentStep = 0;

      // Get all users to preserve them (always preserve users)
      onProgress?.call('Preparing to clear data...', currentStep / totalSteps);
      final usersSnapshot = await _firestore.collection('users').get();
      final usersToPreserve = <String, Map<String, dynamic>>{};
      
      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final role = userData['role'] as String? ?? '';
        // Preserve admin, manager, and cashier users
        if (role == AppConstants.roleAdmin || 
            role == AppConstants.roleManager || 
            role == AppConstants.roleCashier) {
          usersToPreserve[userDoc.id] = userData;
        }
      }

      // Clear categories
      if (collectionsToClear.contains(DataCollectionType.categories)) {
        onProgress?.call('Deleting categories...', currentStep / totalSteps);
        final categoriesSnapshot = await _firestore.collection('categories').get();
        final categoriesBatch = _firestore.batch();
        for (final doc in categoriesSnapshot.docs) {
          categoriesBatch.delete(doc.reference);
        }
        await categoriesBatch.commit();
        currentStep++;
      }

      // Clear products
      if (collectionsToClear.contains(DataCollectionType.products)) {
        onProgress?.call('Deleting products...', currentStep / totalSteps);
        final productsSnapshot = await _firestore.collection('products').get();
        final productsBatch = _firestore.batch();
        for (final doc in productsSnapshot.docs) {
          productsBatch.delete(doc.reference);
        }
        await productsBatch.commit();
        currentStep++;
      }

      // Clear customers (handle large batches)
      if (collectionsToClear.contains(DataCollectionType.customers)) {
        onProgress?.call('Deleting customers...', currentStep / totalSteps);
        final customersSnapshot = await _firestore.collection('customers').get();
        int customerIndex = 0;
        WriteBatch? customersBatch;
        for (final doc in customersSnapshot.docs) {
          if (customersBatch == null || customerIndex % 500 == 0) {
            if (customersBatch != null) {
              await customersBatch.commit();
            }
            customersBatch = _firestore.batch();
          }
          customersBatch.delete(doc.reference);
          customerIndex++;
        }
        if (customersBatch != null) {
          await customersBatch.commit();
        }
        currentStep++;
      }

      // Clear sales (including items)
      if (collectionsToClear.contains(DataCollectionType.sales)) {
        onProgress?.call('Deleting sales...', currentStep / totalSteps);
        final salesSnapshot = await _firestore.collection('sales').get();
        int saleIndex = 0;
        for (final saleDoc in salesSnapshot.docs) {
          // Delete sale items
          final itemsSnapshot = await saleDoc.reference.collection('items').get();
          final itemsBatch = _firestore.batch();
          for (final itemDoc in itemsSnapshot.docs) {
            itemsBatch.delete(itemDoc.reference);
          }
          await itemsBatch.commit();
          
          // Delete sale document
          await saleDoc.reference.delete();
          
          saleIndex++;
          if (saleIndex % 10 == 0) {
            onProgress?.call('Deleting sales ($saleIndex/${salesSnapshot.docs.length})...', 
                (currentStep + (saleIndex / salesSnapshot.docs.length) * 0.5) / totalSteps);
          }
        }
        currentStep++;
      }

      // Clear cash sessions
      if (collectionsToClear.contains(DataCollectionType.cashSessions)) {
        onProgress?.call('Deleting cash sessions...', currentStep / totalSteps);
        final cashSessionsSnapshot = await _firestore.collection('cashSessions').get();
        final cashSessionsBatch = _firestore.batch();
        for (final doc in cashSessionsSnapshot.docs) {
          cashSessionsBatch.delete(doc.reference);
        }
        await cashSessionsBatch.commit();
        currentStep++;
      }

      // Clear inventory (stock levels and movements)
      if (collectionsToClear.contains(DataCollectionType.inventory)) {
        // Delete stock levels
        onProgress?.call('Deleting stock levels...', currentStep / totalSteps);
        final stockLevelsSnapshot = await _firestore.collection('stockLevels').get();
        int stockLevelIndex = 0;
        WriteBatch? stockLevelsBatch;
        for (final doc in stockLevelsSnapshot.docs) {
          if (stockLevelsBatch == null || stockLevelIndex % 500 == 0) {
            if (stockLevelsBatch != null) {
              await stockLevelsBatch.commit();
            }
            stockLevelsBatch = _firestore.batch();
          }
          stockLevelsBatch.delete(doc.reference);
          stockLevelIndex++;
        }
        if (stockLevelsBatch != null) {
          await stockLevelsBatch.commit();
        }
        currentStep++;

        // Delete stock movements
        onProgress?.call('Deleting stock movements...', currentStep / totalSteps);
        final stockMovementsSnapshot = await _firestore.collection('stockMovements').get();
        int stockMovementIndex = 0;
        WriteBatch? stockMovementsBatch;
        for (final doc in stockMovementsSnapshot.docs) {
          if (stockMovementsBatch == null || stockMovementIndex % 500 == 0) {
            if (stockMovementsBatch != null) {
              await stockMovementsBatch.commit();
            }
            stockMovementsBatch = _firestore.batch();
          }
          stockMovementsBatch.delete(doc.reference);
          stockMovementIndex++;
        }
        if (stockMovementsBatch != null) {
          await stockMovementsBatch.commit();
        }
        currentStep++;
      }

      // Clear branches
      if (collectionsToClear.contains(DataCollectionType.branches)) {
        onProgress?.call('Deleting branches...', currentStep / totalSteps);
        final branchesSnapshot = await _firestore.collection('branches').get();
        final branchesBatch = _firestore.batch();
        for (final doc in branchesSnapshot.docs) {
          branchesBatch.delete(doc.reference);
        }
        await branchesBatch.commit();
        currentStep++;
      }

      // Clear tax rates
      if (collectionsToClear.contains(DataCollectionType.taxRates)) {
        onProgress?.call('Deleting tax rates...', currentStep / totalSteps);
        final taxRatesSnapshot = await _firestore.collection('taxRates').get();
        final taxRatesBatch = _firestore.batch();
        for (final doc in taxRatesSnapshot.docs) {
          taxRatesBatch.delete(doc.reference);
        }
        await taxRatesBatch.commit();
        currentStep++;
      }

      onProgress?.call('Data cleared successfully!', 1.0);
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  /// Clear all data except users (admin, cashier, manager) and customers with progress tracking
  /// This is kept for backward compatibility
  Future<void> clearAllData({ProgressCallback? onProgress}) async {
    await clearSelectedData(
      collectionsToClear: {
        DataCollectionType.products,
        DataCollectionType.sales,
        DataCollectionType.inventory,
        DataCollectionType.cashSessions,
        DataCollectionType.categories,
        DataCollectionType.taxRates,
        DataCollectionType.branches,
        // Note: customers are NOT included by default
      },
      onProgress: onProgress,
    );
    try {
      const totalSteps = 10;
      int currentStep = 0;

      // Get all users to preserve them
      onProgress?.call('Preparing to clear data...', currentStep / totalSteps);
      final usersSnapshot = await _firestore.collection('users').get();
      final usersToPreserve = <String, Map<String, dynamic>>{};
      
      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final role = userData['role'] as String? ?? '';
        // Preserve admin, manager, and cashier users
        if (role == AppConstants.roleAdmin || 
            role == AppConstants.roleManager || 
            role == AppConstants.roleCashier) {
          usersToPreserve[userDoc.id] = userData;
        }
      }
      currentStep++;

      // Delete all categories
      onProgress?.call('Deleting categories...', currentStep / totalSteps);
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final categoriesBatch = _firestore.batch();
      for (final doc in categoriesSnapshot.docs) {
        categoriesBatch.delete(doc.reference);
      }
      await categoriesBatch.commit();
      currentStep++;

      // Delete all products
      onProgress?.call('Deleting products...', currentStep / totalSteps);
      final productsSnapshot = await _firestore.collection('products').get();
      final productsBatch = _firestore.batch();
      for (final doc in productsSnapshot.docs) {
        productsBatch.delete(doc.reference);
      }
      await productsBatch.commit();
      currentStep++;

      // Customers are preserved - skip deletion

      // Delete all sales (including items)
      onProgress?.call('Deleting sales...', currentStep / totalSteps);
      final salesSnapshot = await _firestore.collection('sales').get();
      int saleIndex = 0;
      for (final saleDoc in salesSnapshot.docs) {
        // Delete sale items
        final itemsSnapshot = await saleDoc.reference.collection('items').get();
        final itemsBatch = _firestore.batch();
        for (final itemDoc in itemsSnapshot.docs) {
          itemsBatch.delete(itemDoc.reference);
        }
        await itemsBatch.commit();
        
        // Delete sale document
        await saleDoc.reference.delete();
        
        saleIndex++;
        if (saleIndex % 10 == 0) {
          onProgress?.call('Deleting sales ($saleIndex/${salesSnapshot.docs.length})...', 
              (currentStep + (saleIndex / salesSnapshot.docs.length) * 0.5) / totalSteps);
        }
      }
      currentStep++;

      // Delete all cash sessions
      onProgress?.call('Deleting cash sessions...', currentStep / totalSteps);
      final cashSessionsSnapshot = await _firestore.collection('cashSessions').get();
      final cashSessionsBatch = _firestore.batch();
      for (final doc in cashSessionsSnapshot.docs) {
        cashSessionsBatch.delete(doc.reference);
      }
      await cashSessionsBatch.commit();
      currentStep++;

      // Delete all stock levels (handle large batches)
      onProgress?.call('Deleting stock levels...', currentStep / totalSteps);
      final stockLevelsSnapshot = await _firestore.collection('stockLevels').get();
      int stockLevelIndex = 0;
      WriteBatch? stockLevelsBatch;
      for (final doc in stockLevelsSnapshot.docs) {
        if (stockLevelsBatch == null || stockLevelIndex % 500 == 0) {
          if (stockLevelsBatch != null) {
            await stockLevelsBatch.commit();
          }
          stockLevelsBatch = _firestore.batch();
        }
        stockLevelsBatch.delete(doc.reference);
        stockLevelIndex++;
      }
      if (stockLevelsBatch != null) {
        await stockLevelsBatch.commit();
      }
      currentStep++;

      // Delete all stock movements (handle large batches)
      onProgress?.call('Deleting stock movements...', currentStep / totalSteps);
      final stockMovementsSnapshot = await _firestore.collection('stockMovements').get();
      int stockMovementIndex = 0;
      WriteBatch? stockMovementsBatch;
      for (final doc in stockMovementsSnapshot.docs) {
        if (stockMovementsBatch == null || stockMovementIndex % 500 == 0) {
          if (stockMovementsBatch != null) {
            await stockMovementsBatch.commit();
          }
          stockMovementsBatch = _firestore.batch();
        }
        stockMovementsBatch.delete(doc.reference);
        stockMovementIndex++;
      }
      if (stockMovementsBatch != null) {
        await stockMovementsBatch.commit();
      }
      currentStep++;

      // Delete all branches
      onProgress?.call('Deleting branches...', currentStep / totalSteps);
      final branchesSnapshot = await _firestore.collection('branches').get();
      final branchesBatch = _firestore.batch();
      for (final doc in branchesSnapshot.docs) {
        branchesBatch.delete(doc.reference);
      }
      await branchesBatch.commit();
      currentStep++;

      // Delete all tax rates
      onProgress?.call('Deleting tax rates...', currentStep / totalSteps);
      final taxRatesSnapshot = await _firestore.collection('taxRates').get();
      final taxRatesBatch = _firestore.batch();
      for (final doc in taxRatesSnapshot.docs) {
        taxRatesBatch.delete(doc.reference);
      }
      await taxRatesBatch.commit();
      currentStep++;

      // Delete all users, then restore preserved ones
      onProgress?.call('Clearing users...', currentStep / totalSteps);
      final allUsersSnapshot = await _firestore.collection('users').get();
      final usersBatch = _firestore.batch();
      for (final doc in allUsersSnapshot.docs) {
        usersBatch.delete(doc.reference);
      }
      await usersBatch.commit();
      currentStep++;

      // Restore preserved users
      onProgress?.call('Restoring user accounts...', currentStep / totalSteps);
      if (usersToPreserve.isNotEmpty) {
        final restoreUsersBatch = _firestore.batch();
        for (final entry in usersToPreserve.entries) {
          restoreUsersBatch.set(
            _firestore.collection('users').doc(entry.key),
            entry.value,
          );
        }
        await restoreUsersBatch.commit();
      }
      currentStep++;

      onProgress?.call('Data cleared successfully!', 1.0);
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }
}

