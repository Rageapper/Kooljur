import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  // Project ID должен быть получен из переменных окружения или конфигурации
  // Для безопасности не хардкодим в коде
  static String get _projectId => const String.fromEnvironment(
        'FIREBASE_PROJECT_ID',
        defaultValue: 'YOUR_PROJECT_ID_HERE',
      );

  // URL сервера для автоматического получения токена
  static const String _tokenServerUrl =
      'https://kooljur-fcm-server.vercel.app/api';

  // OAuth токен для FCM V1 API (получается автоматически с сервера)
  static String? _accessToken;
  static DateTime? _tokenExpiry;
  static bool _isFetchingToken = false;

  // Автоматическое получение OAuth токена с сервера
  static Future<String?> _getAccessToken() async {
    // Если токен еще действителен, возвращаем его
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(
          _tokenExpiry!.subtract(const Duration(minutes: 5)),
        )) {
      return _accessToken;
    }

    // Если уже идет запрос, ждем
    if (_isFetchingToken) {
      // Ждем до 10 секунд
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (_accessToken != null &&
            _tokenExpiry != null &&
            DateTime.now().isBefore(_tokenExpiry!)) {
          return _accessToken;
        }
      }
      return null;
    }

    // Получаем токен с сервера
    if (_tokenServerUrl.contains('YOUR-PROJECT')) {
      debugPrint('NotificationService: ⚠️ Token server URL not configured');
      debugPrint(
        'NotificationService: Please set _tokenServerUrl in notification_service.dart',
      );
      debugPrint(
        'NotificationService: Or use NotificationService.setAccessToken() manually',
      );
      return null;
    }

    _isFetchingToken = true;

    try {
      debugPrint('NotificationService: 🔄 Fetching token from server...');

      final response = await http
          .get(
            Uri.parse(_tokenServerUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true && data['token'] != null) {
          final token = data['token'] as String;
          final expiresIn = data['expiresIn'] as int? ?? 3600;

          _accessToken = token;
          _tokenExpiry = DateTime.now().add(
            Duration(seconds: expiresIn - 300),
          ); // -5 минут для безопасности

          if (kDebugMode) {
            debugPrint('NotificationService: ✅ Token fetched successfully');
          }
          _isFetchingToken = false;
          return _accessToken;
        } else {
          debugPrint(
            'NotificationService: ❌ Server returned error: ${data['error']}',
          );
        }
      } else {
        debugPrint(
          'NotificationService: ❌ Server error: ${response.statusCode}',
        );
        debugPrint('NotificationService: Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('NotificationService: ❌ Error fetching token: $e');
      debugPrint(
        'NotificationService: Falling back to manual token if available',
      );
    } finally {
      _isFetchingToken = false;
    }

    // Fallback: возвращаем старый токен, если он еще есть
    return _accessToken;
  }

  // Установка токена вручную (для тестирования)
  // Получите токен через: node get_fcm_token.js
  static void setAccessToken(String token, {Duration? expiry}) {
    _accessToken = token;
    _tokenExpiry = DateTime.now().add(expiry ?? const Duration(hours: 1));
    debugPrint(
      'NotificationService: ✅ Access token set (expires in ${expiry?.inMinutes ?? 60} minutes)',
    );
  }

  // Отправка push-уведомления через FCM V1 API (бесплатно, без Blaze)
  static Future<bool> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Получаем FCM токен пользователя из Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('NotificationService: No FCM token found for user $userId');
        }
        return false;
      }

      // Получаем OAuth токен
      final accessToken = await _getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('NotificationService: ⚠️ Access token not available');
        debugPrint('NotificationService: Please run: node get_fcm_token.js');
        debugPrint(
          'NotificationService: Then call: NotificationService.setAccessToken("token")',
        );
        return false;
      }

      // Формируем запрос к FCM V1 API
      final url =
          'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

      final message = {
        'message': {
          'token': fcmToken,
          'notification': {'title': title, 'body': body},
          'data': (data ?? {}).map(
            (key, value) => MapEntry(key, value.toString()),
          ),
          'android': {'priority': 'high'},
          'apns': {
            'headers': {'apns-priority': '10'},
            'payload': {
              'aps': {'sound': 'default'},
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint(
          'NotificationService: ✅ Notification sent successfully to user $userId',
        );
        final responseData = jsonDecode(response.body);
        debugPrint('NotificationService: Message ID: ${responseData['name']}');
        return true;
      } else {
        debugPrint(
          'NotificationService: ❌ Failed to send notification: ${response.statusCode}',
        );
        debugPrint('NotificationService: Response: ${response.body}');

        // Если токен истек, очищаем его
        if (response.statusCode == 401) {
          _accessToken = null;
          _tokenExpiry = null;
          debugPrint(
            'NotificationService: Token expired, please get new token',
          );
        }

        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('NotificationService: ❌ Error sending notification: $e');
      debugPrint('NotificationService: Stack trace: $stackTrace');
      return false;
    }
  }

  // Отправка уведомлений нескольким пользователям
  static Future<int> sendNotificationsToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    int successCount = 0;
    for (final userId in userIds) {
      final success = await sendNotification(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
      if (success) successCount++;
    }
    debugPrint(
      'NotificationService: ✅ Sent notifications to $successCount/${userIds.length} users',
    );
    return successCount;
  }
}
