import 'dart:convert';
import '../config/env_config.dart';
import '../models/marks.dart';
import 'http_service.dart';

class MarksService {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamps[key]!).inMilliseconds < EnvConfig.cacheTimeout;
  }

  static Future<Map<String, dynamic>> getMarksByClass({
    required String standard,
    required String examName,
  }) async {
    final cacheKey = 'marks_${standard}_${examName}';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final url = '${EnvConfig.apiBaseUrl}/marks/by-class?standard=$standard&exam_name=${Uri.encodeComponent(examName)}';
      final response = await HttpService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cache[cacheKey] = data;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return data;
      }
      return {'marks': []};
    } catch (e) {
      return _cache[cacheKey] ?? {'marks': []};
    }
  }

  static Future<Map<String, dynamic>> getStudentMarks({
    required String studentId,
    required String examName,
  }) async {
    final cacheKey = 'student_marks_${studentId}_${examName}';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final url = '${EnvConfig.apiBaseUrl}/marks/student?student_id=$studentId&exam_name=${Uri.encodeComponent(examName)}';
      final response = await HttpService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cache[cacheKey] = data;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return data;
      }
      return {'marks': []};
    } catch (e) {
      return _cache[cacheKey] ?? {'marks': []};
    }
  }

  static Future<List<String>> getExamNames() async {
    return ['Unit Test 1', 'Mid Sem', 'Unit Test 2', 'Final Exam'];
  }

  static Future<bool> saveMarks({
    required String studentId,
    required String examName,
    required List<SubjectMarks> subjects,
  }) async {
    try {
      final url = '${EnvConfig.apiBaseUrl}/marks/save';
      final body = jsonEncode({
        'student_id': studentId,
        'exam_name': examName,
        'subjects': subjects.map((s) => s.toJson()).toList(),
      });
      
      final response = await HttpService.post(url, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _cache.removeWhere((key, value) => key.contains('marks_') || key.contains('student_marks_'));
        _cacheTimestamps.removeWhere((key, value) => key.contains('marks_') || key.contains('student_marks_'));
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
