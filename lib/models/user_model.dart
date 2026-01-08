import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for authentication and user data
class UserModel {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  /// Create UserModel from Firebase User and Firestore data
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
