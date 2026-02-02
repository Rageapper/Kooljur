import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class NotificationSettingsService {
  static const String _pushNotificationsEnabledKey = 'push_notifications_enabled';

  // Получить статус push-уведомлений
  static Future<bool> arePushNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // По умолчанию уведомления включены
      return prefs.getBool(_pushNotificationsEnabledKey) ?? true;
    } catch (e) {
      debugPrint('NotificationSettingsService: Error getting setting: $e');
      return true; // По умолчанию включены
    }
  }

  // Установить статус push-уведомлений
  static Future<void> setPushNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pushNotificationsEnabledKey, enabled);
      debugPrint('NotificationSettingsService: Push notifications ${enabled ? "enabled" : "disabled"}');
    } catch (e) {
      debugPrint('NotificationSettingsService: Error saving setting: $e');
    }
  }
}
