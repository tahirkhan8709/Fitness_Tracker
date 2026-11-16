import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/activity.dart';
import '../models/metric.dart';

/// Design tokens and palette for the Fitness Tracker app.
class FitnessColors {
  FitnessColors._();

  // Metrics (Athletic, high-contrast, strictly restrained)
  static const Color steps = Color(0xFF00E599); // Crisp activity green/teal
  static const Color calories = Color(0xFFFF6A00); // Athletic energetic orange
  static const Color activeTime = Color(0xFF00B2FF); // Vivid electric cyan-blue

  // Dark Theme Palette (Obsidian / Dark Charcoal)
  static const Color darkBackground = Color(0xFF0D1017);
  static const Color darkSurface1 = Color(0xFF151A24); // Primary card
  static const Color darkSurface2 = Color(0xFF1D2433); // Elevated / chips / inputs
  static const Color darkSurface3 = Color(0xFF263044); // Active / border hover
  static const Color darkBorder = Color(0x1FFFFFFF); // 12% white 1px border
  static const Color darkBorderSubtle = Color(0x0FFFFFFF); // 6% white border

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Theme Palette (Clean, polished slate)
  static const Color lightBackground = Color(0xFFF6F8FB);
  static const Color lightSurface1 = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFEEF2F6);
  static const Color lightSurface3 = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0x14000000); // 8% black border
  static const Color lightBorderSubtle = Color(0x0A000000); // 4% black border

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Status & Accents
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0x26EF4444);
}

/// Helper methods for color and theme retrieval.
extension FitnessThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? FitnessColors.darkBackground : FitnessColors.lightBackground;

  Color get cardColor =>
      isDarkMode ? FitnessColors.darkSurface1 : FitnessColors.lightSurface1;

  Color get elevatedColor =>
      isDarkMode ? FitnessColors.darkSurface2 : FitnessColors.lightSurface2;

  Color get borderColor =>
      isDarkMode ? FitnessColors.darkBorder : FitnessColors.lightBorder;

  Color get textPrimary =>
      isDarkMode ? FitnessColors.darkTextPrimary : FitnessColors.lightTextPrimary;

  Color get textSecondary =>
      isDarkMode ? FitnessColors.darkTextSecondary : FitnessColors.lightTextSecondary;

  Color get textMuted =>
      isDarkMode ? FitnessColors.darkTextMuted : FitnessColors.lightTextMuted;
}

/// Helper for metric color mapping.
Color getMetricColor(Metric metric) {
  switch (metric) {
    case Metric.steps:
      return FitnessColors.steps;
    case Metric.calories:
      return FitnessColors.calories;
    case Metric.minutes:
      return FitnessColors.activeTime;
  }
}

/// Phosphor icon provider for Activity types (Strictly NO Icons.*).
IconData getPhosphorIconForActivity(ActivityType type, {bool filled = false}) {
  switch (type) {
    case ActivityType.walking:
      return filled
          ? PhosphorIconsFill.personSimpleWalk
          : PhosphorIconsRegular.personSimpleWalk;
    case ActivityType.running:
      return filled
          ? PhosphorIconsFill.personSimpleRun
          : PhosphorIconsRegular.personSimpleRun;
    case ActivityType.cycling:
      return filled
          ? PhosphorIconsFill.bicycle
          : PhosphorIconsRegular.bicycle;
    case ActivityType.workout:
      return filled
          ? PhosphorIconsFill.barbell
          : PhosphorIconsRegular.barbell;
    case ActivityType.yoga:
      return filled
          ? PhosphorIconsFill.flowerLotus
          : PhosphorIconsRegular.flowerLotus;
    case ActivityType.swimming:
      return filled
          ? PhosphorIconsFill.personSimpleSwim
          : PhosphorIconsRegular.personSimpleSwim;
    case ActivityType.other:
      return filled
          ? PhosphorIconsFill.lightning
          : PhosphorIconsRegular.lightning;
  }
}

/// Phosphor icon provider for Metrics (Strictly NO Icons.*).
IconData getPhosphorIconForMetric(Metric metric, {bool filled = false}) {
  switch (metric) {
    case Metric.steps:
      return filled
          ? PhosphorIconsFill.sneakerMove
          : PhosphorIconsRegular.sneakerMove;
    case Metric.calories:
      return filled
          ? PhosphorIconsFill.fire
          : PhosphorIconsRegular.fire;
    case Metric.minutes:
      return filled
          ? PhosphorIconsFill.timer
          : PhosphorIconsRegular.timer;
  }
}

/// Tabular and lining font features for precise numeric layouts.
const List<FontFeature> tabularFontFeatures = [
  FontFeature.tabularFigures(),
  FontFeature.liningFigures(),
];
