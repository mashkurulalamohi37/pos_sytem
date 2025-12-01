import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String username;
  final String role;
  final String? fullName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    this.id,
    required this.username,
    required this.role,
    this.fullName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isCashier => role == 'cashier';

  @override
  List<Object?> get props => [
        id,
        username,
        role,
        fullName,
        isActive,
        createdAt,
        updatedAt,
      ];
}

