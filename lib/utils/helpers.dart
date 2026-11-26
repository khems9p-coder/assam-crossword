class Helpers {
  Helpers._();

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Example: "Thursday, 26 November 2026"
  static String formatLongDate(DateTime date) {
    return '${_weekdays[date.weekday - 1]}, ${date.day} '
        '${_months[date.month - 1]} ${date.year}';
  }

  /// Example: "Thu"
  static String shortWeekday(DateTime date) {
    return _weekdays[date.weekday - 1].substring(0, 3);
  }

  /// Example: 125 seconds -> "2:05". No time yet -> "—".
  static String formatDuration(int? seconds) {
    if (seconds == null) {
      return '—';
    }
    final int minutes = seconds ~/ 60;
    final int rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}
