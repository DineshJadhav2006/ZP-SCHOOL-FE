import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const String STUDENT_COUNT_KEY = 'student_count_';
  static const String ATTENDANCE_KEY = 'attendance_';
  static const int CACHE_DURATION_MINUTES = 5;

  static Future<void> cacheStudentCount(String className, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'count': count,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString('$STUDENT_COUNT_KEY$className', jsonEncode(data));
  }

  static Future<int?> getCachedStudentCount(String className) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$STUDENT_COUNT_KEY$className');
    if (cached == null) return null;

    final data = jsonDecode(cached);
    final timestamp = data['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - timestamp < CACHE_DURATION_MINUTES * 60 * 1000) {
      return data['count'] as int;
    }
    return null;
  }

  static Future<void> cacheAttendance(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString('$ATTENDANCE_KEY$key', jsonEncode(cacheData));
  }

  static Future<Map<String, dynamic>?> getCachedAttendance(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$ATTENDANCE_KEY$key');
    if (cached == null) return null;

    final cacheData = jsonDecode(cached);
    final timestamp = cacheData['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - timestamp < CACHE_DURATION_MINUTES * 60 * 1000) {
      return cacheData['data'] as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith(STUDENT_COUNT_KEY) || key.startsWith(ATTENDANCE_KEY)) {
        await prefs.remove(key);
      }
    }
  }
}