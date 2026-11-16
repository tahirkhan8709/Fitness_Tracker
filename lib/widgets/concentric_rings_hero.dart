import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/goals.dart';
import '../models/metric.dart';
import '../utils/format.dart';
import 'app_card.dart';
import 'fitness_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

/// Apple-Fitness-style three concentric animated activity rings.
/// Steps (outer) · Calories (middle) · Active time (inner).
class ConcentricRingsHero extends StatefulWidget {
  const ConcentricRingsHero({
    super.key,
    required this.steps,
    required this.calories,
    required this.minutes,
    required this.goals,
    this.onTapGoals,
  });

  final int steps;
  final int calories;
  final int minutes;
  final Goals goals;
  final VoidCallback? onTapGoals;

  @override
  State<ConcentricRingsHero> createState() => _ConcentricRingsHeroState();
}

class _ConcentricRingsHeroState extends State<ConcentricRingsHero>
    with SingleTickerProviderStateMixin {
  /// Single controller drives all three rings with staggered intervals.
  late final AnimationController _controller;

  // Each ring gets its own interval so they stagger: outer → middle → inner.
  late final Animation<double> _outerAnim;
  late final Animation<double> _middleAnim;
  late final Animation<double> _innerAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050), // outer ends at 900 ms
    );
    _outerAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.86, curve: Curves.easeOutCubic),
    );
    _middleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 0.93, curve: Curves.easeOutCubic),
    );
    _innerAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.14, 1.00, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ConcentricRingsHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps ||
        oldWidget.calories != widget.calories ||
        oldWidget.minutes != widget.minutes ||
        oldWidget.goals != widget.goals) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── raw progress ratios (can exceed 1.0 when over goal) ──────────────────
  double get _stepsRaw =>
      widget.goals.steps > 0 ? widget.steps / widget.goals.steps : 0.0;
  double get _caloriesRaw =>
      widget.goals.calories > 0 ? widget.calories / widget.goals.calories : 0.0;
  double get _minutesRaw =>
      widget.goals.minutes > 0 ? widget.minutes / widget.goals.minutes : 0.0;

  // ── capped at 1.0 for visual drawing ─────────────────────────────────────
  double get _stepsCapped => _stepsRaw.clamp(0.0, 1.0);
  double get _caloriesCapped => _caloriesRaw.clamp(0.0, 1.0);
  double get _minutesCapped => _minutesRaw.clamp(0.0, 1.0);

  // ── displayed integer percentage, capped at 100 ──────────────────────────
  int get _stepsPercent => (_stepsCapped * 100).round();
  int get _caloriesPercent => (_caloriesCapped * 100).round();
  int get _minutesPercent => (_minutesCapped * 100).round();

  bool get _allMet =>
      _stepsRaw >= 1.0 && _caloriesRaw >= 1.0 && _minutesRaw >= 1.0;

  int get _overallPercent =>
      ((_stepsPercent + _caloriesPercent + _minutesPercent) / 3).round();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: FitnessColors.steps.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    PhosphorIconsBold.pulse,
                    size: 16,
                    color: FitnessColors.steps,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Daily Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.onTapGoals != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTapGoals,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsRegular.slidersHorizontal,
                            size: 14,
                            color: context.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Edit Goals',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: context.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Rings + Legend ───────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 440;

              final ringsWidget = Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: _ThreeConcentricRingsPainter(
                          // Visual progress is capped × animated value
                          stepsProgress: _stepsCapped * _outerAnim.value,
                          caloriesProgress:
                              _caloriesCapped * _middleAnim.value,
                          minutesProgress: _minutesCapped * _innerAnim.value,
                          isDark: context.isDarkMode,
                        ),
                        child: Center(
                          child: _RingCenter(
                            allMet: _allMet,
                            overallPercent: _overallPercent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );

              final legendWidget = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RingLegendRow(
                    color: FitnessColors.steps,
                    icon: PhosphorIconsFill.sneakerMove,
                    label: Metric.steps.label,
                    value: widget.steps,
                    goal: widget.goals.steps,
                    unit: Metric.steps.unit,
                    cappedPercent: _stepsPercent,
                    met: _stepsRaw >= 1.0,
                  ),
                  const SizedBox(height: 12),
                  _RingLegendRow(
                    color: FitnessColors.calories,
                    icon: PhosphorIconsFill.fire,
                    label: Metric.calories.label,
                    value: widget.calories,
                    goal: widget.goals.calories,
                    unit: Metric.calories.unit,
                    cappedPercent: _caloriesPercent,
                    met: _caloriesRaw >= 1.0,
                  ),
                  const SizedBox(height: 12),
                  _RingLegendRow(
                    color: FitnessColors.activeTime,
                    icon: PhosphorIconsFill.timer,
                    label: Metric.minutes.label,
                    value: widget.minutes,
                    goal: widget.goals.minutes,
                    unit: Metric.minutes.unit,
                    cappedPercent: _minutesPercent,
                    met: _minutesRaw >= 1.0,
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ringsWidget,
                    const SizedBox(width: 24),
                    Expanded(child: legendWidget),
                  ],
                );
              } else {
                return Column(
                  children: [
                    ringsWidget,
                    const SizedBox(height: 20),
                    legendWidget,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Center overlay widget
// ─────────────────────────────────────────────────────────────────────────────

class _RingCenter extends StatelessWidget {
  const _RingCenter({
    required this.allMet,
    required this.overallPercent,
  });

  final bool allMet;
  final int overallPercent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The innermost ring leaves ~(220 - 2*(14+6)*3)/2 ≈ 50px usable radius.
    // We constrain to 72px wide so text never overflows into ring area.
    return SizedBox(
      width: 72,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: allMet
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsFill.checkCircle,
                    size: 22,
                    color: FitnessColors.steps,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'All goals\nmet',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$overallPercent%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                      fontFeatures: tabularFontFeatures,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'of daily\ngoals',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: context.textMuted,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend row
// ─────────────────────────────────────────────────────────────────────────────

class _RingLegendRow extends StatelessWidget {
  const _RingLegendRow({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.cappedPercent,
    required this.met,
  });

  final Color color;
  final IconData icon;
  final String label;
  final int value;
  final int goal;
  final String unit;

  /// Already clamped to 0–100.
  final int cappedPercent;

  /// True when the real value >= goal.
  final bool met;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Colored dot / icon tile
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Icon(icon, size: 14, color: color)),
        ),
        const SizedBox(width: 10),

        // Label + value line
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Metric name
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Percentage — capped, with check icon when goal is met
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (met)
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(
                            PhosphorIconsFill.checkCircle,
                            size: 12,
                            color: color,
                          ),
                        ),
                      Text(
                        '$cappedPercent%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontFeatures: tabularFontFeatures,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Current / goal line with thousands separators
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: formatNumber(value),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          fontFeatures: tabularFontFeatures,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${formatNumber(goal)} $unit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.textMuted,
                          fontFeatures: tabularFontFeatures,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter
// ─────────────────────────────────────────────────────────────────────────────

/// Paints three perfectly concentric rings.
///
/// Design spec:
///   • strokeWidth ≈ 14 px (6.4% of size)
///   • gap between rings = 6 px (fixed visual gap, independent of stroke)
///   • track = metric color at 15% opacity, full circle
///   • arc  = solid metric color, rounded caps, starts at 12 o'clock,
///            sweeps clockwise, clamped to [0..2π]
///   • No gradients, no glow.
class _ThreeConcentricRingsPainter extends CustomPainter {
  const _ThreeConcentricRingsPainter({
    required this.stepsProgress,
    required this.caloriesProgress,
    required this.minutesProgress,
    required this.isDark,
  });

  final double stepsProgress;
  final double caloriesProgress;
  final double minutesProgress;
  final bool isDark;

  static const double _strokeWidth = 14.0;
  static const double _gap = 6.0; // pixel gap between ring edges

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // The outer ring's centre-line radius so it just fits inside the canvas.
    final outerRadius = (size.width / 2) - (_strokeWidth / 2);

    // Each subsequent ring is inset by stroke + gap so their edges never touch.
    final step = _strokeWidth + _gap;
    final middleRadius = outerRadius - step;
    final innerRadius = middleRadius - step;

    _drawRing(
      canvas: canvas,
      center: center,
      radius: outerRadius,
      progress: stepsProgress,
      color: FitnessColors.steps,
    );
    _drawRing(
      canvas: canvas,
      center: center,
      radius: middleRadius,
      progress: caloriesProgress,
      color: FitnessColors.calories,
    );
    _drawRing(
      canvas: canvas,
      center: center,
      radius: innerRadius,
      progress: minutesProgress,
      color: FitnessColors.activeTime,
    );
  }

  void _drawRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double progress,
    required Color color,
  }) {
    // ── Track (full circle behind the arc) ─────────────────────────────────
    final trackPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.15 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // ── Arc (progress, clamped to exactly one full revolution) ─────────────
    if (progress <= 0) return;

    final sweepAngle = (progress * 2 * math.pi).clamp(0.0, 2 * math.pi);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2, // start at 12 o'clock
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ThreeConcentricRingsPainter old) =>
      old.stepsProgress != stepsProgress ||
      old.caloriesProgress != caloriesProgress ||
      old.minutesProgress != minutesProgress ||
      old.isDark != isDark;
}
