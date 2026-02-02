import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CacheService {
  /// Очистить кеш приложения
  static Future<bool> clearCache() async {
    try {
      bool success = true;
      int deletedCount = 0;
      
      // Получаем директорию кеша приложения
      final cacheDir = await getTemporaryDirectory();
      debugPrint('CacheService: Cache directory path: ${cacheDir.path}');
      
      // Очищаем содержимое директории кеша
      if (await cacheDir.exists()) {
        try {
          final entities = cacheDir.list();
          await for (var entity in entities) {
            try {
              if (entity is File) {
                await entity.delete();
                deletedCount++;
              } else if (entity is Directory) {
                await entity.delete(recursive: true);
                deletedCount++;
              }
            } catch (e) {
              debugPrint('CacheService: Error deleting cache item ${entity.path}: $e');
            }
          }
          debugPrint('CacheService: Cache directory cleared. Deleted $deletedCount items');
        } catch (e) {
          debugPrint('CacheService: Error clearing cache directory: $e');
          success = false;
        }
      } else {
        debugPrint('CacheService: Cache directory does not exist');
      }
      
      // Также очищаем директорию документов (если там есть кеш)
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final cachePath = path.join(appDocDir.path, 'cache');
        final cacheDirectory = Directory(cachePath);
        
        if (await cacheDirectory.exists()) {
          await cacheDirectory.delete(recursive: true);
          debugPrint('CacheService: App documents cache cleared');
        }
      } catch (e) {
        debugPrint('CacheService: Error clearing app documents cache: $e');
        // Не критично, продолжаем
      }
      
      debugPrint('CacheService: Cache clearing completed. Success: $success');
      return success;
    } catch (e, stackTrace) {
      debugPrint('CacheService: Error clearing cache: $e');
      debugPrint('CacheService: Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// Получить размер кеша
  static Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        totalSize += await _getDirectorySize(cacheDir);
      }
      
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final cachePath = path.join(appDocDir.path, 'cache');
        final cacheDirectory = Directory(cachePath);
        
        if (await cacheDirectory.exists()) {
          totalSize += await _getDirectorySize(cacheDirectory);
        }
      } catch (e) {
        debugPrint('CacheService: Error getting app documents cache size: $e');
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('CacheService: Error getting cache size: $e');
      return 0;
    }
  }
  
  /// Получить размер директории
  static Future<int> _getDirectorySize(Directory directory) async {
    int size = 0;
    try {
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              size += await entity.length();
            } catch (e) {
              debugPrint('CacheService: Error getting file size: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('CacheService: Error calculating directory size: $e');
    }
    return size;
  }
  
  /// Форматировать размер в читаемый вид
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
