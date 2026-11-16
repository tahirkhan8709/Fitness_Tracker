import 'metric.dart';

/// Everything logged on a single day, added up.
class DayTotals {
  final DateTime date;
  final int steps;
  final int calories;
  final int minutes;

  const DayTotals({
    required this.date,
    required this.steps,
    required this.calories,
    required this.minutes,
  });

  int valueOf(Metric metric) => switch (metric) {
        Metric.steps => steps,
        Metric.calories => calories,
        Metric.minutes => minutes,
      };
}
