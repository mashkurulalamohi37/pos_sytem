import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryFirestoreImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryFirestoreImpl(this._auth, this._firestore);

  @override
  Future<domain.User?> login(String username, String password) async {
    try {
      // Convert username to email format for Firebase Auth
      // Firebase Auth requires email, so we'll use username@aronium.local
      final email = username.contains('@') ? username : '$username@aronium.local';
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        print('Login failed: user is null');
        return null;
      }

      // Fetch user data from Firestore users collection
      domain.User? user;
      
      try {
        final userDoc = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();
        
        if (userDoc.docs.isNotEmpty) {
          final userData = userDoc.docs.first.data();
          final docId = userDoc.docs.first.id;
          
          user = domain.User(
            id: int.tryParse(docId) ?? 0,
            username: userData['username'] as String? ?? username,
            role: userData['role'] as String? ?? 'cashier',
            fullName: userData['fullName'] as String?,
            isActive: userData['isActive'] as bool? ?? true,
            createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (userData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }
      } catch (e) {
        print('Error fetching user from Firestore: $e');
      }
      
      // Fallback to Firebase Auth user metadata if Firestore query failed
      if (user == null && userCredential.user != null) {
        final authUser = userCredential.user!;
        final userMetadata = authUser.metadata;
        final customClaims = await _getUserRole(authUser.uid);

        user = domain.User(
          id: int.tryParse(authUser.uid) ?? 0,
          username: username,
          role: customClaims['role'] as String? ?? 'cashier',
          fullName: authUser.displayName,
          isActive: true,
          createdAt: userMetadata.creationTime ?? DateTime.now(),
          updatedAt: userMetadata.lastSignInTime ?? DateTime.now(),
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Auth error: ${e.message}');
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _getUserRole(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        return {'role': data['role'] as String? ?? 'cashier'};
      }
    } catch (e) {
      print('Error getting user role: $e');
    }
    return {'role': 'cashier'};
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final email = user.email ?? '';
    final username = email.contains('@') ? email.split('@').first : user.uid;

    // Try to fetch from Firestore users collection first
    try {
      final userDoc = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        final docId = userDoc.docs.first.id;
        
        return domain.User(
          id: int.tryParse(docId) ?? 0,
          username: userData['username'] as String? ?? username,
          role: userData['role'] as String? ?? 'cashier',
          fullName: userData['fullName'] as String?,
          isActive: userData['isActive'] as bool? ?? true,
          createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (userData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }
    } catch (e) {
      print('Error fetching current user from Firestore: $e');
    }

    // Fallback to Firebase Auth user metadata
    final userMetadata = user.metadata;
    final customClaims = await _getUserRole(user.uid);

    return domain.User(
      id: int.tryParse(user.uid) ?? 0,
      username: username,
      role: customClaims['role'] as String? ?? 'cashier',
      fullName: user.displayName,
      isActive: true,
      createdAt: userMetadata.creationTime ?? DateTime.now(),
      updatedAt: userMetadata.lastSignInTime ?? DateTime.now(),
    );
  }

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }
}

