import 'package:cloud_firestore/cloud_firestore.dart';

/// Product/Medicine model
class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName; // Denormalized for easier display
  final int stock;
  final double price;
  final DateTime expiryDate;
  final DateTime createdAt;
  final String? imageUrl; // Optional product image

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.stock,
    required this.price,
    required this.expiryDate,
    required this.createdAt,
    this.imageUrl,
  });

  /// Create ProductModel from Firestore document
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      stock: data['stock'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
    );
  }

  /// Convert ProductModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'stock': stock,
      'price': price,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
    };
  }

  /// Create a copy with updated fields
  ProductModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    int? stock,
    double? price,
    DateTime? expiryDate,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Check if product is expired
  bool get isExpired {
    return expiryDate.isBefore(DateTime.now());
  }

  /// Check if product is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return expiryDate.isAfter(now) && expiryDate.isBefore(thirtyDaysFromNow);
  }

  /// Check if stock is low (less than 10)
  bool get isLowStock {
    return stock < 10 && stock > 0;
  }

  /// Check if out of stock
  bool get isOutOfStock {
    return stock == 0;
  }
}
