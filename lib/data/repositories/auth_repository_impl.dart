import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _db;

  AuthRepositoryImpl(this._db);

  @override
  Future<domain.User?> login(String username, String password) async {
    final query = _db.select(_db.users)
      ..where((u) => u.username.equals(username))
      ..where((u) => u.isActive.equals(true));

    final userData = await query.getSingleOrNull();
    if (userData == null) return null;

    // TODO: Use proper password hashing (bcrypt, etc.)
    if (userData.passwordHash != password) return null;

    return domain.User(
      id: userData.id,
      username: userData.username,
      role: userData.role,
      fullName: userData.fullName,
      isActive: userData.isActive,
      createdAt: userData.createdAt,
      updatedAt: userData.updatedAt,
    );
  }

  @override
  Future<void> logout() async {
    // Clear any local session data if needed
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    // In a real app, store current user in secure storage or state
    // For now, return null - this will be managed by state management
    return null;
  }

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    // TODO: Implement password change
    return false;
  }
}

