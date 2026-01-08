import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication state provider
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  /// Initialize auth state
  Future<void> initAuth() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _user = await _authService.getUserData(currentUser.uid);
      notifyListeners();
    }
  }

  /// Sign in
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔐 Attempting login for: $email');
      _user = await _authService.signIn(email, password);
      _isLoading = false;

      if (_user != null) {
        print('✅ Login successful for: ${_user!.email}');
      }

      notifyListeners();
      return _user != null;
    } catch (e) {
      print('❌ Login failed: $e');
      // Clean up error message by removing "Exception:" prefix if present
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📝 Attempting registration for: $email');
      _user = await _authService.register(email, password, name);
      _isLoading = false;

      if (_user != null) {
        print('✅ Registration successful for: ${_user!.email}');
      }

      notifyListeners();
      return _user != null;
    } catch (e) {
      print('❌ Registration failed: $e');
      // Clean up error message by removing "Exception:" prefix if present
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
