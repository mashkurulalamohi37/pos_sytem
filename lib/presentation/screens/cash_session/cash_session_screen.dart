import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/cash_session_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../../domain/entities/cash_session.dart';

class CashSessionScreen extends ConsumerStatefulWidget {
  const CashSessionScreen({super.key});

  @override
  ConsumerState<CashSessionScreen> createState() => _CashSessionScreenState();
}

class _CashSessionScreenState extends ConsumerState<CashSessionScreen> {
  final _startingCashController = TextEditingController();
  final _countedCashController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load current session and past sessions on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      final user = authState.user;
      if (user != null && user.id != null) {
        final branchId = 1; // Default branch
        // Ensure users are loaded for display
        ref.read(userProvider.notifier).loadUsers();
        ref.read(cashSessionProvider.notifier).loadCurrentSession(user.id!, branchId);
        ref.read(cashSessionProvider.notifier).loadSessions(userId: user.id!, branchId: branchId);
      }
    });
  }

  @override
  void dispose() {
    _startingCashController.dispose();
    _countedCashController.dispose();
    super.dispose();
  }

  Future<void> _openSession() async {
    final startingCash = double.tryParse(_startingCashController.text) ?? 0.0;
    if (startingCash < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Starting cash must be positive'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authState = ref.read(authProvider);
    final user = authState.user;
    if (user == null || user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final session = CashSession(
        userId: user.id!,
        branchId: 1, // Default branch - should be configurable
        openingCash: startingCash,
        expectedCash: startingCash,
        openedAt: DateTime.now(),
        status: 'open',
      );
      await ref.read(cashSessionProvider.notifier).openSession(session);
      if (mounted) {
        _startingCashController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session opened successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _closeSession() async {
    final countedCash = double.tryParse(_countedCashController.text);
    if (countedCash == null || countedCash < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid counted cash'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sessionState = ref.read(cashSessionProvider);
    final currentSession = sessionState.currentSession;
    if (currentSession == null || currentSession.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active session found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(cashSessionProvider.notifier).closeSession(
            currentSession.id!,
            countedCash,
            null,
          );
      if (mounted) {
        _countedCashController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session closed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        // If session is already closed, treat it as success (state might be out of sync)
        if (errorMessage.contains('already closed') || errorMessage.contains('Session is already closed')) {
          _countedCashController.clear();
          // Refresh the state
          final authState = ref.read(authProvider);
          final user = authState.user;
          if (user != null && user.id != null) {
            final branchId = 1;
            ref.read(cashSessionProvider.notifier).loadCurrentSession(user.id!, branchId);
            ref.read(cashSessionProvider.notifier).loadSessions(userId: user.id!, branchId: branchId);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session is already closed'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(cashSessionProvider);
    final usersState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Session'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final authState = ref.read(authProvider);
              final user = authState.user;
              if (user != null && user.id != null) {
                final branchId = 1;
                ref.read(cashSessionProvider.notifier).refreshExpectedCash();
                ref.read(cashSessionProvider.notifier).loadCurrentSession(user.id!, branchId);
                ref.read(cashSessionProvider.notifier).loadSessions(userId: user.id!, branchId: branchId);
              }
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: sessionState.isLoading && sessionState.currentSession == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Session Card
                  if (sessionState.currentSession != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Session',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'OPEN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Opened At',
                        DateFormat('MMM dd, yyyy • HH:mm')
                            .format(sessionState.currentSession!.openedAt),
                      ),
                      _buildInfoRow(
                        'Opened By',
                        _getUserName(ref, sessionState.currentSession!.userId, usersState.users) ?? 'Unknown',
                      ),
                      _buildInfoRow(
                        'Starting Cash',
                        'TK ${sessionState.currentSession!.openingCash.toStringAsFixed(2)}',
                      ),
                      _buildInfoRow(
                        'Expected Cash',
                        'TK ${sessionState.currentSession!.expectedCash.toStringAsFixed(2)}',
                      ),
                      // Only show close session UI if session is actually open
                      if (sessionState.currentSession!.isOpen) ...[
                        const Divider(height: 24),
                        // Close Session
                        TextField(
                          controller: _countedCashController,
                          decoration: InputDecoration(
                            labelText: 'Counted Cash *',
                            prefixIcon: const Icon(Icons.attach_money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _closeSession,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Close Session',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const Divider(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This session is already closed',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              // Open Session Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Open New Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _startingCashController,
                        decoration: InputDecoration(
                          labelText: 'Starting Cash *',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _openSession,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Open Session',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // Past Sessions
            Text(
              'Past Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            sessionState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : sessionState.sessions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No past sessions',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 400, // Fixed height for ListView
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: sessionState.sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessionState.sessions[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: session.isClosed
                                        ? Colors.blue.shade50
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    session.isClosed ? Icons.lock : Icons.lock_open,
                                    color: session.isClosed
                                        ? Colors.blue.shade700
                                        : Colors.green.shade700,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  DateFormat('MMM dd, yyyy • HH:mm').format(session.openedAt),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Opened by: ${_getUserName(ref, session.userId, usersState.users) ?? 'Unknown'}',
                                    ),
                                    Text(
                                      'Starting: TK ${session.openingCash.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                                trailing: session.isClosed
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Counted: TK ${session.countedCash!.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Diff: TK ${(session.countedCash! - session.expectedCash).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: (session.countedCash! -
                                                          session.expectedCash) >=
                                                      0
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String? _getUserName(WidgetRef ref, int userId, List users) {
    try {
      // First, check if this is the current logged-in user
      final authState = ref.read(authProvider);
      final currentUser = authState.user;
      if (currentUser != null && currentUser.id == userId) {
        return currentUser.fullName ?? currentUser.username;
      }
      
      // Then search through the users list
      for (final user in users) {
        if (user.id == userId) {
          return user.fullName ?? user.username;
        }
      }
    } catch (e) {
      // If users list is not loaded or has different structure, return null
      print('Error getting user name: $e');
    }
    return null;
  }
}
