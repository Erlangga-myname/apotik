import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Date formatting utilities
class DateFormatter {
  // Private constructor to prevent instantiation
  DateFormatter._();
  
  /// Formats DateTime to default date format (dd MMM yyyy)
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }
  
  /// Formats DateTime to date and time format (dd MMM yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }
  
  /// Formats DateTime to short date format (dd/MM/yyyy)
  static String formatShortDate(DateTime date) {
    return DateFormat(AppConstants.shortDateFormat).format(date);
  }
  
  /// Formats DateTime to relative time (e.g., "2 days ago", "Just now")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Checks if a date is expired (past today)
  static bool isExpired(DateTime date) {
    final today = DateTime.now();
    return date.isBefore(DateTime(today.year, today.month, today.day));
  }
  
  /// Checks if a date is expiring soon (within 30 days)
  static bool isExpiringSoon(DateTime date) {
    final today = DateTime.now();
    final thirtyDaysFromNow = today.add(const Duration(days: 30));
    return date.isAfter(today) && date.isBefore(thirtyDaysFromNow);
  }
  
  /// Gets days until expiry
  static int daysUntilExpiry(DateTime expiryDate) {
    final today = DateTime.now();
    return expiryDate.difference(today).inDays;
  }
  
  /// Formats currency (Indonesian Rupiah)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  /// Formats number with thousand separators
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number);
  }
}
