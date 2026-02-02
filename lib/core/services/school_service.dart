import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SchoolService {
  static const String _selectedSchoolKey = 'selected_school';
  static const String _selectedSchoolAddressKey = 'selected_school_address';

  /// Сохранить выбранную школу
  static Future<void> setSelectedSchool(String name, String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedSchoolKey, name);
      await prefs.setString(_selectedSchoolAddressKey, address);
      debugPrint('SchoolService: School saved - $name');
    } catch (e) {
      debugPrint('SchoolService: Error saving school: $e');
    }
  }

  /// Получить название выбранной школы
  static Future<String?> getSelectedSchoolName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_selectedSchoolKey);
    } catch (e) {
      debugPrint('SchoolService: Error getting school name: $e');
      return null;
    }
  }

  /// Получить адрес выбранной школы
  static Future<String?> getSelectedSchoolAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_selectedSchoolAddressKey);
    } catch (e) {
      debugPrint('SchoolService: Error getting school address: $e');
      return null;
    }
  }

  /// Очистить выбранную школу
  static Future<void> clearSelectedSchool() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_selectedSchoolKey);
      await prefs.remove(_selectedSchoolAddressKey);
      debugPrint('SchoolService: School cleared');
    } catch (e) {
      debugPrint('SchoolService: Error clearing school: $e');
    }
  }
}
