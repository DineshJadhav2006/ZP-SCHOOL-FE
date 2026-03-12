import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../config/env_config.dart';
import 'http_service.dart';
import 'auth_service.dart';

class StudentService {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamps[key]!).inMilliseconds < EnvConfig.cacheTimeout;
  }

  static Future<Map<String, dynamic>?> getStudent() async {
    String? clientId = await AuthService.getClientId();
    String? studentId = await AuthService.getStudentId();

    if (clientId == null || studentId == null) {
      return null;
    }

    final cacheKey = 'student_$studentId';
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final url = ApiConfig.studentUrl(clientId, studentId);
      final response = await HttpService.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final student = data["student"];
        _cache[cacheKey] = student;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return student;
      }
      return _cache[cacheKey];
    } catch (e) {
      return _cache[cacheKey];
    }
  }

  static Future<int> getStudentCount(String standard) async {
    final cacheKey = 'student_count_$standard';
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      String? clientId = await AuthService.getClientId();
      final url = ApiConfig.studentsListUrl(clientId!, standard);
      
      final response = await HttpService.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final count = data["pagination"]["total"];
        _cache[cacheKey] = count;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return count;
      }
      return _cache[cacheKey] ?? 0;
    } catch (e) {
      return _cache[cacheKey] ?? 0;
    }
  }

  static Future<List<dynamic>> getStudents(String standard) async {
    final cacheKey = 'students_$standard';
    if (_isCacheValid(cacheKey)) {
      debugPrint("Returning cached students for $standard: ${(_cache[cacheKey] as List).length}");
      return _cache[cacheKey];
    }

    for (int attempt = 1; attempt <= EnvConfig.maxRetries; attempt++) {
      try {
        String? clientId = await AuthService.getClientId();
        final url = ApiConfig.studentsListUrl(clientId!, standard);
        debugPrint("Fetching students (attempt $attempt): $url");
        
        final response = await HttpService.get(url);
        debugPrint("Students API response status: ${response.statusCode}");
        
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          debugPrint("API response data keys: ${data.keys}");
          
          final students = data["students"];
          debugPrint("Students from API: ${students?.length ?? 'null'}");
          
          _cache[cacheKey] = students ?? [];
          _cacheTimestamps[cacheKey] = DateTime.now();
          return students ?? [];
        }
      } catch (e) {
        debugPrint("Attempt $attempt failed: $e");
        if (attempt == EnvConfig.maxRetries) {
          debugPrint("All attempts failed, returning cached: ${(_cache[cacheKey] as List?)?.length ?? 0}");
          return _cache[cacheKey] ?? [];
        }
        // Wait before retry
        await Future.delayed(Duration(milliseconds: 1000 * attempt));
      }
    }
    
    return _cache[cacheKey] ?? [];
  }

  static Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    final cacheKey = 'student_by_id_$studentId';
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      String? clientId = await AuthService.getClientId();
      final url = ApiConfig.studentUrl(clientId!, studentId);
      final response = await HttpService.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final student = data["student"];
        _cache[cacheKey] = student;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return student;
      }
      return _cache[cacheKey];
    } catch (e) {
      return _cache[cacheKey];
    }
  }

  static Future<bool> updateStudent(
    String studentId,
    Map<String, dynamic> body,
  ) async {
    try {
      String? clientId = await AuthService.getClientId();
      final url = ApiConfig.studentUrl(clientId!, studentId);
      final response = await HttpService.put(url, body: jsonEncode(body));

      if (response.statusCode == 200) {
        _cache.removeWhere((key, value) => key.contains('student'));
        _cacheTimestamps.removeWhere((key, value) => key.contains('student'));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteStudent(String studentId) async {
    try {
      String? clientId = await AuthService.getClientId();
      if (clientId == null) return false;

      final url = ApiConfig.studentUrl(clientId, studentId);
      final response = await HttpService.delete(url);

      if (response.statusCode == 200) {
        _cache.removeWhere((key, value) => key.contains('student'));
        _cacheTimestamps.removeWhere((key, value) => key.contains('student'));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
