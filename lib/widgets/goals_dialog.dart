import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/fitness_store.dart';
import '../models/goals.dart';
import '../models/metric.dart';
import '../utils/format.dart';
import 'fitness_theme.dart';

/// Opens the modern Goals settings modal.
Future<void> showGoalsDialog(BuildContext context, FitnessStore store) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GoalsBottomSheet(store: store),
  );
}

class _GoalsBottomSheet extends StatefulWidget {
  const _GoalsBottomSheet({required this.store});

  final FitnessStore store;

  @override
  State<_GoalsBottomSheet> createState() => _GoalsBottomSheetState();
}

class _GoalsBottomSheetState extends State<_GoalsBottomSheet> {
  late int _steps;
  late int _calories;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _steps = widget.store.goals.steps;
    _calories = widget.store.goals.calories;
    _minutes = widget.store.goals.minutes;
  }

  Future<void> _save() async {
    await widget.store.setGoals(
      Goals(
        steps: _steps,
        calories: _calories,
        minutes: _minutes,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FitnessColors.darkSurface1 : FitnessColors.lightSurface1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? FitnessColors.darkBorder : FitnessColors.lightBorder,
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title row with close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: FitnessColors.steps.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            PhosphorIconsBold.target,
                            size: 18,
                            color: FitnessColors.steps,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Targets',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Customize your daily health goals',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      PhosphorIconsRegular.x,
                      size: 20,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Steps Goal Stepper & Slider
              _GoalCard(
                metric: Metric.steps,
                value: _steps,
                min: 1000,
                max: 30000,
                step: 500,
                color: FitnessColors.steps,
                onChanged: (val) => setState(() => _steps = val),
              ),
              const SizedBox(height: 14),

              // Calories Goal Stepper & Slider
              _GoalCard(
                metric: Metric.calories,
                value: _calories,
                min: 100,
                max: 2000,
                step: 50,
                color: FitnessColors.calories,
                onChanged: (val) => setState(() => _calories = val),
              ),
              const SizedBox(height: 14),

              // Active Minutes Goal Stepper & Slider
              _GoalCard(
                metric: Metric.minutes,
                value: _minutes,
                min: 10,
                max: 180,
                step: 5,
                color: FitnessColors.activeTime,
                onChanged: (val) => setState(() => _minutes = val),
              ),
              const SizedBox(height: 24),

              // Save Action Button
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: FitnessColors.steps,
                  foregroundColor: const Color(0xFF032617),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsBold.check, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Save Goals',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF032617),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.metric,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.color,
    required this.onChanged,
  });

  final Metric metric;
  final int value;
  final int min;
  final int max;
  final int step;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    final icon = getPhosphorIconForMetric(metric, filled: true);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? FitnessColors.darkSurface2 : FitnessColors.lightSurface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? FitnessColors.darkBorderSubtle : FitnessColors.lightBorderSubtle,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, size: 16, color: color),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  metric.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Value display with steppers
              _StepperButton(
                icon: PhosphorIconsBold.minus,
                onPressed: value > min ? () => onChanged(value - step) : null,
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 80),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: formatNumber(value),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                            fontFeatures: tabularFontFeatures,
                          ),
                        ),
                        TextSpan(
                          text: ' ${metric.unit}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StepperButton(
                icon: PhosphorIconsBold.plus,
                onPressed: value < max ? () => onChanged(value + step) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Clean custom slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayColor: color.withValues(alpha: 0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: (max - min) ~/ step,
              onChanged: (v) => onChanged((v / step).round() * step),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Material(
      color: isDark ? FitnessColors.darkSurface3 : FitnessColors.lightSurface3,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: Icon(
              icon,
              size: 13,
              color: onPressed != null ? context.textPrimary : context.textMuted.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
