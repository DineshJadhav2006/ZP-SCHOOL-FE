import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class HomeworkService {
  static Future<List<dynamic>> getHomeworkByClass(String className) async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    final url = ApiConfig.homeworkByClassUrl(clientId!, className);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // API response structure check
      // If response is: { "homework": [...] }
      return data["homework"] ?? [];

      // If response is direct list, use:
      // return data;
    } else {
      print("Get Homework Failed: ${response.body}");
      return [];
    }
  }

  static Future<bool> createHomework({
    required String className,
    required String subjectName,
    required String homeworkText,
    required String homeworkDate,
    String? attachmentUrl,
  }) async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    final url = ApiConfig.homeworkUrl(clientId!);

    Map<String, dynamic> body = {
      "class_name": className,
      "subject_name": subjectName,
      "homework_text": homeworkText,
      "homework_date": homeworkDate,
    };

    if (attachmentUrl != null && attachmentUrl.isNotEmpty) {
      body["attachment_url"] = attachmentUrl;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> updateHomework({
    required String homeworkId,
    required String className,
    required String subjectName,
    required String homeworkText,
    required String homeworkDate,
    String? attachmentUrl,
  }) async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    final url = ApiConfig.homeworkByIdUrl(clientId!, homeworkId);

    Map<String, dynamic> body = {
      "class_name": className,
      "subject_name": subjectName,
      "homework_text": homeworkText,
      "homework_date": homeworkDate,
    };

    if (attachmentUrl != null && attachmentUrl.isNotEmpty) {
      body["attachment_url"] = attachmentUrl;
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteHomework(String homeworkId) async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    final url = ApiConfig.homeworkByIdUrl(clientId!, homeworkId);

    final response = await http.delete(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }
}
