import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import 'auth_service.dart';

class ComplaintService {
  static Future<Map<String, dynamic>> getMyComplaints({String? status}) async {
    try {
      String? token = await AuthService.getAccessToken();
      
      String url = '${EnvConfig.apiBaseUrl}/complaints/my-complaints';
      if (status != null) {
        url += '?status=$status';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'data': [], 'count': 0};
    } catch (e) {
      print('Error fetching complaints: $e');
      return {'data': [], 'count': 0};
    }
  }

  static Future<Map<String, dynamic>> getAllComplaints({String? status}) async {
    try {
      String? token = await AuthService.getAccessToken();
      
      String url = '${EnvConfig.apiBaseUrl}/complaints';
      if (status != null) {
        url += '?status=$status';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'data': [], 'count': 0};
    } catch (e) {
      print('Error fetching all complaints: $e');
      return {'data': [], 'count': 0};
    }
  }

  static Future<Map<String, dynamic>> getTeacherComplaints() async {
    try {
      String? token = await AuthService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/complaints/teacher-complaints'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'data': [], 'count': 0};
    } catch (e) {
      print('Error fetching teacher complaints: $e');
      return {'data': [], 'count': 0};
    }
  }

  static Future<bool> respondToComplaint(String complaintId, String response) async {
    try {
      String? token = await AuthService.getAccessToken();
      
      final apiResponse = await http.patch(
        Uri.parse('${EnvConfig.apiBaseUrl}/complaints/$complaintId/response'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'response': response}),
      );

      return apiResponse.statusCode == 200;
    } catch (e) {
      print('Error responding to complaint: $e');
      return false;
    }
  }

  static Future<bool> deleteComplaint(String complaintId) async {
    try {
      String? token = await AuthService.getAccessToken();
      
      final response = await http.delete(
        Uri.parse('${EnvConfig.apiBaseUrl}/complaints/$complaintId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting complaint: $e');
      return false;
    }
  }

  static Future<bool> submitComplaint({
    required String title,
    required String description,
    required String role,
    String? targetName,
  }) async {
    try {
      String? token = await AuthService.getAccessToken();
      
      Map<String, dynamic> body = {
        'title': title,
        'description': description,
        'role': role,
      };
      
      if (targetName != null && targetName.isNotEmpty) {
        body['target_name'] = targetName;
      }
      
      final response = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/complaints'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error submitting complaint: $e');
      return false;
    }
  }
}
