import '../config/app_config.dart';

class ExpiryService {
  /// Returns true if the app has passed its expiry date
  static bool isExpired() {
    if (!AppConfig.enableExpiry) return false;
    return DateTime.now().isAfter(AppConfig.expiryDate);
  }

  /// Days remaining until expiry (negative = already expired)
  static int daysRemaining() {
    final diff = AppConfig.expiryDate.difference(DateTime.now());
    return diff.inDays;
  }

  /// Expiry date formatted as readable string
  static String expiryDateFormatted() {
    final d = AppConfig.expiryDate;
    return '${d.day}/${d.month}/${d.year}';
  }
}
