import 'package:flutter/material.dart';

/// App-wide color palette with medical/pharmacy theme
class AppColors {
  // Primary colors - Teal/Cyan for medical/health association
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);
  
  // Secondary colors - Deep Orange for alerts/warnings
  static const Color secondary = Color(0xFFFF6F00);
  static const Color secondaryLight = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFE65100);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Stock status colors
  static const Color stockHigh = Color(0xFF4CAF50);
  static const Color stockMedium = Color(0xFFFFC107);
  static const Color stockLow = Color(0xFFFF5722);
  static const Color stockOut = Color(0xFFF44336);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
