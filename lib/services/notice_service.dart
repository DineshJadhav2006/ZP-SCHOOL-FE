import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeService {
  static Future<bool> sendNotice({
    required String title,
    required String description,
    required String noticeDate,
    required String role,
    String? className,
  }) async {
    String? token = await AuthService.getAccessToken();

    if (token == null) return false;

    Map<String, dynamic> body = {
      "title": title,
      "description": description,
      "notice_date": noticeDate,
      "role": role,
    };

    if (className != null && className.isNotEmpty) {
      body["class_name"] = className;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.noticesUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error sending notice: $e");
      return false;
    }
  }

  static Future<bool> updateNotice({
    required String noticeId,
    required String title,
    required String description,
    required String noticeDate,
    required String role,
    String? className,
  }) async {
    String? token = await AuthService.getAccessToken();
    if (token == null) return false;

    Map<String, dynamic> body = {
      "title": title,
      "description": description,
      "notice_date": noticeDate,
      "role": role,
    };

    if (className != null && className.isNotEmpty) {
      body["class_name"] = className;
    }

    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.noticesUrl}/$noticeId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating notice: $e");
      return false;
    }
  }

  static Future<bool> deleteNotice(String noticeId) async {
    String? token = await AuthService.getAccessToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.noticesUrl}/$noticeId"),
        headers: {"Authorization": "Bearer $token"},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting notice: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> getNotices({
    String? date,
    int page = 1,
    int limit = 10,
  }) async {
    String? token = await AuthService.getAccessToken();

    if (token == null) return {"data": [], "total": 0};

    String url = "${ApiConfig.noticesUrl}?page=$page&limit=$limit";
    if (date != null) {
      url += "&date=$date";
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return {
          "data": result["data"] ?? [],
          "total": result["total"] ?? 0,
        };
      }
    } catch (e) {
      print("Error fetching notices: $e");
    }

    return {"data": [], "total": 0};
  }

  static Future<void> updateUnreadCount() async {
    String? token = await AuthService.getAccessToken();
    if (token == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      String? lastCheckStr = prefs.getString('last_notice_check');
      DateTime lastCheck = lastCheckStr != null ? DateTime.parse(lastCheckStr) : DateTime.now().subtract(Duration(days: 7));

      // Get student's class
      var studentData = await AuthService.getStudentData();
      String? studentClass = studentData?['standard'];

      var result = await getNotices(limit: 100);
      List<dynamic> allNotices = result['data'];

      // Filter notices for student (same logic as student_notices_screen)
      List<dynamic> filteredNotices = allNotices.where((notice) {
        String role = notice['role'] ?? '';
        String? className = notice['class_name'];
        
        if (role == 'all') return true;
        if (role == 'student') {
          if (className == null || className.isEmpty) return true;
          if (className == studentClass) return true;
        }
        return false;
      }).toList();

      // Count only new notices created after last check
      int newCount = filteredNotices.where((notice) {
        String? createdAt = notice['created_at'];
        if (createdAt == null) return false;
        try {
          DateTime noticeDate = DateTime.parse(createdAt);
          return noticeDate.isAfter(lastCheck);
        } catch (_) {
          return false;
        }
      }).length;

      await prefs.setInt('unread_notices', newCount);
    } catch (e) {
      print("Error updating unread count: $e");
    }
  }
}
