import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/fitness_store.dart';
import '../models/activity.dart';
import '../utils/format.dart';
import '../widgets/activity_tile.dart';
import '../widgets/fitness_theme.dart';
import 'activity_form_screen.dart';

/// Grouped day data containing the date, total metrics for the day,
/// and the list of activities on that day.
class _DayGroup {
  _DayGroup({required this.date, required this.activities});

  final DateTime date;
  final List<Activity> activities;

  int get totalSteps => activities.fold(0, (sum, a) => sum + a.steps);
  int get totalCalories => activities.fold(0, (sum, a) => sum + a.calories);
  int get totalMinutes => activities.fold(0, (sum, a) => sum + a.durationMinutes);

  String get summary {
    final parts = <String>[
      if (totalSteps > 0) '${formatNumber(totalSteps)} steps',
      if (totalCalories > 0) '${formatNumber(totalCalories)} kcal',
      if (totalMinutes > 0 && totalSteps == 0 && totalCalories == 0)
        '$totalMinutes min',
    ];
    return parts.join(' · ');
  }
}

/// History screen showing activities grouped by day with daily totals on the
/// header, swipe-to-delete, confirmation dialog, and a custom vector-drawn empty state.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.store});

  final FitnessStore store;

  Future<bool> _confirmDelete(BuildContext context, Activity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dlgTheme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: ctx.isDarkMode
              ? FitnessColors.darkSurface1
              : FitnessColors.lightSurface1,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FitnessColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    PhosphorIconsBold.trashSimple,
                    size: 18,
                    color: FitnessColors.error,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete this activity?',
                  style: dlgTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ctx.isDarkMode
                  ? FitnessColors.darkSurface2
                  : FitnessColors.lightSurface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ctx.borderColor),
            ),
            child: Text(
              '${activity.type.label} · ${fullDate(activity.date)} · ${activity.summary}',
              style: dlgTheme.textTheme.bodySmall?.copyWith(
                color: ctx.textSecondary,
                fontFeatures: tabularFontFeatures,
                height: 1.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: ctx.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            FilledButton.icon(
              icon: const Icon(PhosphorIconsBold.trashSimple, size: 15),
              label: const Text('Delete'),
              style: FilledButton.styleFrom(
                backgroundColor: FitnessColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: dlgTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final activities = store.activities;

        if (activities.isEmpty) {
          return _EmptyHistoryView(
            onLogFirst: () => openActivityForm(context, store),
          );
        }

        // Group activities by date
        final dayGroups = <_DayGroup>[];
        DateTime? currentDay;
        List<Activity> currentList = [];

        for (final a in activities) {
          final aDate = dateOnly(a.date);
          if (currentDay == null || !isSameDay(currentDay, aDate)) {
            if (currentDay != null) {
              dayGroups.add(_DayGroup(date: currentDay, activities: currentList));
            }
            currentDay = aDate;
            currentList = [a];
          } else {
            currentList.add(a);
          }
        }
        if (currentDay != null) {
          dayGroups.add(_DayGroup(date: currentDay, activities: currentList));
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 16,
            16,
            120, // Extra bottom padding to clear floating nav bar
          ),
          itemCount: dayGroups.length + 1, // Header row + groups
          itemBuilder: (context, groupIndex) {
            if (groupIndex == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOGGED SESSIONS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                              color: context.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Activity History',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FitnessColors.steps.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activities.length} total',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: FitnessColors.steps,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final group = dayGroups[groupIndex - 1];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day header with daily total summary on the line
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        friendlyDate(group.date),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (group.summary.isNotEmpty)
                        Flexible(
                          child: Text(
                            group.summary,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: context.textMuted,
                              fontWeight: FontWeight.w600,
                              fontFeatures: tabularFontFeatures,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),

                // Activities in this day group with swipe-to-delete
                for (final activity in group.activities)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: ValueKey(activity.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(context, activity),
                      onDismissed: (_) => store.delete(activity.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: FitnessColors.error.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIconsBold.trashSimple,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: ActivityTile(
                        activity: activity,
                        onTap: () => openActivityForm(
                          context,
                          store,
                          existing: activity,
                        ),
                        onDelete: () async {
                          final confirmed = await _confirmDelete(context, activity);
                          if (confirmed) {
                            await store.delete(activity.id);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// A clean, minimalist vector-drawn empty state view (no emoji, no clip-art).
class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView({required this.onLogFirst});

  final VoidCallback onLogFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom-drawn geometric athletic vector icon
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _GeometricVectorEmptyPainter(
                  accentColor: FitnessColors.steps,
                  lineColor: isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No activities recorded yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                'Your recorded workouts, daily walks, and exercise sessions will appear here chronologically.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.textMuted,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onLogFirst,
              icon: const Icon(PhosphorIconsBold.plus, size: 18),
              label: const Text('Log First Activity'),
              style: FilledButton.styleFrom(
                backgroundColor: FitnessColors.steps,
                foregroundColor: const Color(0xFF032617),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom vector painter drawing clean geometric concentric dials and activity arcs.
class _GeometricVectorEmptyPainter extends CustomPainter {
  const _GeometricVectorEmptyPainter({
    required this.accentColor,
    required this.lineColor,
  });

  final Color accentColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Subtle dashed outer dial
    final dialPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, 48, dialPaint);

    // Dynamic athletic accent arcs
    final arcPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final rect1 = Rect.fromCircle(center: center, radius: 48);
    canvas.drawArc(rect1, -math.pi / 3, math.pi / 2, false, arcPaint);

    final innerPaint = Paint()
      ..color = FitnessColors.activeTime.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final rect2 = Rect.fromCircle(center: center, radius: 34);
    canvas.drawArc(rect2, math.pi / 4, (3 * math.pi) / 4, false, innerPaint);

    final innermostPaint = Paint()
      ..color = FitnessColors.calories.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect3 = Rect.fromCircle(center: center, radius: 20);
    canvas.drawArc(rect3, math.pi, math.pi / 2, false, innermostPaint);

    // Center focal point
    final pointPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, pointPaint);
  }

  @override
  bool shouldRepaint(covariant _GeometricVectorEmptyPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor ||
      oldDelegate.lineColor != lineColor;
}
