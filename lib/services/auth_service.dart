import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/api_config.dart';

class AuthService {
  // Login API
  static Future<String?> login(String id, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uniqueIdOrPhone": id, "password": password}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      String accessToken = data["accessToken"];
      String refreshToken = data["refreshToken"];

      // From response (new fields)
      String userId = data["user_id"];
      String roleId = data["role_id"];
      String? teacherId = data["teacher_id"];
      String? studentId = data["student_id"];
      String? adminId = data["admin_id"];

      // Decode token for extra info
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

      String role = decodedToken["role_name"];
      String clientId = decodedToken["client_id"];

      // Save in local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString("access_token", accessToken);
      await prefs.setString("refresh_token", refreshToken);
      await prefs.setString("role", role);
      await prefs.setString("user_id", userId);
      await prefs.setString("client_id", clientId);
      await prefs.setString("role_id", roleId);

      // Save teacher, student, or admin ID based on role
      if (teacherId != null) {
        await prefs.setString("teacher_id", teacherId);
      }
      if (studentId != null) {
        await prefs.setString("student_id", studentId);
      }
      if (adminId != null) {
        await prefs.setString("admin_id", adminId);
      }

      return role;
    } else {
      return null;
    }
  }

  // Get Access Token
  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  // Get Client ID
  static Future<String?> getClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("client_id");
  }

  // Get User ID
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id");
  }

  // Get Teacher ID
  static Future<String?> getTeacherId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("teacher_id");
  }

  // Get Student ID
  static Future<String?> getStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("student_id");
  }

  // Get Admin ID
  static Future<String?> getAdminId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("admin_id");
  }

  // Get Role
  static Future<String?> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  // Get Teacher Name
  static Future<String?> getTeacherName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("teacher_name");
  }

  // Get Student Name
  static Future<String?> getStudentName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("student_name");
  }

  // Get Class Name
  static Future<String?> getClassName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("class_name");
  }

  // Get Admin Name
  static Future<String?> getAdminName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("admin_name");
  }

  // Set Admin Name
  static Future<void> setAdminName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("admin_name", name);
  }

  // Check login session
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("access_token");
  }

  // Logout with token invalidation
  static Future<void> logout() async {
    try {
      String? token = await getAccessToken();
      if (token != null) {
        // Try to notify backend about logout
        await http
            .post(
              Uri.parse(ApiConfig.logoutUrl),
              headers: {"Authorization": "Bearer $token"},
            )
            .timeout(Duration(seconds: 5))
            .catchError((_) => null);
      }
    } catch (e) {
      print("Error during logout API call: $e");
    } finally {
      // Always clear local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  // Check if token is still valid (not expired)
  static Future<bool> isTokenValid() async {
    String? token = await getAccessToken();
    if (token == null) return false;

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int expirationTime = decodedToken['exp'] as int;
      DateTime expiresAt = DateTime.fromMillisecondsSinceEpoch(
        expirationTime * 1000,
      );
      return DateTime.now().isBefore(expiresAt);
    } catch (e) {
      return false;
    }
  }

  // Signup (Add Teacher/Student)
  static Future<Map<String, dynamic>?> signup(Map<String, dynamic> data) async {
    String? token = await getAccessToken();
    
    final response = await http.post(
      Uri.parse(ApiConfig.signupUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Get Student Data
  static Future<Map<String, dynamic>?> getStudentData() async {
    String? token = await getAccessToken();
    String? clientId = await getClientId();
    String? studentId = await getStudentId();

    if (token == null || clientId == null || studentId == null) {
      return null;
    }

    final url = ApiConfig.studentUrl(clientId, studentId);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["student"];
      }
    } catch (e) {
      print("Error fetching student data: $e");
    }

    return null;
  }
}
