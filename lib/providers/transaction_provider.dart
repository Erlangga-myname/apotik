import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/product_service.dart';

/// Transaction state provider
class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _totalSales = 0;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalSales => _totalSales;

  /// Initialize transactions stream
  void initTransactions() {
    _transactionService.getTransactionsStream().listen((transactions) {
      _transactions = transactions;
      _calculateTotalSales();
    });
  }

  /// Calculate total sales
  void _calculateTotalSales() {
    _totalSales = _transactions.fold(
      0,
      (sum, transaction) => sum + transaction.totalAmount,
    );
    notifyListeners();
  }

  /// Add transaction and update product stock
  Future<bool> addTransaction(TransactionModel transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('💰 Adding transaction for product: ${transaction.productName}');

      // Get current product to check stock
      final product = await _productService.getProduct(transaction.productId);

      if (product == null) {
        throw 'Product not found';
      }

      print(
        '📦 Current stock: ${product.stock}, Requested: ${transaction.quantity}',
      );

      if (product.stock < transaction.quantity) {
        throw 'Insufficient stock. Available: ${product.stock}';
      }

      // Add transaction
      await _transactionService.addTransaction(transaction);
      print('✅ Transaction added successfully');

      // Update product stock
      final newStock = product.stock - transaction.quantity;
      await _productService.updateStock(transaction.productId, newStock);
      print('📊 Stock updated: ${product.stock} → $newStock');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Transaction failed: $e');
      // Clean up error message by removing "Exception:" prefix if present
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete transaction
  Future<bool> deleteTransaction(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _transactionService.deleteTransaction(id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get today's sales
  Future<double> getTodaySales() async {
    try {
      return await _transactionService.getTodaySales();
    } catch (e) {
      return 0;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
