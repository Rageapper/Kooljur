import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Обработчик уведомлений в фоне (должен быть top-level функцией)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCMService: Background message received: ${message.messageId}');
  debugPrint('FCMService: Message data: ${message.data}');
  debugPrint('FCMService: Message notification: ${message.notification?.title}');
}
