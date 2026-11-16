import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitnesstracker/data/fitness_store.dart';
import 'package:fitnesstracker/models/activity.dart';
import 'package:fitnesstracker/screens/history_screen.dart';
import 'package:fitnesstracker/widgets/activity_tile.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp(FitnessStore store, {Size size = const Size(360, 640)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: HistoryScreen(store: store),
        ),
      ),
    );
  }

  testWidgets('ActivityTile formats duration and displays chips properly', (tester) async {
    final activity90 = Activity(
      id: '1',
      type: ActivityType.running,
      date: DateTime.now(),
      steps: 8500,
      durationMinutes: 90,
      calories: 620,
      note: 'Long morning run across the downtown bridge and park',
    );

    final activity45 = Activity(
      id: '2',
      type: ActivityType.yoga,
      date: DateTime.now(),
      durationMinutes: 45,
      calories: 180,
      note: 'Evening calm flow',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Column(
            children: [
              ActivityTile(activity: activity90, onDelete: () {}),
              ActivityTile(activity: activity45, onDelete: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.text('1h 30m'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('8,500'), findsOneWidget);
    expect(find.text('620 kcal'), findsOneWidget);
    expect(find.text('180 kcal'), findsOneWidget);
    expect(find.text(activity90.note), findsOneWidget);
  });

  testWidgets('History screen shows items and does not overflow at 360px', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final store = FitnessStore();
    await store.add(Activity(
      id: '1',
      type: ActivityType.running,
      date: DateTime.now(),
      steps: 99999,
      durationMinutes: 135,
      calories: 9999,
      note: 'A very very long note describing this intense workout session at 360px width without any overflow issues',
    ));

    await tester.pumpWidget(buildTestApp(store, size: const Size(360, 640)));
    await tester.pumpAndSettle();

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('2h 15m'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Fallback delete button shows confirmation dialog, Cancel keeps item', (tester) async {
    final store = FitnessStore();
    await store.add(Activity(
      id: '1',
      type: ActivityType.walking,
      date: DateTime.now(),
      steps: 5000,
      durationMinutes: 30,
      calories: 150,
    ));

    await tester.pumpWidget(buildTestApp(store));
    await tester.pumpAndSettle();

    expect(store.activities.length, 1);

    // Find and tap the fallback delete button (Tooltip 'Delete')
    final deleteBtn = find.byTooltip('Delete');
    expect(deleteBtn, findsOneWidget);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Delete this activity?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Item is still there
    expect(store.activities.length, 1);
    expect(find.text('Walking'), findsOneWidget);
  });

  testWidgets('Fallback delete button shows confirmation dialog, Delete removes item', (tester) async {
    final store = FitnessStore();
    await store.add(Activity(
      id: '1',
      type: ActivityType.walking,
      date: DateTime.now(),
      steps: 5000,
      durationMinutes: 30,
      calories: 150,
    ));

    await tester.pumpWidget(buildTestApp(store));
    await tester.pumpAndSettle();

    final deleteBtn = find.byTooltip('Delete');
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    expect(find.text('Delete this activity?'), findsOneWidget);

    // Tap Delete in dialog
    final dialogDelete = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Delete'),
    );
    await tester.tap(dialogDelete);
    await tester.pumpAndSettle();

    // Item was removed
    expect(store.activities.isEmpty, isTrue);
    expect(find.text('No activities recorded yet'), findsOneWidget);
  });

  testWidgets('Swipe to delete reveals background, Cancel keeps item, Confirm deletes item', (tester) async {
    final store = FitnessStore();
    await store.add(Activity(
      id: '1',
      type: ActivityType.cycling,
      date: DateTime.now(),
      durationMinutes: 45,
      calories: 300,
    ));

    await tester.pumpWidget(buildTestApp(store));
    await tester.pumpAndSettle();

    expect(store.activities.length, 1);

    // Fling left (endToStart)
    await tester.fling(find.byType(Dismissible), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Delete this activity?'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Item kept
    expect(store.activities.length, 1);
    expect(find.text('Cycling'), findsOneWidget);

    // Fling left again
    await tester.fling(find.byType(Dismissible), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    // Tap Delete
    final dialogDelete = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Delete'),
    );
    await tester.tap(dialogDelete);
    await tester.pumpAndSettle();

    // Item dismissed & deleted
    expect(store.activities.isEmpty, isTrue);
  });

  testWidgets('Tapping tile opens the edit activity screen', (tester) async {
    final store = FitnessStore();
    await store.add(Activity(
      id: '1',
      type: ActivityType.running,
      date: DateTime.now(),
      steps: 7000,
      durationMinutes: 40,
      calories: 450,
      note: 'Morning run',
    ));

    await tester.pumpWidget(buildTestApp(store));
    await tester.pumpAndSettle();

    // Tap on the running activity tile
    await tester.tap(find.text('Running'));
    await tester.pumpAndSettle();

    // Verify Edit Activity screen opened
    expect(find.text('Edit Activity'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });
}
