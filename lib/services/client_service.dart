import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

class ClientService {
  static Future<List<dynamic>> getAllClients() async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.clientsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to load clients');
      }
    } catch (e) {
      print('Error fetching clients: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getClientById(String clientId) async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.clientByIdUrl(clientId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load client');
      }
    } catch (e) {
      print('Error fetching client: $e');
      return null;
    }
  }

  static Future<bool> addClient({
    required String name,
    required String code,
    required String phone,
    String? info,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.clientsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'code': code,
          'phone': phone,
          if (info != null) 'info': info,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding client: $e');
      return false;
    }
  }

  static Future<bool> updateClient({
    required String clientId,
    String? name,
    String? phone,
    String? info,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (info != null) body['info'] = info;

      final response = await http.put(
        Uri.parse(ApiConfig.clientByIdUrl(clientId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating client: $e');
      return false;
    }
  }

  static Future<bool> deleteClient(String clientId) async {
    try {
      final token = await AuthService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.clientByIdUrl(clientId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting client: $e');
      return false;
    }
  }
}
