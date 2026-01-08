import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../core/constants/app_constants.dart';

/// Transaction service for sales operations
class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get transactions collection reference
  CollectionReference get _transactionsCollection =>
      _firestore.collection(AppConstants.transactionsCollection);

  /// Get all transactions stream
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _transactionsCollection
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  /// Get transactions for a specific date range
  Stream<List<TransactionModel>> getTransactionsByDateRangeStream(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _transactionsCollection
        .where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('transactionDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  /// Get single transaction
  Future<TransactionModel?> getTransaction(String id) async {
    try {
      final doc = await _transactionsCollection.doc(id).get();
      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get transaction: $e';
    }
  }

  /// Add new transaction
  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _transactionsCollection.add(transaction.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add transaction: $e';
    }
  }

  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsCollection.doc(id).delete();
    } catch (e) {
      throw 'Failed to delete transaction: $e';
    }
  }

  /// Get total sales amount
  Future<double> getTotalSales() async {
    try {
      final snapshot = await _transactionsCollection.get();
      double total = 0;
      for (var doc in snapshot.docs) {
        final transaction = TransactionModel.fromFirestore(doc);
        total += transaction.totalAmount;
      }
      return total;
    } catch (e) {
      throw 'Failed to get total sales: $e';
    }
  }

  /// Get sales for today
  Future<double> getTodaySales() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final snapshot = await _transactionsCollection
          .where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('transactionDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final transaction = TransactionModel.fromFirestore(doc);
        total += transaction.totalAmount;
      }
      return total;
    } catch (e) {
      throw 'Failed to get today sales: $e';
    }
  }

  /// Get transaction count
  Future<int> getTransactionCount() async {
    try {
      final snapshot = await _transactionsCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      throw 'Failed to get transaction count: $e';
    }
  }
}
