import 'env_config.dart';

class ApiConfig {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // ============== AUTH ENDPOINTS ==============
  static String get loginUrl => '$baseUrl/auth/login';
  static String get logoutUrl => '$baseUrl/auth/logout';
  static String get signupUrl => '$baseUrl/auth/signup';

  // ============== STUDENT ENDPOINTS ==============
  static String studentUrl(String clientId, String studentId) =>
      '$baseUrl/students/$clientId/students/$studentId';
  
  static String studentsListUrl(String clientId, String standard) =>
      '$baseUrl/students/$clientId/students?class=$standard';

  // ============== TEACHER ENDPOINTS ==============
  static String teacherUrl(String clientId, String teacherId) =>
      '$baseUrl/teachers/$clientId/teachers/$teacherId';
  
  static String teachersListUrl(String clientId) =>
      '$baseUrl/teachers/$clientId/teachers';

  // ============== ADMIN ENDPOINTS ==============
  static String adminUrl(String clientId, String adminId) =>
      '$baseUrl/admins/$clientId/admins/$adminId';

  // ============== ATTENDANCE ENDPOINTS ==============
  static String attendanceByClassUrl(String clientId, String date, String standard, String division) =>
      '$baseUrl/attendance/client/$clientId/class?date=$date&standard=$standard&division=$division';
  
  static String attendanceUpdateUrl(String attendanceId) =>
      '$baseUrl/attendance/$attendanceId';
  
  static String get attendanceBulkUrl => '$baseUrl/attendance/bulk';
  
  static String studentMonthlyAttendanceUrl(String studentId, String month, String year) =>
      '$baseUrl/attendance/student/$studentId/month?month=$month&year=$year';

  // ============== HOMEWORK ENDPOINTS ==============
  static String homeworkByClassUrl(String clientId, String className) =>
      '$baseUrl/homework/$clientId/homework?className=$className';
  
  static String homeworkUrl(String clientId) =>
      '$baseUrl/homework/$clientId/homework';
  
  static String homeworkByIdUrl(String clientId, String homeworkId) =>
      '$baseUrl/homework/$clientId/homework/$homeworkId';

  // ============== STATISTICS ENDPOINTS ==============
  static String get statisticsUrl => '$baseUrl/users/statistics';
  
  static String attendanceStatisticsUrl(String date) =>
      '$baseUrl/attendance/statistics?date=$date';
}
