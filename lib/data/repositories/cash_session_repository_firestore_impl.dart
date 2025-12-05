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

    // Always generate a new document ID when opening a session
    final docId = generateDocId();
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

    // Recalculate expected cash from all cash sales during the session
    final recalculatedExpectedCash = await _calculateExpectedCash(
      session.userId,
      session.branchId,
      session.openedAt,
      session.openingCash,
    );

    final difference = countedCash - recalculatedExpectedCash;
    final now = DateTime.now();

    // Find the document by searching for open sessions matching the session ID hash
    // Since sessionId is a hash of doc.id, we need to find the doc that produces this hash
    final snapshot = await _firestore.collection('cashSessions')
        .where('userId', isEqualTo: session.userId)
        .where('branchId', isEqualTo: session.branchId)
        .where('status', isEqualTo: 'open')
        .get();

    // Find the document whose ID hash matches the sessionId
    DocumentSnapshot? matchingDoc;
    for (final doc in snapshot.docs) {
      // Check if this document's ID hash matches the sessionId
      if (doc.id.hashCode == sessionId) {
        matchingDoc = doc;
        break;
      }
    }

    // If not found by hash, try matching by openedAt (fallback)
    if (matchingDoc == null) {
      for (final doc in snapshot.docs) {
        final dataMap = doc.data() as Map<String, dynamic>;
        final docOpenedAt = (dataMap['openedAt'] as Timestamp?)?.toDate();
        if (docOpenedAt != null) {
          // Compare dates with tolerance (within 5 seconds)
          final timeDiff = (docOpenedAt.difference(session.openedAt)).abs();
          if (timeDiff.inSeconds <= 5) {
            matchingDoc = doc;
            break;
          }
        }
      }
    }

    if (matchingDoc == null) {
      throw Exception('Session document not found. SessionId: $sessionId, UserId: ${session.userId}, BranchId: ${session.branchId}');
    }

    // Update the document
    await matchingDoc.reference.update({
      'expectedCash': recalculatedExpectedCash,
      'countedCash': countedCash,
      'difference': difference,
      'closedAt': Timestamp.fromDate(now),
      'status': 'closed',
      'notes': notes,
    });

    return session.copyWith(
      expectedCash: recalculatedExpectedCash,
      countedCash: countedCash,
      difference: difference,
      closedAt: now,
      status: 'closed',
      notes: notes,
    );
  }

  /// Calculate expected cash: openingCash + sum of all cash sales during session
  Future<double> _calculateExpectedCash(
    int userId,
    int branchId,
    DateTime sessionOpenedAt,
    double openingCash,
  ) async {
    // Firestore requires composite indexes for multiple where clauses with range queries
    // To avoid index requirements, we'll fetch sales with minimal filters and filter in memory
    // This works fine for small to medium datasets
    
    // Fetch sales for this user/branch (using only two where clauses to avoid index requirement)
    // Note: We don't use orderBy here to avoid index requirements
    final salesSnapshot = await _firestore.collection('sales')
        .where('userId', isEqualTo: userId)
        .where('branchId', isEqualTo: branchId)
        .get();

    // Filter in memory for paymentMethod, status, and date range
    double totalCashSales = 0.0;
    for (final doc in salesSnapshot.docs) {
      final data = doc.data();
      final paymentMethod = data['paymentMethod'] as String? ?? '';
      final status = data['status'] as String? ?? '';
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      
      // Check if sale matches our criteria
      if (paymentMethod == 'cash' && 
          status == 'completed' && 
          createdAt != null && 
          createdAt.isAfter(sessionOpenedAt.subtract(const Duration(seconds: 1)))) {
        final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        totalCashSales += totalAmount;
      }
    }

    return openingCash + totalCashSales;
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

    // Find the document using simpler query
    final snapshot = await _firestore.collection('cashSessions')
        .where('userId', isEqualTo: session.userId)
        .where('branchId', isEqualTo: session.branchId)
        .get();

    // Find the matching session by comparing openedAt in memory
    DocumentSnapshot? matchingDoc;
    for (final doc in snapshot.docs) {
      final dataMap = doc.data() as Map<String, dynamic>;
      final docOpenedAt = (dataMap['openedAt'] as Timestamp?)?.toDate();
      if (docOpenedAt != null) {
        // Compare dates (ignore milliseconds for matching)
        final sessionOpenedAtRounded = DateTime(
          session.openedAt.year,
          session.openedAt.month,
          session.openedAt.day,
          session.openedAt.hour,
          session.openedAt.minute,
          session.openedAt.second,
        );
        final docOpenedAtRounded = DateTime(
          docOpenedAt.year,
          docOpenedAt.month,
          docOpenedAt.day,
          docOpenedAt.hour,
          docOpenedAt.minute,
          docOpenedAt.second,
        );
        if (sessionOpenedAtRounded == docOpenedAtRounded) {
          matchingDoc = doc;
          break;
        }
      }
    }

    if (matchingDoc == null) {
      throw Exception('Session document not found');
    }

    await matchingDoc.reference.update({
      'expectedCash': amount,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Calculate and update expected cash for current session
  Future<void> recalculateExpectedCash(int sessionId) async {
    final session = await getSessionById(sessionId);
    if (session == null || session.status != 'open') return;

    final recalculatedExpectedCash = await _calculateExpectedCash(
      session.userId,
      session.branchId,
      session.openedAt,
      session.openingCash,
    );

    await updateExpectedCash(sessionId, recalculatedExpectedCash);
  }

  domain.CashSession _toCashSession(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Session document has no data');
    }
    final dataMap = data as Map<String, dynamic>;
    // Use document ID hash as numeric ID for compatibility
    final numericId = doc.id.hashCode;
    return domain.CashSession(
      id: numericId,
      userId: (dataMap['userId'] as num?)?.toInt() ?? 0,
      branchId: (dataMap['branchId'] as num?)?.toInt() ?? 0,
      openingCash: (dataMap['openingCash'] as num?)?.toDouble() ?? 0.0,
      expectedCash: (dataMap['expectedCash'] as num?)?.toDouble() ?? 0.0,
      countedCash: (dataMap['countedCash'] as num?)?.toDouble(),
      difference: (dataMap['difference'] as num?)?.toDouble(),
      openedAt: (dataMap['openedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      closedAt: (dataMap['closedAt'] as Timestamp?)?.toDate(),
      status: dataMap['status'] as String? ?? 'open',
      notes: dataMap['notes'] as String?,
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

