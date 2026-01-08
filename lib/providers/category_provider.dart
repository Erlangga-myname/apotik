import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

/// Category state provider
class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize categories stream
  void initCategories() {
    _categoryService.getCategoriesStream().listen((categories) {
      _categories = categories;
      notifyListeners();
    });
  }

  /// Get categories (one-time fetch)
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add category
  Future<bool> addCategory(CategoryModel category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _categoryService.addCategory(category);
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

  /// Update category
  Future<bool> updateCategory(String id, CategoryModel category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _categoryService.updateCategory(id, category);
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

  /// Delete category
  Future<bool> deleteCategory(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _categoryService.deleteCategory(id);
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

  /// Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
