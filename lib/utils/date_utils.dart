import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat.yMMMd().format(date); // Sep 10, 2025
    } catch (_) {
      return dateString; // fallback
    }
  }
}
