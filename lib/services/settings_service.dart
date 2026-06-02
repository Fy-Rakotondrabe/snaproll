import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _langKey = 'language';
  static const _notifHourKey = 'notif_hour';
  static const _notifMinKey = 'notif_min';
  static const _notifEnabledKey = 'notif_enabled';

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'fr';
  }

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  static Future<TimeOfDay> getNotifTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_notifHourKey) ?? 9;
    final min = prefs.getInt(_notifMinKey) ?? 0;
    return TimeOfDay(hour: hour, minute: min);
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
}
