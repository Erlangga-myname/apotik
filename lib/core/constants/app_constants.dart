/// App-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();
  
  // Firestore collection names
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String transactionsCollection = 'transactions';
  
  // Stock thresholds
  static const int lowStockThreshold = 10;
  static const int mediumStockThreshold = 50;
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxCategoryNameLength = 50;
  
  // Date formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String shortDateFormat = 'dd/MM/yyyy';
  
  // App info
  static const String appName = 'PharmaCare';
  static const String appVersion = '1.0.0';
}
