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
      body: jsonEncode({
        "uniqueIdOrPhone": id,
        "password": password
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      String accessToken = data["accessToken"];
      String refreshToken = data["refreshToken"];

      // From response (new fields)
      String userId = data["user_id"];
      String roleId = data["role_id"];
      String teacherId = data["teacher_id"];

      // Decode token for extra info
      Map<String, dynamic> decodedToken =
          JwtDecoder.decode(accessToken);

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
      await prefs.setString("teacher_id", teacherId);

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

  // Get Teacher ID
  static Future<String?> getTeacherId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("teacher_id");
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

  // Get Class Name
  static Future<String?> getClassName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("class_name");
  }

  // Check login session
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("access_token");
  }

  // Logout
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
