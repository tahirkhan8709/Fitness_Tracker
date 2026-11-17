import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fitnesstracker/models/day_totals.dart';
import 'package:fitnesstracker/models/metric.dart';
import 'package:fitnesstracker/widgets/weekly_bar_chart.dart';

void main() {
  final sampleDays = List.generate(
    7,
    (i) => DayTotals(
      date: DateTime.now().subtract(Duration(days: 6 - i)),
      steps: 4000 + i * 500,
      calories: 200 + i * 50,
      minutes: 30 + i * 5,
    ),
  );

  Widget buildChartTestWidget({
    required Metric metric,
    required ValueChanged<Metric> onMetricChanged,
    required bool isDark,
    Size size = const Size(360, 640),
  }) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        theme: isDark ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: size.width,
              child: WeeklyBarChart(
                days: sampleDays,
                metric: metric,
                goal: 10000,
                onMetricChanged: onMetricChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('FitnessMetricSwitch switches between Steps, Calories, Time in dark mode', (tester) async {
    Metric current = Metric.steps;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildChartTestWidget(
            metric: current,
            onMetricChanged: (m) => setState(() => current = m),
            isDark: true,
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Verify all 3 tabs are displayed
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);

    // Initial state: Steps selected
    expect(current, Metric.steps);

    // Tap Calories
    await tester.tap(find.text('Calories'));
    await tester.pumpAndSettle();
    expect(current, Metric.calories);

    // Tap Time
    await tester.tap(find.text('Time'));
    await tester.pumpAndSettle();
    expect(current, Metric.minutes);

    // Tap Steps
    await tester.tap(find.text('Steps'));
    await tester.pumpAndSettle();
    expect(current, Metric.steps);

    // No exceptions or overflows
    expect(tester.takeException(), isNull);
  });

  testWidgets('FitnessMetricSwitch switches between tabs in light mode without overflow at 360px', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    Metric current = Metric.steps;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildChartTestWidget(
            metric: current,
            onMetricChanged: (m) => setState(() => current = m),
            isDark: false,
            size: const Size(360, 640),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap Calories on 360px screen
    await tester.tap(find.text('Calories'));
    await tester.pumpAndSettle();
    expect(current, Metric.calories);

    // Tap Time on 360px screen
    await tester.tap(find.text('Time'));
    await tester.pumpAndSettle();
    expect(current, Metric.minutes);

    // Tap Steps on 360px screen
    await tester.tap(find.text('Steps'));
    await tester.pumpAndSettle();
    expect(current, Metric.steps);

    expect(tester.takeException(), isNull);
  });

  testWidgets('FitnessMetricSwitch standalone visual spec check', (tester) async {
    Metric selected = Metric.calories;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FitnessMetricSwitch(
              selectedMetric: selected,
              onChanged: (m) => selected = m,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify outer container height is at least 44px
    final switchFinder = find.byType(FitnessMetricSwitch);
    final renderBox = tester.renderObject<RenderBox>(switchFinder);
    expect(renderBox.size.height, greaterThanOrEqualTo(44.0));

    // Tap Steps
    await tester.tap(find.text('Steps'));
    await tester.pumpAndSettle();
    expect(selected, Metric.steps);
  });
}
