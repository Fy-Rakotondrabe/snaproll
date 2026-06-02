import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _langKey = 'language';
  static const _notifHourKey = 'notif_hour';
  static const _notifMinKey = 'notif_min';
  static const _notifEnabledKey = 'notif_enabled';
  static const _activityKey = 'activity_dates';
  static const _recordStreakKey = 'record_streak';

  // Notifies ProgressPage when a spin is recorded
  static final spinNotifier = ValueNotifier<int>(0);

  // ── Language ─────────────────────────────────────────────────────────────────

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'fr';
  }

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  // ── Notifications ─────────────────────────────────────────────────────────────

  static Future<TimeOfDay> getNotifTime() async {
    final prefs = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: prefs.getInt(_notifHourKey) ?? 9,
      minute: prefs.getInt(_notifMinKey) ?? 0,
    );
  }

  static Future<void> setNotifTime(TimeOfDay t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notifHourKey, t.hour);
    await prefs.setInt(_notifMinKey, t.minute);
  }

  static Future<bool> getNotifEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifEnabledKey) ?? false;
  }

  static Future<void> setNotifEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifEnabledKey, v);
  }

  // ── Activity & Streak ─────────────────────────────────────────────────────────

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Records a spin for today. Idempotent — multiple calls on the same day = one entry.
  static Future<void> recordSpinToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(_today());
    final dates = prefs.getStringList(_activityKey) ?? [];
    if (dates.contains(today)) return; // already recorded today

    dates.add(today);
    await prefs.setStringList(_activityKey, dates);

    // Update record streak if new streak beats old record
    final streak = _computeStreak(dates);
    final record = prefs.getInt(_recordStreakKey) ?? 0;
    if (streak > record) {
      await prefs.setInt(_recordStreakKey, streak);
    }

    spinNotifier.value++;
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return _computeStreak(prefs.getStringList(_activityKey) ?? []);
  }

  static Future<int> getRecordStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_recordStreakKey) ?? 0;
  }

  /// Returns 7 booleans for Mon→Sun of the current week.
  static Future<List<bool>> getWeekActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final dates = (prefs.getStringList(_activityKey) ?? []).toSet();
    final today = _today();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return dates.contains(_dateKey(day));
    });
  }

  static int _computeStreak(List<String> dates) {
    if (dates.isEmpty) return 0;
    final unique = dates.map(DateTime.parse).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final today = _today();
    int streak = 0;
    DateTime expected = today;
    for (final d in unique) {
      final day = DateTime(d.year, d.month, d.day);
      if (day == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (day.isBefore(expected)) {
        break;
      }
    }
    return streak;
  }
}
