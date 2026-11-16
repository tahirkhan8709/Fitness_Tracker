import 'package:material_ui/material_ui.dart';

import '../utils/format.dart';

enum ActivityType {
  walking('Walking', Icons.directions_walk_rounded),
  running('Running', Icons.directions_run_rounded),
  cycling('Cycling', Icons.directions_bike_rounded),
  workout('Workout', Icons.fitness_center_rounded),
  yoga('Yoga', Icons.self_improvement_rounded),
  swimming('Swimming', Icons.pool_rounded),
  other('Other', Icons.bolt_rounded);

  const ActivityType(this.label, this.icon);

  final String label;
  final IconData icon;
}

class Activity {
  final String id;
  final ActivityType type;
  final DateTime date; // date only (no time)
  final int steps;
  final int durationMinutes;
  final int calories;
  final String note;

  const Activity({
    required this.id,
    required this.type,
    required this.date,
    this.steps = 0,
    this.durationMinutes = 0,
    this.calories = 0,
    this.note = '',
  });

  /// e.g. "5,000 steps · 40 min · 320 kcal"
  String get summary {
    final parts = <String>[
      if (steps > 0) '${formatNumber(steps)} steps',
      if (durationMinutes > 0) '$durationMinutes min',
      if (calories > 0) '${formatNumber(calories)} kcal',
    ];
    return parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'date': date.toIso8601String(),
        'steps': steps,
        'durationMinutes': durationMinutes,
        'calories': calories,
        'note': note,
      };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ActivityType.other,
      ),
      date: dateOnly(DateTime.parse(json['date'] as String)),
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      note: (json['note'] as String?) ?? '',
    );
  }
}
