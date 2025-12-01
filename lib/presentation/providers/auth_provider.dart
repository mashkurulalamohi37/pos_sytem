import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'repository_providers.dart';
import 'firebase_provider.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  StreamSubscription<firebase_auth.User?>? _authStateSubscription;

  AuthNotifier(this._authRepository, this._firebaseAuth) : super(AuthState()) {
    // Listen to Firebase Auth state changes to automatically restore session
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        // User is logged in, fetch user data
        await _checkCurrentUser();
      } else {
        // User is logged out
        state = AuthState();
      }
    });
    
    // Also check immediately for existing session
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkCurrentUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.login(username, password);
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid username or password',
        );
        return false;
      }
    } catch (e) {
      // Extract meaningful error message
      String errorMessage = 'Invalid username or password';
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid username or password';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'User not found. Please create users in Firebase first.';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please verify your email first';
      } else {
        errorMessage = e.toString();
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider) as firebase_auth.FirebaseAuth;
  return AuthNotifier(authRepo, firebaseAuth);
});

