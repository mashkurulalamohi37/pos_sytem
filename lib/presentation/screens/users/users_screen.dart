import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/user.dart' as domain;
import 'user_form_screen.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(userProvider);
    final authState = ref.watch(authProvider);
    final currentUser = authState.user;

    // Only admin can access this screen
    if (currentUser == null || !currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: const Center(
          child: Text('Access denied. Admin only.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserFormScreen(),
                ),
              );
              if (result == true) {
                ref.read(userProvider.notifier).loadUsers();
              }
            },
            tooltip: 'Add User',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(userProvider.notifier).loadUsers();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(userProvider.notifier).loadUsers(search: value.isEmpty ? null : value);
              },
            ),
          ),
          // Users List
          Expanded(
            child: usersState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : usersState.users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: usersState.users.length,
                        itemBuilder: (context, index) {
                          final user = usersState.users[index];
                          return _buildUserCard(user, currentUser);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(domain.User user, domain.User currentUser) {
    final roleColors = {
      'admin': Colors.red,
      'manager': Colors.blue,
      'cashier': Colors.green,
    };

    final roleColor = roleColors[user.role.toLowerCase()] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.2),
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.fullName ?? user.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
                if (!user.isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'INACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.username}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserFormScreen(user: user),
                  ),
                );
                if (result == true) {
                  ref.read(userProvider.notifier).loadUsers();
                }
                break;
              case 'promote_manager':
                await _promoteUser(user, 'manager');
                break;
              case 'promote_cashier':
                await _promoteUser(user, 'cashier');
                break;
              case 'activate':
                await ref.read(userProvider.notifier).activateUser(user.id!);
                break;
              case 'deactivate':
                await ref.read(userProvider.notifier).deactivateUser(user.id!);
                break;
              case 'delete':
                await _deleteUser(user);
                break;
            }
          },
          itemBuilder: (context) {
            final items = <PopupMenuEntry<String>>[];

            // Edit option
            items.add(const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ));

            // Role promotion options
            if (user.role == 'cashier') {
              items.add(const PopupMenuItem(
                value: 'promote_manager',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Promote to Manager'),
                  ],
                ),
              ));
            } else if (user.role == 'manager') {
              items.add(const PopupMenuItem(
                value: 'promote_cashier',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Demote to Cashier'),
                  ],
                ),
              ));
            }

            // Activate/Deactivate
            if (user.isActive) {
              items.add(const PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Deactivate'),
                  ],
                ),
              ));
            } else {
              items.add(const PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Activate'),
                  ],
                ),
              ));
            }

            // Delete option (don't allow deleting yourself)
            if (user.id != currentUser.id) {
              items.add(const PopupMenuDivider());
              items.add(const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ));
            }

            return items;
          },
        ),
      ),
    );
  }

  Future<void> _promoteUser(domain.User user, String newRole) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newRole == 'manager' ? 'Promote' : 'Demote'} User'),
        content: Text(
          'Are you sure you want to ${newRole == 'manager' ? 'promote' : 'demote'} ${user.username} to ${newRole}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref.read(userProvider.notifier).updateUserRole(user.id!, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'User ${newRole == 'manager' ? 'promoted' : 'demoted'} successfully'
                : 'Failed to update user role'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(domain.User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user ${user.username}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref.read(userProvider.notifier).deleteUser(user.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'User deleted successfully' : 'Failed to delete user'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

