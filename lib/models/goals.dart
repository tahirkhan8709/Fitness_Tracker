import 'metric.dart';

/// The user's daily targets.
class Goals {
  final int steps;
  final int calories;
  final int minutes;

  const Goals({this.steps = 10000, this.calories = 500, this.minutes = 45});

  int goalFor(Metric metric) => switch (metric) {
        Metric.steps => steps,
        Metric.calories => calories,
        Metric.minutes => minutes,
      };

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'calories': calories,
        'minutes': minutes,
      };

  factory Goals.fromJson(Map<String, dynamic> json) {
    return Goals(
      steps: (json['steps'] as num?)?.toInt() ?? 10000,
      calories: (json['calories'] as num?)?.toInt() ?? 500,
      minutes: (json['minutes'] as num?)?.toInt() ?? 45,
    );
  }
}
