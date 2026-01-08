import 'package:cloud_firestore/cloud_firestore.dart';

/// Category model for product categorization
class CategoryModel {
  final String id;
  final String name;
  final String description;
  final int colorValue; // Store color as int for Firestore
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.colorValue,
    required this.createdAt,
  });

  /// Create CategoryModel from Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      colorValue: data['colorValue'] ?? 0xFF00897B, // Default to primary color
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert CategoryModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'colorValue': colorValue,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
