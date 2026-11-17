import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/day_totals.dart';
import '../models/metric.dart';
import '../utils/format.dart';
import 'app_card.dart';
import 'fitness_theme.dart';

/// Custom Segmented Pill Switch for Steps / Calories / Active Time.
class FitnessMetricSwitch extends StatelessWidget {
  const FitnessMetricSwitch({
    super.key,
    required this.selectedMetric,
    required this.onChanged,
  });

  final Metric selectedMetric;
  final ValueChanged<Metric> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final backgroundColor =
        isDark ? FitnessColors.darkSurface2 : FitnessColors.lightSurface2;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? FitnessColors.darkBorderSubtle
              : FitnessColors.lightBorderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          for (final metric in Metric.values)
            Expanded(
              child: _MetricTabItem(
                metric: metric,
                isSelected: selectedMetric == metric,
                onTap: () => onChanged(metric),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricTabItem extends StatelessWidget {
  const _MetricTabItem({
    required this.metric,
    required this.isSelected,
    required this.onTap,
  });

  final Metric metric;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    final metricColor = getMetricColor(metric);
    final icon = getPhosphorIconForMetric(metric, filled: isSelected);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? metricColor.withValues(alpha: isDark ? 0.15 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? metricColor.withValues(alpha: isDark ? 0.5 : 0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? metricColor : context.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  metric == Metric.minutes ? 'Time' : metric.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? context.textPrimary : context.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 7-Day interactive bar chart with dashed goal line, today highlight,
/// custom segmented switch, bar selection, and clean empty state.
class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({
    super.key,
    required this.days,
    required this.metric,
    required this.goal,
    this.onMetricChanged,
  });

  final List<DayTotals> days;
  final Metric metric;
  final int goal;
  final ValueChanged<Metric>? onMetricChanged;

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Default select today (the last day in the 7-day list)
    if (widget.days.isNotEmpty) {
      _selectedIndex = widget.days.length - 1;
    }
  }

  @override
  void didUpdateWidget(covariant WeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metric != widget.metric && widget.days.isNotEmpty) {
      _selectedIndex = widget.days.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metricColor = getMetricColor(widget.metric);
    final values = widget.days.map((d) => d.valueOf(widget.metric)).toList();
    final maxValue = values.fold<int>(widget.goal, (a, b) => a > b ? a : b);
    final top = maxValue <= 0 ? 1 : (maxValue * 1.15).round();
    final today = dateOnly(DateTime.now());

    final isAllZero = values.every((v) => v == 0);
    final total = values.fold<int>(0, (a, b) => a + b);
    final average = values.isEmpty ? 0 : (total / values.length).round();
    final bestDay = values.fold<int>(0, (a, b) => a > b ? a : b);

    final selectedDay = (_selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < widget.days.length)
        ? widget.days[_selectedIndex!]
        : (widget.days.isNotEmpty ? widget.days.last : null);
    final selectedValue = selectedDay?.valueOf(widget.metric) ?? 0;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and selected bar tooltip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Weekly Performance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (selectedDay != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: metricColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weekdayShort(selectedDay.date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: metricColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${formatNumber(selectedValue)} ${widget.metric.unit}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: metricColor,
                          fontWeight: FontWeight.w700,
                          fontFeatures: tabularFontFeatures,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Segmented Switch (if callback provided)
          if (widget.onMetricChanged != null) ...[
            FitnessMetricSwitch(
              selectedMetric: widget.metric,
              onChanged: widget.onMetricChanged!,
            ),
            const SizedBox(height: 20),
          ],

          // Chart Body or Empty State
          if (isAllZero)
            _buildEmptyState(context, metricColor)
          else
            _buildChartArea(context, values, top, today, metricColor),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 3 Bottom Stats: Total, Daily Average, Best Day
          Row(
            children: [
              _StatItem(
                label: 'Week Total',
                value: formatNumber(total),
                unit: widget.metric.unit,
                icon: PhosphorIconsRegular.chartLineUp,
              ),
              _StatItem(
                label: 'Daily Average',
                value: formatNumber(average),
                unit: widget.metric.unit,
                icon: PhosphorIconsRegular.trendUp,
              ),
              _StatItem(
                label: 'Best Day',
                value: formatNumber(bestDay),
                unit: widget.metric.unit,
                icon: PhosphorIconsRegular.trophy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color metricColor) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 170,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: metricColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  PhosphorIconsRegular.chartBar,
                  size: 24,
                  color: metricColor.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No activity logged yet this week',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Log an activity to track your progress against daily goals',
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartArea(
    BuildContext context,
    List<int> values,
    int top,
    DateTime today,
    Color metricColor,
  ) {
    const chartHeight = 140.0;
    final goalRatio =
        widget.goal > 0 ? (widget.goal / top).clamp(0.0, 1.0) : 0.0;
    final goalY = chartHeight * (1.0 - goalRatio);

    return SizedBox(
      height: chartHeight + 36, // Bars + day labels
      child: Stack(
        children: [
          // Dashed Goal Line
          if (widget.goal > 0)
            Positioned(
              left: 0,
              right: 0,
              top: goalY,
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _DashedLinePainter(
                        color: metricColor.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: metricColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Goal: ${compactNumber(widget.goal)}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: metricColor,
                        fontFeatures: tabularFontFeatures,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Bars Row
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < widget.days.length; i++)
                  Expanded(
                    child: _BarItem(
                      day: widget.days[i].date,
                      value: values[i],
                      top: top,
                      goal: widget.goal,
                      color: metricColor,
                      isToday: isSameDay(widget.days[i].date, today),
                      isSelected: _selectedIndex == i,
                      onTap: () => setState(() => _selectedIndex = i),
                      chartHeight: chartHeight,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.day,
    required this.value,
    required this.top,
    required this.goal,
    required this.color,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
    required this.chartHeight,
  });

  final DateTime day;
  final int value;
  final int top;
  final int goal;
  final Color color;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;
  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = top > 0 ? (value / top).clamp(0.0, 1.0) : 0.0;
    var barHeight = chartHeight * ratio;
    if (value > 0 && barHeight < 6) barHeight = 6;

    final reachedGoal = goal > 0 && value >= goal;
    Color barColor;
    if (isSelected || isToday) {
      barColor = color;
    } else if (reachedGoal) {
      barColor = color.withValues(alpha: 0.75);
    } else {
      barColor = color.withValues(alpha: 0.28);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bar Container
          SizedBox(
            height: chartHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Ghost track background
                Container(
                  width: 18,
                  height: chartHeight,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                // Animated Bar
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: barHeight),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, h, _) => Container(
                    width: 18,
                    height: h,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Day Label with Today indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekdayShort(day),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: (isToday || isSelected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isToday
                      ? color
                      : (isSelected ? context.textPrimary : context.textMuted),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isToday
                      ? color
                      : (isSelected ? context.textSecondary : Colors.transparent),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: context.textMuted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.textMuted,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: tabularFontFeatures,
            ),
          ),
          Text(
            unit,
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
