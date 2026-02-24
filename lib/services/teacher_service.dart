import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

class TeacherService {
  static Future<Map<String, dynamic>?> getTeacher() async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();
    String? teacherId = await AuthService.getTeacherId();

    if (token == null || clientId == null || teacherId == null) {
      return null;
    }

    final url = ApiConfig.teacherUrl(clientId, teacherId);

    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data["teacher"];
    } else {
      return null;
    }
  }

  // Get all teachers
  static Future<List<dynamic>> getAllTeachers() async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    if (token == null || clientId == null) {
      return [];
    }

    final url = ApiConfig.teachersListUrl(clientId);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["teachers"] ?? [];
      }
    } catch (e) {
      print("Error fetching teachers: $e");
    }

    return [];
  }

  // Update teacher
  static Future<bool> updateTeacher(String teacherId, Map<String, dynamic> data) async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    if (token == null || clientId == null) {
      return false;
    }

    final url = ApiConfig.teacherUrl(clientId, teacherId);

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating teacher: $e");
      return false;
    }
  }

  // Delete teacher
  static Future<bool> deleteTeacher(String teacherId) async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    if (token == null || clientId == null) {
      return false;
    }

    final url = ApiConfig.teacherUrl(clientId, teacherId);

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting teacher: $e");
      return false;
    }
  }

  // Get admin profile
  static Future<Map<String, dynamic>?> getAdmin() async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();
    String? adminId = await AuthService.getAdminId();

    if (token == null || clientId == null || adminId == null) {
      return null;
    }

    final url = ApiConfig.adminUrl(clientId, adminId);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data;
      }
    } catch (e) {
      print("Error fetching admin: $e");
    }

    return null;
  }

  // Get statistics (students, teachers, admins count)
  static Future<Map<String, dynamic>?> getStatistics() async {
    String? token = await AuthService.getAccessToken();

    if (token == null) {
      return null;
    }

    final url = ApiConfig.statisticsUrl;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["data"];
      }
    } catch (e) {
      print("Error fetching statistics: $e");
    }

    return null;
  }
}
