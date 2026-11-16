import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/fitness_store.dart';
import '../models/activity.dart';
import '../utils/format.dart';
import '../widgets/fitness_theme.dart';

/// Opens the add screen, or the edit screen when [existing] is given.
Future<void> openActivityForm(
  BuildContext context,
  FitnessStore store, {
  Activity? existing,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ActivityFormScreen(store: store, existing: existing),
    ),
  );
}

class ActivityFormScreen extends StatefulWidget {
  const ActivityFormScreen({super.key, required this.store, this.existing});

  final FitnessStore store;
  final Activity? existing;

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late ActivityType _type = widget.existing?.type ?? ActivityType.walking;
  late DateTime _date = widget.existing?.date ?? dateOnly(DateTime.now());

  late final TextEditingController _steps =
      TextEditingController(text: _initial(widget.existing?.steps));
  late final TextEditingController _minutes =
      TextEditingController(text: _initial(widget.existing?.durationMinutes));
  late final TextEditingController _calories =
      TextEditingController(text: _initial(widget.existing?.calories));
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');

  /// Activity types for which the Steps field is relevant.
  static const _stepTypes = {
    ActivityType.walking,
    ActivityType.running,
    ActivityType.other,
  };

  /// Whether the Steps field should be visible for the currently-selected type.
  bool get _showSteps => _stepTypes.contains(_type);

  bool get _isEdit => widget.existing != null;

  String _initial(int? value) =>
      (value == null || value == 0) ? '' : value.toString();

  int _parse(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  @override
  void dispose() {
    _steps.dispose();
    _minutes.dispose();
    _calories.dispose();
    _note.dispose();
    super.dispose();
  }

  String? Function(String?) _numberValidator(int max) {
    return (value) {
      final text = (value ?? '').trim();
      if (text.isEmpty) return null; // optional
      final n = int.tryParse(text);
      if (n == null) return 'Enter a valid number';
      if (n > max) return 'Maximum is $max';
      return null;
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: dateOnly(DateTime.now()),
    );
    if (picked != null) setState(() => _date = dateOnly(picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Only count steps in the "at least one > 0" check when the field is visible.
    final effectiveSteps = _showSteps ? _parse(_steps) : 0;
    final minutes = _parse(_minutes);
    final calories = _parse(_calories);

    if (effectiveSteps == 0 && minutes == 0 && calories == 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: FitnessColors.error,
            content: const Text(
              'Please enter at least steps, duration or calories.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      return;
    }

    final activity = Activity(
      id: widget.existing?.id ?? widget.store.newId(),
      type: _type,
      date: _date,
      steps: _showSteps ? _parse(_steps) : 0,
      durationMinutes: minutes,
      calories: calories,
      note: _note.text.trim(),
    );

    if (_isEdit) {
      await widget.store.update(activity);
    } else {
      await widget.store.add(activity);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.caretLeft, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEdit ? 'Edit Activity' : 'Log Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                // Section: Activity Type
                Text(
                  'ACTIVITY TYPE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 500 ? 4 : (constraints.maxWidth > 350 ? 4 : 3);
                    final width = (constraints.maxWidth - ((columns - 1) * 10)) / columns;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final type in ActivityType.values)
                          SizedBox(
                            width: width,
                            child: _ActivityTypeTile(
                              type: type,
                              isSelected: _type == type,
                              onTap: () => setState(() {
                                _type = type;
                                // Clear stale steps value when switching to a
                                // type that does not use steps.
                                if (!_stepTypes.contains(type)) {
                                  _steps.clear();
                                }
                              }),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Section: Date Selector
                Text(
                  'DATE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  color: isDark ? FitnessColors.darkSurface2 : FitnessColors.lightSurface2,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? FitnessColors.darkBorderSubtle : FitnessColors.lightBorderSubtle,
                        ),
                      ),
                      child: Row(
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
                                PhosphorIconsRegular.calendarBlank,
                                size: 16,
                                color: FitnessColors.steps,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friendlyDate(_date),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                Text(
                                  fullDate(_date),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: context.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            PhosphorIconsRegular.caretRight,
                            size: 16,
                            color: context.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Metrics
                Text(
                  'METRICS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                // Steps Field — only shown for Walking, Running, Other
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: _showSteps
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _FilledNumericField(
                              controller: _steps,
                              label: 'Steps',
                              unit: 'steps',
                              icon: PhosphorIconsRegular.sneakerMove,
                              accentColor: FitnessColors.steps,
                              max: 200000,
                              validator: _numberValidator(200000),
                            ),
                            const SizedBox(height: 12),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // Duration Field
                _FilledNumericField(
                  controller: _minutes,
                  label: 'Active Duration',
                  unit: 'min',
                  icon: PhosphorIconsRegular.timer,
                  accentColor: FitnessColors.activeTime,
                  max: 1440,
                  validator: _numberValidator(1440),
                ),
                const SizedBox(height: 12),

                // Calories Field
                _FilledNumericField(
                  controller: _calories,
                  label: 'Calories Burned',
                  unit: 'kcal',
                  icon: PhosphorIconsRegular.fire,
                  accentColor: FitnessColors.calories,
                  max: 20000,
                  validator: _numberValidator(20000),
                ),
                const SizedBox(height: 24),

                // Section: Notes
                Text(
                  'NOTES (OPTIONAL)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? FitnessColors.darkSurface2 : FitnessColors.lightSurface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? FitnessColors.darkBorderSubtle : FitnessColors.lightBorderSubtle,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextFormField(
                    controller: _note,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'How was your session? (e.g. Morning jog in park)',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: context.textMuted.withValues(alpha: 0.7),
                      ),
                      icon: Icon(
                        PhosphorIconsRegular.notepad,
                        size: 20,
                        color: context.textMuted,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Primary Save Button
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: FitnessColors.steps,
                    foregroundColor: const Color(0xFF032617),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(PhosphorIconsBold.check, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isEdit ? 'Save Changes' : 'Save Activity',
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
      ),
    );
  }
}

class _ActivityTypeTile extends StatelessWidget {
  const _ActivityTypeTile({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final ActivityType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    final icon = getPhosphorIconForActivity(type, filled: isSelected);
    final primary = FitnessColors.steps;

    return Material(
      color: isSelected
          ? primary.withValues(alpha: 0.15)
          : (isDark ? FitnessColors.darkSurface2 : FitnessColors.lightSurface2),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? primary
                  : (isDark ? FitnessColors.darkBorderSubtle : FitnessColors.lightBorderSubtle),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? primary : context.textMuted,
              ),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? context.textPrimary : context.textMuted,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledNumericField extends StatelessWidget {
  const _FilledNumericField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
    required this.accentColor,
    required this.max,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final int max;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FitnessColors.darkSurface2 : FitnessColors.lightSurface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? FitnessColors.darkBorderSubtle : FitnessColors.lightBorderSubtle,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 16, color: accentColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: validator,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
                fontFeatures: tabularFontFeatures,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: context.textMuted,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isDark ? FitnessColors.darkSurface3 : FitnessColors.lightSurface3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              unit,
              style: theme.textTheme.labelSmall?.copyWith(
                color: context.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
