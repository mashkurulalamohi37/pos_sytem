import '../../domain/entities/cash_session.dart' as domain;
import '../../domain/repositories/cash_session_repository.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class CashSessionRepositoryImpl implements CashSessionRepository {
  final AppDatabase _db;

  CashSessionRepositoryImpl(this._db);

  @override
  Future<domain.CashSession> openSession(domain.CashSession session) async {
    final companion = CashSessionsCompanion(
      userId: Value(session.userId),
      branchId: Value(session.branchId),
      openingCash: Value(session.openingCash),
      expectedCash: Value(session.expectedCash),
      status: const Value('open'),
      openedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.cashSessions).insert(companion);
    return session.copyWith(id: id);
  }

  @override
  Future<domain.CashSession> closeSession(
    int sessionId,
    double countedCash,
    String? notes,
  ) async {
    final session = await getSessionById(sessionId);
    if (session == null) throw Exception('Session not found');

    final difference = countedCash - session.expectedCash;

    await (_db.update(_db.cashSessions)..where((cs) => cs.id.equals(sessionId)))
        .write(CashSessionsCompanion(
      countedCash: Value(countedCash),
      difference: Value(difference),
      closedAt: Value(DateTime.now()),
      status: const Value('closed'),
      notes: Value(notes),
    ));

    return session.copyWith(
      countedCash: countedCash,
      difference: difference,
      closedAt: DateTime.now(),
      status: 'closed',
      notes: notes,
    );
  }

  @override
  Future<domain.CashSession?> getCurrentSession(int userId, int branchId) async {
    final session = await (_db.select(_db.cashSessions)
          ..where((cs) => cs.userId.equals(userId))
          ..where((cs) => cs.branchId.equals(branchId))
          ..where((cs) => cs.status.equals('open')))
        .getSingleOrNull();
    return session != null ? _toCashSession(session) : null;
  }

  @override
  Future<List<domain.CashSession>> getSessions({
    int? userId,
    int? branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _db.select(_db.cashSessions);

    if (userId != null) {
      query = query..where((cs) => cs.userId.equals(userId));
    }
    if (branchId != null) {
      query = query..where((cs) => cs.branchId.equals(branchId));
    }
    if (startDate != null) {
      query = query..where((cs) => cs.openedAt.isBiggerOrEqual(Constant(startDate)));
    }
    if (endDate != null) {
      query = query..where((cs) => cs.openedAt.isSmallerOrEqual(Constant(endDate)));
    }

    query = query..orderBy([(cs) => OrderingTerm.desc(cs.openedAt)]);

    final sessions = await query.get();
    return sessions.map((s) => _toCashSession(s)).toList();
  }

  @override
  Future<domain.CashSession?> getSessionById(int id) async {
    final session = await (_db.select(_db.cashSessions)
          ..where((cs) => cs.id.equals(id)))
        .getSingleOrNull();
    return session != null ? _toCashSession(session) : null;
  }

  @override
  Future<void> updateExpectedCash(int sessionId, double amount) async {
    await (_db.update(_db.cashSessions)..where((cs) => cs.id.equals(sessionId)))
        .write(CashSessionsCompanion(
      expectedCash: Value(amount),
    ));
  }

  domain.CashSession _toCashSession(CashSession dbSession) {
    return domain.CashSession(
      id: dbSession.id,
      userId: dbSession.userId,
      branchId: dbSession.branchId,
      openingCash: dbSession.openingCash,
      expectedCash: dbSession.expectedCash,
      countedCash: dbSession.countedCash,
      difference: dbSession.difference,
      openedAt: dbSession.openedAt,
      closedAt: dbSession.closedAt,
      status: dbSession.status,
      notes: dbSession.notes,
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

