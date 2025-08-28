import 'package:intl/intl.dart';

class DateUtilsForThirtyDays {
  /// Gets the current date
  static DateTime get now => DateTime.now();

  /// Formats a date into day and date components
  static Map<String, String> formatDayMonth(DateTime date) {
    return {
      'day': DateFormat('EEE').format(date), // e.g. "Mon"
      'date': DateFormat('d').format(date), // e.g. "28"
    };
  }

  /// Gets the next [daysCount] days starting from [startDate]
  /// If [startDate] is not provided, uses current date
  static List<DateTime> getNextDays({int daysCount = 30, DateTime? startDate}) {
    final start = startDate ?? now;
    return List.generate(
      daysCount,
      (index) => start.add(Duration(days: index)),
    );
  }

  /// Gets formatted next days as strings (e.g., ['Mon 28', 'Tue 29', ...])
  static List<Map<String, String>> getFormattedNextDays({
    int daysCount = 30,
    DateTime? startDate,
  }) {
    return getNextDays(
      daysCount: daysCount,
      startDate: startDate,
    ).map(formatDayMonth).toList();
  }

  /// Converts a day index (0 = today, 1 = tomorrow, etc.) into a UTC ISO 8601 string
  static String getUtcDateStringFromIndex(int index) {
    final today = DateTime.now();
    final target = today.add(Duration(days: index));
    // Set time to 08:00:00 in local time
    final dateWithTime = DateTime(
      target.year,
      target.month,
      target.day,
      8,
      0,
      0,
    );
    // Format as 'yyyy-MM-ddTHH:mm:ss'
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateWithTime);
  }

  /// Checks if two dates are the same day (ignores time)
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Formats time as 'h:mma' (e.g., '8:30am')
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time).toLowerCase();
  }

  /// Formats time range (e.g., '8:30am - 9:15am')
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }
}
