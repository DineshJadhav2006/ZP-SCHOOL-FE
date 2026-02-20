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

    final url =
        "${ApiConfig.baseUrl}/teachers/$clientId/teachers/$teacherId";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data["teacher"];
    } else {
      return null;
    }
  }
}
