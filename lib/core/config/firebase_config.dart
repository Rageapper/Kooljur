/// Конфигурация Firebase
/// 
/// Для использования создайте файл firebase_config_local.dart с вашими данными:
/// 
/// ```dart
/// class FirebaseConfigLocal {
///   static const String apiKey = 'YOUR_API_KEY';
///   static const String appId = 'YOUR_APP_ID';
///   static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
///   static const String projectId = 'YOUR_PROJECT_ID';
/// }
/// ```
/// 
/// Или используйте переменные окружения.

class FirebaseConfig {
  // Используем значения из переменных окружения или дефолтные для разработки
  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );
  
  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: 'YOUR_APP_ID_HERE',
  );
  
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: 'YOUR_MESSAGING_SENDER_ID_HERE',
  );
  
  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'YOUR_PROJECT_ID_HERE',
  );
}
