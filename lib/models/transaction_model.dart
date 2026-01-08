import 'package:cloud_firestore/cloud_firestore.dart';

/// Transaction/Sales model
class TransactionModel {
  final String id;
  final String productId;
  final String productName; // Denormalized for easier display
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final DateTime transactionDate;
  final String? customerName; // Optional customer info
  final String? notes; // Optional transaction notes

  TransactionModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.transactionDate,
    this.customerName,
    this.notes,
  });

  /// Create TransactionModel from Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      customerName: data['customerName'],
      notes: data['notes'],
    );
  }

  /// Convert TransactionModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'customerName': customerName,
      'notes': notes,
    };
  }

  /// Create a copy with updated fields
  TransactionModel copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    DateTime? transactionDate,
    String? customerName,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionDate: transactionDate ?? this.transactionDate,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
    );
  }
}
