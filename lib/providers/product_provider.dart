import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

/// Product state provider
class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategoryId;

  List<ProductModel> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Initialize products stream
  void initProducts() {
    _productService.getProductsStream().listen((products) {
      _products = products;
      _applyFilters();
    });
  }

  /// Search products
  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Filter by category
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
  }

  /// Apply search and category filters
  void _applyFilters() {
    _filteredProducts = _products;

    // Apply category filter
    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((product) => product.categoryId == _selectedCategoryId)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  /// Add product
  Future<bool> addProduct(ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.addProduct(product);
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

  /// Update product
  Future<bool> updateProduct(String id, ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.updateProduct(id, product);
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

  /// Delete product
  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.deleteProduct(id);
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

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      return await _productService.getLowStockProductsStream().first;
    } catch (e) {
      return [];
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _applyFilters();
  }
}
