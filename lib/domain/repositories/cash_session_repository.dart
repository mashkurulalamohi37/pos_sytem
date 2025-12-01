import '../entities/cash_session.dart';

abstract class CashSessionRepository {
  Future<CashSession> openSession(CashSession session);
  Future<CashSession> closeSession(int sessionId, double countedCash, String? notes);
  Future<CashSession?> getCurrentSession(int userId, int branchId);
  Future<List<CashSession>> getSessions({
    int? userId,
    int? branchId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<CashSession?> getSessionById(int id);
  Future<void> updateExpectedCash(int sessionId, double amount);
}

