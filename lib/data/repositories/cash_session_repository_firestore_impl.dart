import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cash_session.dart' as domain;
import '../../domain/repositories/cash_session_repository.dart';
import 'firestore_utils.dart';

class CashSessionRepositoryFirestoreImpl implements CashSessionRepository {
  final FirebaseFirestore _firestore;

  CashSessionRepositoryFirestoreImpl(this._firestore);

  @override
  Future<domain.CashSession> openSession(domain.CashSession session) async {
    // Check if there's already an open session for this user/branch
    final existingSession = await getCurrentSession(session.userId, session.branchId);
    if (existingSession != null) {
      throw Exception('An open session already exists for this user and branch');
    }

    final docId = session.id != null ? idToDocId(session.id!) : generateDocId();
    final now = DateTime.now();

    await _firestore.collection('cashSessions').doc(docId).set({
      'userId': session.userId,
      'branchId': session.branchId,
      'openingCash': session.openingCash,
      'expectedCash': session.expectedCash,
      'status': 'open',
      'openedAt': Timestamp.fromDate(now),
    });

    // Use doc ID hash as numeric ID for compatibility
    final numericId = docId.hashCode;
    return session.copyWith(id: numericId, openedAt: now, status: 'open');
  }

  @override
  Future<domain.CashSession> closeSession(
    int sessionId,
    double countedCash,
    String? notes,
  ) async {
    final session = await getSessionById(sessionId);
    if (session == null) throw Exception('Session not found');

    if (session.status == 'closed') {
      throw Exception('Session is already closed');
    }

    final difference = countedCash - session.expectedCash;
    final now = DateTime.now();

    // Find the document by searching for the session
    final snapshot = await _firestore.collection('cashSessions')
        .where('userId', isEqualTo: session.userId)
        .where('branchId', isEqualTo: session.branchId)
        .where('openedAt', isEqualTo: Timestamp.fromDate(session.openedAt))
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Session document not found');
    }

    await snapshot.docs.first.reference.update({
      'countedCash': countedCash,
      'difference': difference,
      'closedAt': Timestamp.fromDate(now),
      'status': 'closed',
      'notes': notes,
    });

    return session.copyWith(
      countedCash: countedCash,
      difference: difference,
      closedAt: now,
      status: 'closed',
      notes: notes,
    );
  }

  @override
  Future<domain.CashSession?> getCurrentSession(int userId, int branchId) async {
    final snapshot = await _firestore.collection('cashSessions')
        .where('userId', isEqualTo: userId)
        .where('branchId', isEqualTo: branchId)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return _toCashSession(snapshot.docs.first);
  }

  @override
  Future<List<domain.CashSession>> getSessions({
    int? userId,
    int? branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore.collection('cashSessions');

    // Firestore requires composite indexes for multiple where clauses with orderBy
    // To avoid index requirements, we'll fetch all sessions and filter in memory
    // This works fine for small to medium datasets
    
    // If we only have one filter, we can use it in the query
    if (userId != null && branchId == null) {
      query = query.where('userId', isEqualTo: userId);
    } else if (branchId != null && userId == null) {
      query = query.where('branchId', isEqualTo: branchId);
    }
    // If both are provided or neither, we'll filter in memory

    // Always order by openedAt
    query = query.orderBy('openedAt', descending: true);

    final snapshot = await query.get();
    var sessions = snapshot.docs.map((doc) => _toCashSession(doc)).toList();

    // Filter in memory for userId and branchId if both are provided
    if (userId != null && branchId != null) {
      sessions = sessions.where((s) => s.userId == userId && s.branchId == branchId).toList();
    } else if (userId != null && branchId == null) {
      // Already filtered by query, but double-check
      sessions = sessions.where((s) => s.userId == userId).toList();
    } else if (branchId != null && userId == null) {
      // Already filtered by query, but double-check
      sessions = sessions.where((s) => s.branchId == branchId).toList();
    }

    // Filter by date in memory if provided
    if (startDate != null) {
      sessions = sessions.where((s) => s.openedAt.isAfter(startDate.subtract(const Duration(seconds: 1)))).toList();
    }
    if (endDate != null) {
      sessions = sessions.where((s) => s.openedAt.isBefore(endDate.add(const Duration(days: 1)))).toList();
    }

    return sessions;
  }

  @override
  Future<domain.CashSession?> getSessionById(int id) async {
    // Since we use hash codes as IDs, we need to search all sessions
    // This is not ideal but works for now
    final snapshot = await _firestore.collection('cashSessions').get();
    for (final doc in snapshot.docs) {
      final session = _toCashSession(doc);
      if (session.id == id) {
        return session;
      }
    }
    return null;
  }

  @override
  Future<void> updateExpectedCash(int sessionId, double amount) async {
    final session = await getSessionById(sessionId);
    if (session == null) throw Exception('Session not found');

    // Find the document
    final snapshot = await _firestore.collection('cashSessions')
        .where('userId', isEqualTo: session.userId)
        .where('branchId', isEqualTo: session.branchId)
        .where('openedAt', isEqualTo: Timestamp.fromDate(session.openedAt))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Session document not found');
    }

    await snapshot.docs.first.reference.update({
      'expectedCash': amount,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  domain.CashSession _toCashSession(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Use document ID hash as numeric ID for compatibility
    final numericId = doc.id.hashCode;
    return domain.CashSession(
      id: numericId,
      userId: (data['userId'] as num?)?.toInt() ?? 0,
      branchId: (data['branchId'] as num?)?.toInt() ?? 0,
      openingCash: (data['openingCash'] as num?)?.toDouble() ?? 0.0,
      expectedCash: (data['expectedCash'] as num?)?.toDouble() ?? 0.0,
      countedCash: (data['countedCash'] as num?)?.toDouble(),
      difference: (data['difference'] as num?)?.toDouble(),
      openedAt: (data['openedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      closedAt: (data['closedAt'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'open',
      notes: data['notes'] as String?,
    );
  }
}

extension CashSessionCopyWith on domain.CashSession {
  domain.CashSession copyWith({
    int? id,
    int? userId,
    int? branchId,
    double? openingCash,
    double? expectedCash,
    double? countedCash,
    double? difference,
    DateTime? openedAt,
    DateTime? closedAt,
    String? status,
    String? notes,
  }) {
    return domain.CashSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      branchId: branchId ?? this.branchId,
      openingCash: openingCash ?? this.openingCash,
      expectedCash: expectedCash ?? this.expectedCash,
      countedCash: countedCash ?? this.countedCash,
      difference: difference ?? this.difference,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

