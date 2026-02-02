import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class AvatarService {
  static const String _keyAvatarPath = 'avatarPath';

  /// Сохранить путь к аватарке
  static Future<void> saveAvatarPath(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarPath, filePath);
    debugPrint('AvatarService: Avatar path saved: $filePath');
  }

  /// Получить путь к аватарке
  static Future<String?> getAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAvatarPath);
  }

  /// Сохранить аватарку в локальное хранилище
  static Future<String?> saveAvatar(File imageFile) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory(path.join(appDocDir.path, 'avatars'));
      
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await imageFile.copy(path.join(avatarDir.path, fileName));
      
      await saveAvatarPath(savedFile.path);
      debugPrint('AvatarService: Avatar saved to: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      debugPrint('AvatarService: Error saving avatar: $e');
      return null;
    }
  }

  /// Получить файл аватарки
  static Future<File?> getAvatarFile() async {
    final avatarPath = await getAvatarPath();
    if (avatarPath == null) return null;
    
    final file = File(avatarPath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Удалить аватарку
  static Future<void> deleteAvatar() async {
    try {
      final avatarPath = await getAvatarPath();
      if (avatarPath != null) {
        final file = File(avatarPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAvatarPath);
      debugPrint('AvatarService: Avatar deleted');
    } catch (e) {
      debugPrint('AvatarService: Error deleting avatar: $e');
    }
  }

  /// Сбросить аватарку на дефолтную (удалить сохраненную)
  static Future<void> resetToDefault() async {
    await deleteAvatar();
    debugPrint('AvatarService: Avatar reset to default');
  }
}
