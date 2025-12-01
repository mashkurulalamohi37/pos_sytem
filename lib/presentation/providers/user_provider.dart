import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_firestore_impl.dart';
import 'firebase_provider.dart';

class UserState {
  final List<User> users;
  final bool isLoading;
  final String? error;

  UserState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _userRepository;

  UserNotifier(this._userRepository) : super(UserState()) {
    loadUsers();
  }

  Future<void> loadUsers({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await _userRepository.getUsers(search: search);
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createUser(User user, String password) async {
    try {
      await _userRepository.createUser(user, password);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      await _userRepository.updateUser(user);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateUserRole(int userId, String newRole) async {
    try {
      await _userRepository.updateUserRole(userId, newRole);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      await _userRepository.deleteUser(userId);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> activateUser(int userId) async {
    try {
      await _userRepository.activateUser(userId);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deactivateUser(int userId) async {
    try {
      await _userRepository.deactivateUser(userId);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return UserRepositoryFirestoreImpl(auth, firestore);
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return UserNotifier(userRepo);
});

