import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  final int? id;
  final String name;
  final String? address;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Branch({
    this.id,
    required this.name,
    this.address,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, address, phone, createdAt, updatedAt];
}

