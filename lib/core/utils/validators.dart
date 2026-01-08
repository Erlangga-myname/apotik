/// Form validation utilities
class Validators {
  // Private constructor to prevent instantiation
  Validators._();
  
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  /// Validates password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validates required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  /// Validates name (letters and spaces only)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }
  
  /// Validates positive number
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = num.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }
  
  /// Validates non-negative number (can be 0)
  static String? validateNonNegativeNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = num.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    
    return null;
  }
  
  /// Validates price format
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    
    return null;
  }
  
  /// Validates stock quantity
  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stock is required';
    }
    
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Please enter a valid number';
    }
    
    if (stock < 0) {
      return 'Stock cannot be negative';
    }
    
    return null;
  }
}
