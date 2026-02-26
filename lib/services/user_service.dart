import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

class UserService {
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.userUrl(userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAllStatistics() async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.allStatisticsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      print('Error fetching statistics: $e');
      return null;
    }
  }
}
