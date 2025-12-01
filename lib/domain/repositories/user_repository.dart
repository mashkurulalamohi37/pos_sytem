import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers({String? search});
  Future<User?> getUserById(int id);
  Future<User?> getUserByUsername(String username);
  Future<User> createUser(User user, String password);
  Future<User> updateUser(User user);
  Future<void> updateUserRole(int userId, String newRole);
  Future<void> deleteUser(int userId);
  Future<void> activateUser(int userId);
  Future<void> deactivateUser(int userId);
}

