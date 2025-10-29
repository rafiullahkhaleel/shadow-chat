import 'package:intl/intl.dart';

class DateTimeHelper{
  static String formatTime(DateTime? timestamp) {
    if (timestamp == null) {
      return '';
    }
    try {
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inDays == 0) {
        // Today - show time only
        return DateFormat('hh:mm a').format(timestamp);
      } else if (difference.inDays == 1) {
        // Yesterday
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        // Within a week - show day name
        return DateFormat('EEEE').format(timestamp);
      } else {
        // Older - show date
        return DateFormat('dd/MM/yyyy').format(timestamp);
      }
    } catch (e) {
      return '';
    }
  }
}