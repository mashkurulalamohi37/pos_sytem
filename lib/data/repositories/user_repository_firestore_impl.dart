import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/user_repository.dart';
import 'firestore_utils.dart';

class UserRepositoryFirestoreImpl implements UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserRepositoryFirestoreImpl(this._auth, this._firestore);

  @override
  Future<List<domain.User>> getUsers({String? search}) async {
    Query query = _firestore.collection('users');

    final snapshot = await query.get();
    var users = snapshot.docs.map((doc) => _toUser(doc)).toList();

    // Filter by search if provided
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      users = users.where((u) {
        return u.username.toLowerCase().contains(searchLower) ||
               (u.fullName?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    return users;
  }

  @override
  Future<domain.User?> getUserById(int id) async {
    // Search all users and find by ID match (ID is hash of UID)
    final snapshot = await _firestore.collection('users').get();
    for (final doc in snapshot.docs) {
      final user = _toUser(doc);
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<domain.User?> getUserByUsername(String username) async {
    final snapshot = await _firestore.collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return _toUser(snapshot.docs.first);
  }

  @override
  Future<domain.User> createUser(domain.User user, String password) async {
    try {
      // Create user in Firebase Auth
      final email = user.username.contains('@') 
          ? user.username 
          : '${user.username}@aronium.local';
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final authUser = userCredential.user;
      if (authUser == null) {
        throw Exception('Failed to create user in Firebase Auth');
      }

      // Create user document in Firestore using UID as document ID
      final now = DateTime.now();
      await _firestore.collection('users').doc(authUser.uid).set({
        'uid': authUser.uid, // Store UID for reference
        'username': user.username,
        'role': user.role,
        'fullName': user.fullName,
        'isActive': user.isActive,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      // Use UID hash as numeric ID for domain entity compatibility
      final numericId = authUser.uid.hashCode;
      
      return user.copyWith(
        id: numericId,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  @override
  Future<domain.User> updateUser(domain.User user) async {
    if (user.id == null) throw Exception('User ID is required');

    // Find the document by searching for the user
    final snapshot = await _firestore.collection('users')
        .where('username', isEqualTo: user.username)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    await snapshot.docs.first.reference.update({
      'role': user.role,
      'fullName': user.fullName,
      'isActive': user.isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    return user;
  }

  @override
  Future<void> updateUserRole(int userId, String newRole) async {
    // Find user by ID
    final user = await getUserById(userId);
    if (user == null) throw Exception('User not found');

    // Find document by username
    final snapshot = await _firestore.collection('users')
        .where('username', isEqualTo: user.username)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      throw Exception('User document not found');
    }

    await snapshot.docs.first.reference.update({
      'role': newRole,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> deleteUser(int userId) async {
    // Find user by ID
    final user = await getUserById(userId);
    if (user == null) throw Exception('User not found');

    // Find document by username
    final snapshot = await _firestore.collection('users')
        .where('username', isEqualTo: user.username)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      throw Exception('User document not found');
    }

    final docId = snapshot.docs.first.id;
    final username = user.username;
    final email = username.contains('@') ? username : '$username@aronium.local';

    // Note: Firebase Admin SDK is needed to delete users from Auth
    // For now, we'll just deactivate the user in Firestore
    // In production, you should use Firebase Admin SDK to delete the auth user
    await snapshot.docs.first.reference.update({
      'isActive': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> activateUser(int userId) async {
    final user = await getUserById(userId);
    if (user == null) throw Exception('User not found');

    final snapshot = await _firestore.collection('users')
        .where('username', isEqualTo: user.username)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      throw Exception('User document not found');
    }

    await snapshot.docs.first.reference.update({
      'isActive': true,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> deactivateUser(int userId) async {
    final user = await getUserById(userId);
    if (user == null) throw Exception('User not found');

    final snapshot = await _firestore.collection('users')
        .where('username', isEqualTo: user.username)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      throw Exception('User document not found');
    }

    await snapshot.docs.first.reference.update({
      'isActive': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  domain.User _toUser(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Use document ID hash as numeric ID for compatibility
    final numericId = doc.id.hashCode;
    return domain.User(
      id: numericId,
      username: data['username'] as String,
      role: data['role'] as String? ?? 'cashier',
      fullName: data['fullName'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// Extension to add copyWith to User
extension UserCopyWith on domain.User {
  domain.User copyWith({
    int? id,
    String? username,
    String? role,
    String? fullName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return domain.User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

