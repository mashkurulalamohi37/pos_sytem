import 'package:equatable/equatable.dart';

class CashSession extends Equatable {
  final int? id;
  final int userId;
  final int branchId;
  final double openingCash;
  final double expectedCash;
  final double? countedCash;
  final double? difference;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String status;
  final String? notes;

  const CashSession({
    this.id,
    required this.userId,
    required this.branchId,
    this.openingCash = 0.0,
    this.expectedCash = 0.0,
    this.countedCash,
    this.difference,
    required this.openedAt,
    this.closedAt,
    this.status = 'open',
    this.notes,
  });

  bool get isOpen => status == 'open';
  bool get isClosed => status == 'closed';

  @override
  List<Object?> get props => [
        id,
        userId,
        branchId,
        openingCash,
        expectedCash,
        countedCash,
        difference,
        openedAt,
        closedAt,
        status,
        notes,
      ];
}

