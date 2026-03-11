import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../models/marks.dart';
import 'auth_service.dart';

class MarksService {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamps[key]!).inMilliseconds < 30000; // 30 seconds cache
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
      String? token = await AuthService.getAccessToken();
      final url = '${EnvConfig.apiBaseUrl}/marks/by-class?standard=$standard&exam_name=${Uri.encodeComponent(examName)}';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

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
      String? token = await AuthService.getAccessToken();
      final url = '${EnvConfig.apiBaseUrl}/marks/student?student_id=$studentId&exam_name=${Uri.encodeComponent(examName)}';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

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
      String? token = await AuthService.getAccessToken();
      final url = '${EnvConfig.apiBaseUrl}/marks/save';
      final body = jsonEncode({
        'student_id': studentId,
        'exam_name': examName,
        'subjects': subjects.map((s) => s.toJson()).toList(),
      });
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

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

  static Future<bool> bulkSaveMarks({
    required String teacherId,
    required String examName,
    required List<StudentMarks> students,
  }) async {
    try {
      String? token = await AuthService.getAccessToken();
      
      if (token == null || teacherId.isEmpty) {
        print('Token or teacherId is null/empty');
        return false;
      }
      
      final response = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/marks/bulk-save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'teacher_id': teacherId,
          'exam_name': examName,
          'students': students.map((s) => s.toJson()).toList(),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving marks: $e');
      return false;
    }
  }

  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
