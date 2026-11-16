import 'package:material_ui/material_ui.dart';

/// The three things the dashboard tracks.
enum Metric {
  steps('Steps', 'steps', Icons.directions_walk_rounded, Color(0xFF14B8A6)),
  calories(
    'Calories',
    'kcal',
    Icons.local_fire_department_rounded,
    Color(0xFFF97316),
  ),
  minutes('Active time', 'min', Icons.timer_rounded, Color(0xFF6366F1));

  const Metric(this.label, this.unit, this.icon, this.color);

  final String label;
  final String unit;
  final IconData icon;
  final Color color;
}
