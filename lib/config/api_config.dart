import 'env_config.dart';

class ApiConfig {
  static String get baseUrl => EnvConfig.apiBaseUrl;
  
  // Auth endpoints
  static String get loginUrl => '$baseUrl/auth/login';
  
  // Student endpoints
  static String get studentsUrl => '$baseUrl/api/students';
  static String studentByIdUrl(int id) => '$baseUrl/api/students/$id';
  
  // Teacher endpoints
  static String get teachersUrl => '$baseUrl/api/teachers';
  static String teacherByIdUrl(int id) => '$baseUrl/api/teachers/$id';
}