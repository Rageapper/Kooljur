import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static const Locale _defaultLocale = Locale('ru', ''); // Русский по умолчанию

  // Поддерживаемые языки
  static const List<Locale> supportedLocales = [
    Locale('ru', ''), // Русский
    Locale('kk', ''), // Казахский
    Locale('en', ''), // Английский
  ];

  // Получить текущий язык
  static Future<Locale> getCurrentLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        return Locale(languageCode, '');
      }
      
      // Если язык не сохранен, используем системный
      return _getSystemLocale();
    } catch (e) {
      debugPrint('LanguageService: Error getting locale: $e');
      return _defaultLocale;
    }
  }

  // Установить язык
  static Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      debugPrint('LanguageService: Language set to ${locale.languageCode}');
    } catch (e) {
      debugPrint('LanguageService: Error setting locale: $e');
    }
  }

  // Получить системный язык
  static Locale _getSystemLocale() {
    try {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      
      // Проверяем, поддерживается ли системный язык
      if (supportedLocales.any((locale) => locale.languageCode == systemLocale.languageCode)) {
        return Locale(systemLocale.languageCode, '');
      }
      
      return _defaultLocale;
    } catch (e) {
      debugPrint('LanguageService: Error getting system locale: $e');
      return _defaultLocale;
    }
  }

  // Получить название языка
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return 'Русский';
      case 'kk':
        return 'Қазақша';
      case 'en':
        return 'English';
      default:
        return 'Русский';
    }
  }
}
