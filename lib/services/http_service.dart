import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import 'auth_service.dart';

class HttpService {
  static final http.Client _client = http.Client();
  
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final defaultHeaders = {
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
      'User-Agent': 'Flutter App',
    };
    
    String? token = await AuthService.getAccessToken();
    if (token != null) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }
    
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    
    return await _client.get(
      Uri.parse(url),
      headers: defaultHeaders,
    ).timeout(Duration(milliseconds: EnvConfig.connectionTimeout));
  }
  
  static Future<http.Response> post(String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final defaultHeaders = {
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json',
      'User-Agent': 'Flutter App',
    };
    
    String? token = await AuthService.getAccessToken();
    if (token != null) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }
    
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    
    return await _client.post(
      Uri.parse(url),
      headers: defaultHeaders,
      body: body,
    ).timeout(Duration(milliseconds: EnvConfig.connectionTimeout));
  }
  
  static Future<http.Response> put(String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final defaultHeaders = {
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json',
      'User-Agent': 'Flutter App',
    };
    
    String? token = await AuthService.getAccessToken();
    if (token != null) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }
    
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    
    return await _client.put(
      Uri.parse(url),
      headers: defaultHeaders,
      body: body,
    ).timeout(Duration(milliseconds: EnvConfig.connectionTimeout));
  }
  
  static Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    final defaultHeaders = {
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
      'User-Agent': 'Flutter App',
    };
    
    String? token = await AuthService.getAccessToken();
    if (token != null) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }
    
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    
    return await _client.delete(
      Uri.parse(url),
      headers: defaultHeaders,
    ).timeout(Duration(milliseconds: EnvConfig.connectionTimeout));
  }
  
  static void dispose() {
    _client.close();
  }
}