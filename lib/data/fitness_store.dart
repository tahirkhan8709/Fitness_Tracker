import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/day_totals.dart';
import '../models/goals.dart';
import '../utils/format.dart';

/// Holds all activities and goals, and saves them on the device
/// (shared_preferences) so the data is still there after restarting.
class FitnessStore extends ChangeNotifier {
  static const String _activitiesKey = 'fitness_activities_v1';
  static const String _goalsKey = 'fitness_goals_v1';

  final List<Activity> _activities = [];
  Goals _goals = const Goals();

  /// Newest first.
  List<Activity> get activities => List.unmodifiable(_activities);
  Goals get goals => _goals;

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _activities.clear();

    final rawActivities = prefs.getString(_activitiesKey);
    if (rawActivities != null) {
      try {
        final decoded = jsonDecode(rawActivities) as List<dynamic>;
        _activities.addAll(
          decoded.map((e) => Activity.fromJson(e as Map<String, dynamic>)),
        );
      } catch (_) {
        // Corrupted data: start fresh instead of crashing.
      }
    }

    final rawGoals = prefs.getString(_goalsKey);
    if (rawGoals != null) {
      try {
        _goals = Goals.fromJson(jsonDecode(rawGoals) as Map<String, dynamic>);
      } catch (_) {
        _goals = const Goals();
      }
    }

    _sort();
    notifyListeners();
  }

  Future<void> add(Activity activity) async {
    _activities.add(activity);
    _sort();
    notifyListeners();
    await _saveActivities();
  }

  Future<void> update(Activity activity) async {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index == -1) return;
    _activities[index] = activity;
    _sort();
    notifyListeners();
    await _saveActivities();
  }

  Future<void> delete(String id) async {
    _activities.removeWhere((a) => a.id == id);
    notifyListeners();
    await _saveActivities();
  }

  Future<void> setGoals(Goals goals) async {
    _goals = goals;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalsKey, jsonEncode(goals.toJson()));
  }

  List<Activity> activitiesOn(DateTime day) =>
      _activities.where((a) => isSameDay(a.date, day)).toList();

  DayTotals totalsFor(DateTime day) {
    var steps = 0, calories = 0, minutes = 0;
    for (final a in _activities) {
      if (isSameDay(a.date, day)) {
        steps += a.steps;
        calories += a.calories;
        minutes += a.durationMinutes;
      }
    }
    return DayTotals(
      date: dateOnly(day),
      steps: steps,
      calories: calories,
      minutes: minutes,
    );
  }

  /// Totals for the last [count] days, oldest first, ending today.
  List<DayTotals> lastDays(int count) {
    final today = dateOnly(DateTime.now());
    return List.generate(count, (i) {
      final day = DateTime(today.year, today.month, today.day - (count - 1 - i));
      return totalsFor(day);
    });
  }

  void _sort() {
    _activities.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_activities.map((a) => a.toJson()).toList());
    await prefs.setString(_activitiesKey, encoded);
  }
}
