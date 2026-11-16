import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/fitness_store.dart';
import '../models/metric.dart';
import '../utils/format.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_card.dart';
import '../widgets/concentric_rings_hero.dart';
import '../widgets/fitness_theme.dart';
import '../widgets/goals_dialog.dart';
import '../widgets/metric_progress_card.dart';
import '../widgets/weekly_bar_chart.dart';
import 'activity_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.store});

  final FitnessStore store;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Metric _metric = Metric.steps;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final store = widget.store;
        final theme = Theme.of(context);
        final isDark = context.isDarkMode;

        final today = dateOnly(DateTime.now());
        final totals = store.totalsFor(today);
        final goals = store.goals;
        final week = store.lastDays(7);
        final todaysActivities = store.activitiesOn(today);

        return ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 16,
            16,
            120, // Extra bottom padding for floating navigation bar
          ),
          children: [
            // Top App Bar Header with Greeting, Date and Goals Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullDate(today).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: context.textMuted,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getGreeting(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? FitnessColors.darkSurface2
                        : FitnessColors.lightSurface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? FitnessColors.darkBorderSubtle
                          : FitnessColors.lightBorderSubtle,
                    ),
                  ),
                  child: IconButton(
                    tooltip: 'Daily goals',
                    icon: Icon(
                      PhosphorIconsRegular.slidersHorizontal,
                      size: 20,
                      color: context.textPrimary,
                    ),
                    onPressed: () => showGoalsDialog(context, store),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hero: Apple-Fitness-style Concentric Animated Rings
            ConcentricRingsHero(
              steps: totals.steps,
              calories: totals.calories,
              minutes: totals.minutes,
              goals: goals,
              onTapGoals: () => showGoalsDialog(context, store),
            ),
            const SizedBox(height: 14),

            // Three Compact Stat Cards (Steps, Calories, Active Time)
            Row(
              children: [
                Expanded(
                  child: MetricProgressCard(
                    metric: Metric.steps,
                    value: totals.steps,
                    goal: goals.steps,
                    onTap: () => setState(() => _metric = Metric.steps),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricProgressCard(
                    metric: Metric.calories,
                    value: totals.calories,
                    goal: goals.calories,
                    onTap: () => setState(() => _metric = Metric.calories),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricProgressCard(
                    metric: Metric.minutes,
                    value: totals.minutes,
                    goal: goals.minutes,
                    onTap: () => setState(() => _metric = Metric.minutes),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 7-Day Performance Chart with Segmented Switch
            WeeklyBarChart(
              days: week,
              metric: _metric,
              goal: goals.goalFor(_metric),
              onMetricChanged: (m) => setState(() => _metric = m),
            ),
            const SizedBox(height: 24),

            // Today's Activities Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Today's Activities",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (todaysActivities.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FitnessColors.steps.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${todaysActivities.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: FitnessColors.steps,
                              fontWeight: FontWeight.w700,
                              fontFeatures: tabularFontFeatures,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => openActivityForm(context, store),
                  icon: const Icon(PhosphorIconsBold.plus, size: 14),
                  label: const Text('Log'),
                  style: TextButton.styleFrom(
                    foregroundColor: FitnessColors.steps,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (todaysActivities.isEmpty)
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: FitnessColors.steps.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          PhosphorIconsRegular.sneakerMove,
                          size: 18,
                          color: FitnessColors.steps,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No activities logged today',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap "+ Log" or the center button to record a workout.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final activity in todaysActivities)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ActivityTile(
                    activity: activity,
                    onTap: () => openActivityForm(
                      context,
                      store,
                      existing: activity,
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
