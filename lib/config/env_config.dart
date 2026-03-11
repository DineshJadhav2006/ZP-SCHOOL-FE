// class EnvConfig {
//   // static const String apiBaseUrl = 'http://localhost:8803';
//   static const String apiBaseUrl = 'http://172.16.21.134:8803';
//   // static const String apiBaseUrl = 'https://zp-school-mandave-kh.onrender.com';
//   static const String appName = 'School Management';
//   static const bool debugMode = true;
//   static const int connectionTimeout = 5000; // Reduced to 5s for faster response
//   static const int receiveTimeout = 5000; // Reduced to 5s for faster response
//   static const int cacheTimeout = 300000; // 5 minutes cache
//   static const int maxRetries = 2;
// } 

class EnvConfig {

  // API URL
  static const String apiBaseUrl = 'http://localhost:8803';
  // static const String apiBaseUrl = 'http://172.16.21.225:8803';
  // static const String apiBaseUrl = 'https://zp-school-mandave-kh.onrender.com';

  // App Info
  static const String appName = 'School Management';

  // Debug
  static const bool debugMode = true;

  // Network Timeout (milliseconds)
  static const int connectionTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 20000; // 20 seconds

  // Cache
  static const int cacheTimeout = 180000; // 3 minutes

  // Retry
  static const int maxRetries = 3;
}