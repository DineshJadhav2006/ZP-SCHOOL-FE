import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

class AdminService {
  static Future<List<dynamic>> getAdminsByClient(String clientId) async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.adminsByClientUrl(clientId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['admins'] ?? [];
      } else {
        throw Exception('Failed to load admins');
      }
    } catch (e) {
      print('Error fetching admins: $e');
      rethrow;
    }
  }

  static Future<bool> addAdmin({
    required String clientId,
    required String userId,
    required String firstName,
    String? middleName,
    required String lastName,
    required String designation,
    required String mobileNumber,
    String? qualification,
    String? dateOfBirth,
    int? experience,
    String? gender,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final body = {
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'designation': designation,
        'mobile_number': mobileNumber,
        if (middleName != null) 'middle_name': middleName,
        if (qualification != null) 'qualification': qualification,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (experience != null) 'experience': experience,
        if (gender != null) 'gender': gender,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.adminsByClientUrl(clientId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding admin: $e');
      return false;
    }
  }

  static Future<bool> updateAdmin({
    required String clientId,
    required String adminId,
    String? firstName,
    String? middleName,
    String? lastName,
    String? designation,
    String? mobileNumber,
    String? qualification,
    int? experience,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (middleName != null) body['middle_name'] = middleName;
      if (lastName != null) body['last_name'] = lastName;
      if (designation != null) body['designation'] = designation;
      if (mobileNumber != null) body['mobile_number'] = mobileNumber;
      if (qualification != null) body['qualification'] = qualification;
      if (experience != null) body['experience'] = experience;

      final response = await http.put(
        Uri.parse(ApiConfig.adminByIdUrl(clientId, adminId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating admin: $e');
      return false;
    }
  }

  static Future<bool> deleteAdmin(String clientId, String adminId) async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.adminByIdUrl(clientId, adminId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting admin: $e');
      return false;
    }
  }
}
