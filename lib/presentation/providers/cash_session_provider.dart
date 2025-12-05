import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cash_session.dart';
import '../../domain/repositories/cash_session_repository.dart';
import 'repository_providers.dart';

class CashSessionState {
  final CashSession? currentSession;
  final List<CashSession> sessions;
  final bool isLoading;

  CashSessionState({
    this.currentSession,
    this.sessions = const [],
    this.isLoading = false,
  });

  CashSessionState copyWith({
    CashSession? currentSession,
    List<CashSession>? sessions,
    bool? isLoading,
  }) {
    return CashSessionState(
      currentSession: currentSession ?? this.currentSession,
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CashSessionNotifier extends StateNotifier<CashSessionState> {
  final CashSessionRepository _cashSessionRepository;

  CashSessionNotifier(this._cashSessionRepository) : super(CashSessionState()) {
    // Don't load sessions here - wait for user context
  }

  Future<void> loadCurrentSession(int userId, int branchId) async {
    try {
      final session = await _cashSessionRepository.getCurrentSession(userId, branchId);
      state = state.copyWith(currentSession: session);
    } catch (e) {
      // Handle error
      print('Error loading current session: $e');
    }
  }


  Future<void> loadSessions({int? userId, int? branchId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final sessions = await _cashSessionRepository.getSessions(
        userId: userId,
        branchId: branchId,
      );
      state = state.copyWith(
        sessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Log error for debugging
      print('Error loading sessions: $e');
    }
  }

  Future<void> openSession(CashSession session) async {
    try {
      state = state.copyWith(isLoading: true);
      await _cashSessionRepository.openSession(session);
      // Reload to get the session with ID
      await loadCurrentSession(session.userId, session.branchId);
      await loadSessions(userId: session.userId, branchId: session.branchId);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Refresh expected cash for current session by recalculating from sales
  Future<void> refreshExpectedCash() async {
    final currentSession = state.currentSession;
    if (currentSession != null && currentSession.id != null && currentSession.isOpen) {
      try {
        // Recalculate expected cash from sales
        // This will be done by the repository when we reload
        await loadCurrentSession(currentSession.userId, currentSession.branchId);
      } catch (e) {
        print('Error refreshing expected cash: $e');
      }
    }
  }

  Future<void> closeSession(int sessionId, double countedCash, String? notes) async {
    try {
      final currentSession = state.currentSession;
      if (currentSession == null) {
        // If no current session, just return silently (might already be closed)
        return;
      }
      
      if (currentSession.id != sessionId) {
        throw Exception('Session ID mismatch');
      }
      
      // Check if session is already closed
      if (currentSession.isClosed) {
        // Session is already closed, just clear state and reload
        final userId = currentSession.userId;
        final branchId = currentSession.branchId;
        state = state.copyWith(currentSession: null);
        await loadCurrentSession(userId, branchId);
        await loadSessions(userId: userId, branchId: branchId);
        return;
      }
      
      final userId = currentSession.userId;
      final branchId = currentSession.branchId;
      
      state = state.copyWith(isLoading: true);
      
      // Close the session in the repository
      await _cashSessionRepository.closeSession(sessionId, countedCash, notes);
      
      // Immediately clear current session from state to update UI
      state = state.copyWith(currentSession: null, isLoading: false);
      
      // Reload current session to verify it's closed (should return null)
      // This ensures we're in sync with Firestore
      await loadCurrentSession(userId, branchId);
      
      // Reload sessions list to include the newly closed session
      await loadSessions(userId: userId, branchId: branchId);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      
      // If error is "already closed", handle gracefully
      if (e.toString().contains('already closed') || e.toString().contains('Session is already closed')) {
        final currentSession = state.currentSession;
        if (currentSession != null) {
          final userId = currentSession.userId;
          final branchId = currentSession.branchId;
          state = state.copyWith(currentSession: null);
          await loadCurrentSession(userId, branchId);
          await loadSessions(userId: userId, branchId: branchId);
        }
        return; // Don't throw error, just sync state
      }
      
      // For other errors, reload to get current state
      final currentSession = state.currentSession;
      if (currentSession != null) {
        await loadCurrentSession(currentSession.userId, currentSession.branchId);
      }
      rethrow;
    }
  }
}

final cashSessionProvider = StateNotifierProvider<CashSessionNotifier, CashSessionState>((ref) {
  final cashSessionRepo = ref.watch(cashSessionRepositoryProvider);
  return CashSessionNotifier(cashSessionRepo);
});

