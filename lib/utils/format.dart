DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String weekdayShort(DateTime d) => _weekdays[d.weekday - 1];

/// 12500 -> "12,500"
String formatNumber(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}

/// 12500 -> "12.5k", 800 -> "800"
String compactNumber(int n) {
  if (n < 1000) return n.toString();
  final s = (n / 1000).toStringAsFixed(1);
  return s.endsWith('.0') ? '${s.substring(0, s.length - 2)}k' : '${s}k';
}

/// "Mon, 16 Nov 2026"
String fullDate(DateTime d) =>
    '${weekdayShort(d)}, ${d.day} ${_months[d.month - 1]} ${d.year}';

/// "Today", "Yesterday" or "Sat, 14 Nov"
String friendlyDate(DateTime d) {
  final today = dateOnly(DateTime.now());
  if (isSameDay(d, today)) return 'Today';
  if (isSameDay(d, DateTime(today.year, today.month, today.day - 1))) {
    return 'Yesterday';
  }
  return '${weekdayShort(d)}, ${d.day} ${_months[d.month - 1]}';
}
