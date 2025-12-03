import 'package:equatable/equatable.dart';

class TaxRate extends Equatable {
  final int? id;
  final String name;
  final double rate; // Percentage (e.g., 15.0 for 15%)
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaxRate({
    this.id,
    required this.name,
    required this.rate,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        rate,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];
}

