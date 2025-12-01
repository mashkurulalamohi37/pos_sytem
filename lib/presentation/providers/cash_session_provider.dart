import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cash_session.dart';
import '../../domain/repositories/cash_session_repository.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

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
      await _cashSessionRepository.openSession(session);
      await loadCurrentSession(session.userId, session.branchId);
      await loadSessions(userId: session.userId, branchId: session.branchId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeSession(int sessionId, double countedCash, String? notes) async {
    try {
      final currentSession = state.currentSession;
      await _cashSessionRepository.closeSession(sessionId, countedCash, notes);
      // Clear current session since it's now closed
      state = state.copyWith(currentSession: null);
      // Reload sessions with the same user/branch filters
      if (currentSession != null) {
        await loadSessions(userId: currentSession.userId, branchId: currentSession.branchId);
      } else {
        await loadSessions();
      }
    } catch (e) {
      rethrow;
    }
  }
}

final cashSessionProvider = StateNotifierProvider<CashSessionNotifier, CashSessionState>((ref) {
  final cashSessionRepo = ref.watch(cashSessionRepositoryProvider);
  return CashSessionNotifier(cashSessionRepo);
});

