import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/activity.dart';
import '../utils/format.dart';
import 'app_card.dart';
import 'fitness_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers (UI only — format.dart is never touched)
// ─────────────────────────────────────────────────────────────────────────────

Color _getActivityColor(ActivityType type) {
  switch (type) {
    case ActivityType.walking:
      return FitnessColors.steps;
    case ActivityType.running:
      return const Color(0xFF10B981);
    case ActivityType.cycling:
      return FitnessColors.activeTime;
    case ActivityType.workout:
      return FitnessColors.calories;
    case ActivityType.yoga:
      return const Color(0xFF8B5CF6);
    case ActivityType.swimming:
      return const Color(0xFF06B6D4);
    case ActivityType.other:
      return const Color(0xFFF59E0B);
  }
}

/// Converts minutes to a friendly string without touching format.dart.
/// 90 → "1h 30m" · 45 → "45 min" · 60 → "1h" · 0 → ""
String _formatDuration(int minutes) {
  if (minutes <= 0) return '';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric chip
// ─────────────────────────────────────────────────────────────────────────────

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? FitnessColors.darkSurface2
            : FitnessColors.lightSurface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? FitnessColors.darkBorderSubtle
              : FitnessColors.lightBorderSubtle,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
              fontFeatures: tabularFontFeatures,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity tile
// ─────────────────────────────────────────────────────────────────────────────

/// A polished tile representing one logged activity.
///
/// Shows:
///   • Color-coded icon in a rounded square (left)
///   • Activity type label
///   • Metric chips in a Wrap (steps / duration / calories)
///   • Optional note with notepad icon (1 line, ellipsis)
///   • Trailing delete button for desktop/mouse users (44×44, tooltip)
///
/// Swipe-to-delete is handled by the parent [Dismissible]; this widget
/// only shows the fallback trailing button when [onDelete] is provided.
class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.activity,
    this.onTap,
    this.onDelete,
  });

  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activityColor = _getActivityColor(activity.type);
    final icon = getPhosphorIconForActivity(activity.type, filled: true);

    // Build metric chips — only for values > 0
    final chips = <Widget>[];
    if (activity.steps > 0) {
      chips.add(_MetricChip(
        icon: PhosphorIconsFill.sneakerMove,
        label: formatNumber(activity.steps),
        color: FitnessColors.steps,
      ));
    }
    if (activity.durationMinutes > 0) {
      chips.add(_MetricChip(
        icon: PhosphorIconsFill.timer,
        label: _formatDuration(activity.durationMinutes),
        color: FitnessColors.activeTime,
      ));
    }
    if (activity.calories > 0) {
      chips.add(_MetricChip(
        icon: PhosphorIconsFill.fire,
        label: '${formatNumber(activity.calories)} kcal',
        color: FitnessColors.calories,
      ));
    }

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Activity icon ────────────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: activityColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(icon, size: 22, color: activityColor),
            ),
          ),
          const SizedBox(width: 12),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity type name
                Text(
                  activity.type.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                // Metric chips
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: chips,
                  ),
                ],
                // Note
                if (activity.note.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.notepad,
                        size: 12,
                        color: context.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: context.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Trailing: delete button (desktop fallback) or caret ──────────
          if (onDelete != null) ...[
            const SizedBox(width: 6),
            Tooltip(
              message: 'Delete',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: FitnessColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        PhosphorIconsRegular.trashSimple,
                        size: 18,
                        color: FitnessColors.error.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(width: 4),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 16,
              color: context.textMuted.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );
  }
}
