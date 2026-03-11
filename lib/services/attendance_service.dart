import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/attendance.dart';
import 'auth_service.dart';
import 'http_service.dart';

class AttendanceService {

  static Future<Map<String, dynamic>> getAttendance({
    required String clientId,
    required String standard,
    required String division,
    required String date,
  }) async {

    final url = ApiConfig.attendanceByClassUrl(clientId, date, standard, division);

    final response = await HttpService.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<Attendance> list =
          (data['data'] as List)
              .map((e) => Attendance.fromJson(e))
              .toList();

      return {
        "total": data['total'] ?? 0,
        "present": data['present'] ?? 0,
        "absent": data['absent'] ?? 0,
        "late": data['late'] ?? 0,
        "list": list
      };
    } else {
      return {
        "total": 0,
        "present": 0,
        "absent": 0,
        "late": 0,
        "list": <Attendance>[]
      };
    }
  }

  /// Update Attendance
  static Future<bool> updateAttendance({
    required String attendanceId,
    required String status,
    String? remark,
  }) async {

    final token = await AuthService.getAccessToken();

    final url = ApiConfig.attendanceUpdateUrl(attendanceId);

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

    final url = ApiConfig.attendanceBulkUrl;

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

  static Future<List<dynamic>> getStudentMonthlyAttendance({
  required String studentId,
  required String month,
  required String year,
}) async {
  final response = await http.get(
    Uri.parse(ApiConfig.studentMonthlyAttendanceUrl(studentId, month, year)),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['data'];
  } else {
    throw Exception('Failed to load attendance');
  }
}


static Future<Map<String, dynamic>> getStudentMonthlyAttendanceFull({
  required String studentId,
  required String month,
  required String year,
}) async {
  final response = await http.get(
    Uri.parse(ApiConfig.studentMonthlyAttendanceUrl(studentId, month, year)),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load attendance');
  }
}

  static Future<Map<String, dynamic>?> getAttendanceStatistics(String date) async {
    String? token = await AuthService.getAccessToken();

    if (token == null) return null;

    final url = ApiConfig.attendanceStatisticsUrl(date);

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
      print("Error fetching attendance statistics: $e");
    }

    return null;
  }
}
