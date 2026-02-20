import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

class StudentService {

  static Future<int> getStudentCount(String standard) async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    final url =
        "${ApiConfig.baseUrl}/students/$clientId/students?class=$standard";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data["pagination"]["total"];
    } else {
      return 0;
    }
  }

  static Future<List<dynamic>> getStudents(String standard) async {
    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    final url =
        "${ApiConfig.baseUrl}/students/$clientId/students?class=$standard";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data["students"];
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getStudentById(String studentId) async {
  String? token = await AuthService.getAccessToken();
  String? clientId = await AuthService.getClientId();

  final url =
      "${ApiConfig.baseUrl}/students/$clientId/students/$studentId";

  final response = await http.get(
    Uri.parse(url),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return data["student"];
  } else {
    return null;
  }
}

static Future<bool> updateStudent(
    String studentId, Map<String, dynamic> body) async {

  String? token = await AuthService.getAccessToken();
  String? clientId = await AuthService.getClientId();

  final url =
      "${ApiConfig.baseUrl}/students/$clientId/students/$studentId";

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

}
