import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/attendance.dart';
import 'auth_service.dart';

class AttendanceService {

  static Future<Map<String, dynamic>> getAttendance({
    required String clientId,
    required String standard,
    required String division,
    required String date,
  }) async {

    final token = await AuthService.getAccessToken();

    final url =
        "${ApiConfig.baseUrl}/attendance/client/$clientId/class"
        "?date=$date&standard=$standard&division=$division";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<Attendance> list =
          (data['data'] as List)
              .map((e) => Attendance.fromJson(e))
              .toList();

      return {
        "total": data['total'],
        "present": data['present'],
        "absent": data['absent'],
        "late": data['late'],
        "list": list
      };
    } else {
      throw Exception("Failed to fetch attendance");
    }
  }

  /// Update Attendance
  static Future<bool> updateAttendance({
    required String attendanceId,
    required String status,
    String? remark,
  }) async {

    final token = await AuthService.getAccessToken();

    final url = "${ApiConfig.baseUrl}/attendance/$attendanceId";

    Map<String, dynamic> body = {
      "status": status,
    };

    if (remark != null && remark.isNotEmpty) {
      body["remark"] = remark;
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  /// Bulk Create Attendance
  static Future<bool> createBulkAttendance({
    required List<Map<String, dynamic>> attendances,
  }) async {

    final token = await AuthService.getAccessToken();

    final url = "${ApiConfig.baseUrl}/attendance/bulk";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "attendances": attendances
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
