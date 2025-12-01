import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final double loyaltyPoints;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.loyaltyPoints = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        loyaltyPoints,
        isActive,
        createdAt,
        updatedAt,
      ];
}

