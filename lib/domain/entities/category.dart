import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final int? parentCategoryId; // Parent category ID for subcategories
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    this.id,
    required this.name,
    this.description,
    this.parentCategoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSubcategory => parentCategoryId != null;

  Category copyWith({
    int? id,
    String? name,
    String? description,
    int? parentCategoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, parentCategoryId, createdAt, updatedAt];
}

