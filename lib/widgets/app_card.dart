import 'package:material_ui/material_ui.dart';
import 'fitness_theme.dart';

/// A premium, layered card surface used across the app.
/// Features a subtle 1px border, soft shadow, and ripple interaction.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.borderRadius = 20,
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final surfaceColor = color ??
        (isDark ? FitnessColors.darkSurface1 : FitnessColors.lightSurface1);
    final border = borderColor ??
        (isDark ? FitnessColors.darkBorder : FitnessColors.lightBorder);

    Widget cardBody = Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          highlightColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (margin != null) {
      cardBody = Padding(padding: margin!, child: cardBody);
    }

    return cardBody;
  }
}
