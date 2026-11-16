# fitnesstracker

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# CodeAlpha_FitnessTracker

A Fitness Tracker app built with Flutter for the CodeAlpha App Development Internship (Task 3).

## Features

- Log daily activities manually: type (walking, running, cycling, workout, yoga, swimming, other), steps, duration, calories burned, date and an optional note
- **Dashboard** with today's progress: animated steps ring, calories and active-time progress bars
- **Weekly chart** (last 7 days) for steps, calories or active time, with total, daily average and best day
- Set your own **daily goals** (steps, calories, active minutes)
- **History** screen: all activities grouped by day, tap to edit, delete with confirmation
- Data is saved on the device (shared_preferences), so it is still there after restarting the app
- Clean Material 3 interface with light and dark mode
- Charts are drawn with plain Flutter widgets, no chart package needed

## Project structure

```
lib/
  main.dart                          App entry point and themes
  models/                            Activity, Goals, Metric, DayTotals
  data/fitness_store.dart            State + local storage
  utils/format.dart                  Date and number helpers
  screens/home_shell.dart            Bottom navigation + Add button
  screens/dashboard_screen.dart      Daily summary and weekly chart
  screens/history_screen.dart        List of all activities
  screens/activity_form_screen.dart  Add / edit activity form
  widgets/                           Ring, bar chart, cards, goals dialog
```

## Run it

```bash
flutter create codealpha_fitnesstracker
cd codealpha_fitnesstracker
flutter pub add shared_preferences
flutter run
```

## Tech

Flutter, Dart, Material 3, shared_preferences