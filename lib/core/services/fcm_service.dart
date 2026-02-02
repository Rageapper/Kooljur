import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/services/notification_settings_service.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String _fcmTokenKey = 'fcm_token';

  // Инициализация FCM
  static Future<void> initialize() async {
    try {
      // Проверяем настройку пользователя
      final notificationsEnabled = await NotificationSettingsService.arePushNotificationsEnabled();
      if (!notificationsEnabled) {
        debugPrint('FCMService: Push notifications disabled by user, skipping initialization');
        return;
      }

      // Запрашиваем разрешение на уведомления
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCMService: Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCMService: User granted permission');
        
        // Получаем токен
        String? token = await _messaging.getToken();
        if (token != null) {
          // Не логируем токен в production для безопасности
          if (kDebugMode) {
            debugPrint('FCMService: FCM Token obtained (length: ${token.length})');
          }
          await _saveToken(token);
          await _saveTokenToFirestore(token);
        }

        // Слушаем обновления токена
        _messaging.onTokenRefresh.listen((newToken) {
          if (kDebugMode) {
            debugPrint('FCMService: Token refreshed (length: ${newToken.length})');
          }
          _saveToken(newToken);
          _saveTokenToFirestore(newToken);
        });

        // Обработка уведомлений когда приложение открыто
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('FCMService: Message received while app is open');
          debugPrint('FCMService: Message data: ${message.data}');
          debugPrint('FCMService: Message notification: ${message.notification?.title}');
        });

        // Обработка уведомлений когда приложение в фоне
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('FCMService: Message opened from background');
          debugPrint('FCMService: Message data: ${message.data}');
        });
      } else {
        debugPrint('FCMService: User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint('FCMService: Error initializing: $e');
    }
  }

  // Повторная инициализация (когда пользователь включает уведомления)
  static Future<void> reinitialize() async {
    debugPrint('FCMService: Reinitializing FCM...');
    await initialize();
  }

  // Удаление токена (когда пользователь отключает уведомления)
  static Future<void> disableNotifications() async {
    try {
      final currentUser = await DataService.getCurrentUser();
      if (currentUser != null) {
        // Удаляем токен из Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.id)
            .update({
          'fcmToken': FieldValue.delete(),
        });
        debugPrint('FCMService: FCM token removed from Firestore for user ${currentUser.id}');
      }
      
      // Удаляем токен локально
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);
      debugPrint('FCMService: FCM token removed locally');
    } catch (e) {
      debugPrint('FCMService: Error disabling notifications: $e');
    }
  }

  // Сохранение токена локально
  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);
      debugPrint('FCMService: Token saved locally');
    } catch (e) {
      debugPrint('FCMService: Error saving token: $e');
    }
  }

  // Сохранение токена в Firestore для текущего пользователя
  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      final currentUser = await DataService.getCurrentUser();
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.id)
            .update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        if (kDebugMode) {
          debugPrint('FCMService: Token saved to Firestore for user ${currentUser.id}');
        }
      } else {
        debugPrint('FCMService: No current user, cannot save token to Firestore');
      }
    } catch (e) {
      debugPrint('FCMService: Error saving token to Firestore: $e');
    }
  }

  // Получение токена текущего пользователя
  static Future<String?> getCurrentUserToken() async {
    try {
      final currentUser = await DataService.getCurrentUser();
      if (currentUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.id)
            .get();
        return doc.data()?['fcmToken'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('FCMService: Error getting token: $e');
      return null;
    }
  }

  // Получение токена пользователя по ID
  static Future<String?> getUserToken(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.data()?['fcmToken'] as String?;
    } catch (e) {
      debugPrint('FCMService: Error getting user token: $e');
      return null;
    }
  }

  // Отправка уведомления пользователю
  static Future<bool> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await getUserToken(userId);
      if (token == null) {
        debugPrint('FCMService: No FCM token found for user $userId');
        return false;
      }

      // Отправляем через HTTP API Firebase Cloud Messaging
      // Для этого нужен серверный ключ, но мы можем использовать Firestore triggers
      // или Cloud Functions. Для простоты, сохраним задачу на отправку в Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
      });

      debugPrint('FCMService: Notification task created for user $userId');
      return true;
    } catch (e) {
      debugPrint('FCMService: Error sending notification: $e');
      return false;
    }
  }
}

