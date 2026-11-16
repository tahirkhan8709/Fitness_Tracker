import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/fitness_store.dart';
import '../widgets/fitness_theme.dart';
import 'activity_form_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';

/// Main screen with smooth tab navigation between Dashboard and History,
/// plus a custom floating pill bottom navigation bar with an integrated
/// "Add Activity" button.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});

  final FitnessStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          // Screen content with smooth animated transition
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _index == 0
                    ? DashboardScreen(
                        key: const ValueKey('dashboard'),
                        store: widget.store,
                      )
                    : HistoryScreen(
                        key: const ValueKey('history'),
                        store: widget.store,
                      ),
              ),
            ),
          ),

          // Custom Floating Bottom Navigation Pill
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom + 6
                        : 20,
                  ),
                  child: _FloatingNavBar(
                    currentIndex: _index,
                    onTabSelected: (i) => setState(() => _index = i),
                    onAddPressed: () => openActivityForm(context, widget.store),
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
    required this.isDark,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final navSurfaceColor = isDark
        ? FitnessColors.darkSurface1.withValues(alpha: 0.92)
        : FitnessColors.lightSurface1.withValues(alpha: 0.94);
    final borderColor =
        isDark ? FitnessColors.darkBorder : FitnessColors.lightBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: navSurfaceColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dashboard Tab
              Expanded(
                child: _NavBarTab(
                  icon: PhosphorIconsRegular.squaresFour,
                  selectedIcon: PhosphorIconsFill.squaresFour,
                  label: 'Dashboard',
                  isSelected: currentIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
              ),

              // Integrated Center Add Activity Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAddPressed,
                    borderRadius: BorderRadius.circular(26),
                    splashColor: Colors.black.withValues(alpha: 0.15),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: FitnessColors.steps,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: FitnessColors.steps.withValues(alpha: 0.38),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          PhosphorIconsBold.plus,
                          size: 22,
                          color: Color(0xFF032617),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // History Tab
              Expanded(
                child: _NavBarTab(
                  icon: PhosphorIconsRegular.clockCounterClockwise,
                  selectedIcon: PhosphorIconsFill.clockCounterClockwise,
                  label: 'History',
                  isSelected: currentIndex == 1,
                  onTap: () => onTabSelected(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarTab extends StatelessWidget {
  const _NavBarTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = FitnessColors.steps;
    final inactiveColor = context.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  key: ValueKey(isSelected),
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
