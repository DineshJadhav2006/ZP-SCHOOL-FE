class AppConstants {
  // User Roles
  static const String ROLE_SUPERADMIN = 'superadmin';
  static const String ROLE_ADMIN = 'admin';
  static const String ROLE_TEACHER = 'teacher';
  static const String ROLE_STUDENT = 'student';
  
  // Storage Keys
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_KEY = 'user_data';
  static const String LANGUAGE_KEY = 'selected_language';
  
  // API Endpoints
  static const String LOGIN_ENDPOINT = '/auth/login';
  static const String STUDENTS_ENDPOINT = '/students';
  static const String TEACHERS_ENDPOINT = '/teachers';
  static const String CLASSES_ENDPOINT = '/classes';
  
  // Default Values
  static const String DEFAULT_LANGUAGE = 'en';
  static const int DEFAULT_PAGE_SIZE = 20;
  
  // Validation
  static const int MIN_PASSWORD_LENGTH = 6;
  static const int MAX_NAME_LENGTH = 50;
  
  // Gender Options
  static const List<String> GENDER_OPTIONS = ['Male', 'Female', 'Other'];
  
  // Class Names
  static const List<String> CLASS_NAMES = [
    '1st', '2nd', '3rd', '4th', '5th', 
    '6th', '7th', '8th', '9th', '10th',
    '11th', '12th'
  ];
  
  // Divisions
  static const List<String> DIVISIONS = ['A', 'B', 'C', 'D', 'E'];
}