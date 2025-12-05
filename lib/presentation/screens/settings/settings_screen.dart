import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firebase_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/customer_provider.dart';
import '../../../data/services/backup_service.dart';
import '../../../data/services/restore_service.dart';
import '../../../data/services/clear_data_service.dart';
import 'clear_data_selection_dialog.dart';
import 'sku_settings_screen.dart';

/// Progress dialog widget for backup operations
class _BackupProgressDialog extends StatefulWidget {
  final String message;
  final double progress;

  const _BackupProgressDialog({
    super.key,
    required this.message,
    required this.progress,
  });

  @override
  State<_BackupProgressDialog> createState() => _BackupProgressDialogState();
}

class _BackupProgressDialogState extends State<_BackupProgressDialog> {
  late String _message;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _message = widget.message;
    _progress = widget.progress;
  }

  void updateProgress(String message, double progress) {
    if (mounted) {
      setState(() {
        _message = message;
        _progress = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please wait, this may take a few moments...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // User Info Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      user?.username[0].toUpperCase() ?? '?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? user?.username ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.role.toUpperCase() ?? 'UNKNOWN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Administration Section
          if (user?.isAdmin ?? false) ...[
            _buildSectionHeader(context, 'Administration'),
            _buildSettingTile(
              context,
              icon: Icons.people,
              title: 'User Management',
              subtitle: 'Manage users, roles, and permissions',
              onTap: () {
                Navigator.pushNamed(context, '/users');
              },
            ),
          ],

          // Configuration Section
          if ((user?.isAdmin ?? false) || (user?.isManager ?? false)) ...[
            _buildSectionHeader(context, 'Configuration'),
            _buildSettingTile(
              context,
              icon: Icons.receipt_long,
              title: 'Tax Rates',
              subtitle: 'Manage tax rates for products',
              onTap: () {
                Navigator.pushNamed(context, '/tax-rates');
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.qr_code,
              title: 'SKU Generator',
              subtitle: 'Configure automatic SKU generation',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SkuSettingsScreen()),
                );
              },
            ),
          ],

          // Data Management Section

          // Data Management Section
          _buildSectionHeader(context, 'General'),
          _buildSettingTile(
            context,
            icon: Icons.backup,
            title: 'Backup Data',
            subtitle: 'Export database backup',
            onTap: () => _handleBackup(context, ref),
          ),
          _buildSettingTile(
            context,
            icon: Icons.restore,
            title: 'Restore Data',
            subtitle: 'Import database backup',
            onTap: () => _handleRestore(context, ref),
          ),
          _buildSettingTile(
            context,
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Delete all data except users',
            onTap: () => _handleClearData(context, ref),
            isDestructive: true,
          ),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildSettingTile(
            context,
            icon: Icons.info,
            title: 'App Version',
            subtitle: 'Current version information',
            onTap: null,
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
    final firestore = ref.read(firestoreProvider);
    final backupService = BackupService(firestore);

    // Show progress dialog
    if (!context.mounted) return;
    
    String currentMessage = 'Initializing backup...';
    double currentProgress = 0.0;
    
    // Create a stateful dialog that can be updated
    final progressKey = GlobalKey<_BackupProgressDialogState>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: _BackupProgressDialog(
          key: progressKey,
          message: currentMessage,
          progress: currentProgress,
        ),
      ),
    );

    try {
      await backupService.exportBackup(
        onProgress: (message, progress) {
          currentMessage = message;
          currentProgress = progress;
          // Update dialog state
          if (progressKey.currentState != null) {
            progressKey.currentState!.updateProgress(message, progress);
          }
        },
      );
      
      // Small delay to show 100% completion
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close progress dialog
      if (!context.mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Backup exported successfully!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close progress dialog
      if (!context.mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Backup failed: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'This will replace all existing data with the backup. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final firestore = ref.read(firestoreProvider);
    final restoreService = RestoreService(firestore);

    // Show progress dialog
    if (!context.mounted) return;
    
    String currentMessage = 'Initializing restore...';
    double currentProgress = 0.0;
    
    final progressKey = GlobalKey<_BackupProgressDialogState>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: _BackupProgressDialog(
          key: progressKey,
          message: currentMessage,
          progress: currentProgress,
        ),
      ),
    );

    try {
      await restoreService.pickAndRestore(
        onProgress: (message, progress) {
          currentMessage = message;
          currentProgress = progress;
          if (progressKey.currentState != null) {
            progressKey.currentState!.updateProgress(message, progress);
          }
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close progress dialog
      if (!context.mounted) return;
      
      // Refresh all providers to show restored data
      ref.read(productProvider.notifier).loadProducts(includeInactive: true);
      ref.read(productProvider.notifier).loadCategories();
      ref.read(inventoryProvider.notifier).loadMovements();
      ref.read(inventoryProvider.notifier).loadBranches();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Data restored successfully!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close progress dialog
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Restore failed: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _handleClearData(BuildContext context, WidgetRef ref) async {
    // Show selection dialog
    final selectedCollections = await showDialog<Set<DataCollectionType>>(
      context: context,
      builder: (context) => const ClearDataSelectionDialog(),
    );

    if (selectedCollections == null || selectedCollections.isEmpty) return;

    // Build confirmation message
    final selectedNames = <String>[];
    if (selectedCollections.contains(DataCollectionType.products)) {
      selectedNames.add('Products');
    }
    if (selectedCollections.contains(DataCollectionType.sales)) {
      selectedNames.add('Sales');
    }
    if (selectedCollections.contains(DataCollectionType.inventory)) {
      selectedNames.add('Inventory (Stock Levels & Movements)');
    }
    if (selectedCollections.contains(DataCollectionType.customers)) {
      selectedNames.add('Customers');
    }
    if (selectedCollections.contains(DataCollectionType.cashSessions)) {
      selectedNames.add('Cash Sessions');
    }
    if (selectedCollections.contains(DataCollectionType.categories)) {
      selectedNames.add('Product Categories');
    }
    if (selectedCollections.contains(DataCollectionType.taxRates)) {
      selectedNames.add('Tax Rates');
    }
    if (selectedCollections.contains(DataCollectionType.branches)) {
      selectedNames.add('Branches');
    }

    // Confirmation dialog
    if (!context.mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirm Data Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are about to permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...selectedNames.map((name) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $name'),
            )),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone!\n\nUser accounts (admin, manager, cashier) will always be preserved.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Selected'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final firestore = ref.read(firestoreProvider);
    final clearDataService = ClearDataService(firestore);

    // Show progress dialog
    if (!context.mounted) return;
    
    String currentMessage = 'Initializing data clear...';
    double currentProgress = 0.0;
    
    final progressKey = GlobalKey<_BackupProgressDialogState>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: _BackupProgressDialog(
          key: progressKey,
          message: currentMessage,
          progress: currentProgress,
        ),
      ),
    );

    try {
      await clearDataService.clearSelectedData(
        collectionsToClear: selectedCollections,
        onProgress: (message, progress) {
          currentMessage = message;
          currentProgress = progress;
          if (progressKey.currentState != null) {
            progressKey.currentState!.updateProgress(message, progress);
          }
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close progress dialog
      if (!context.mounted) return;
      
      // Refresh providers based on what was cleared
      if (selectedCollections.contains(DataCollectionType.products)) {
        ref.read(productProvider.notifier).loadProducts(includeInactive: true);
      }
      if (selectedCollections.contains(DataCollectionType.categories)) {
        ref.read(productProvider.notifier).loadCategories();
      }
      if (selectedCollections.contains(DataCollectionType.customers)) {
        ref.read(customerProvider.notifier).loadCustomers();
      }
      if (selectedCollections.contains(DataCollectionType.inventory)) {
        ref.read(inventoryProvider.notifier).loadMovements();
        ref.read(inventoryProvider.notifier).loadBranches();
      } else if (selectedCollections.contains(DataCollectionType.branches)) {
        ref.read(inventoryProvider.notifier).loadBranches();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Selected data cleared successfully!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close progress dialog
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Clear data failed: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}