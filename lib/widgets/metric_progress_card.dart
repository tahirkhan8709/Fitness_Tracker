import 'package:material_ui/material_ui.dart';

import '../models/metric.dart';
import '../utils/format.dart';
import 'app_card.dart';
import 'fitness_theme.dart';

/// Compact stat card showing an icon in a tinted rounded square,
/// big tabular number, unit, and a tiny animated progress bar.
class MetricProgressCard extends StatelessWidget {
  const MetricProgressCard({
    super.key,
    required this.metric,
    required this.value,
    required this.goal,
    this.onTap,
  });

  final Metric metric;
  final int value;
  final int goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metricColor = getMetricColor(metric);
    final progress =
        goal > 0 ? (value / goal).clamp(0.0, 1.0).toDouble() : 0.0;
    final icon = getPhosphorIconForMetric(metric, filled: true);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: metricColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, size: 16, color: metricColor),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    metric.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              formatNumber(value),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
                fontFeatures: tabularFontFeatures,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'of ${formatNumber(goal)} ${metric.unit}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.textMuted,
              fontFeatures: tabularFontFeatures,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Tiny sleek progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 4,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 4,
                  color: metricColor,
                  backgroundColor: metricColor.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
