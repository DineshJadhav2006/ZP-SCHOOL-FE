# ZP School Management System - Flutter Frontend

A comprehensive Flutter mobile and web application for school management, designed for seamless interaction between Students, Teachers, Admins, and Super Admins.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [API Integration](#api-integration)
- [Architecture](#architecture)
- [Key Features by Role](#key-features-by-role)
- [Project Dependencies](#project-dependencies)
- [Environment Variables](#environment-variables)
- [Code Quality](#code-quality)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

### Core Features
- **Multi-Role Authentication**: Support for Student, Teacher, Admin, and Super Admin roles
- **JWT Token Management**: Secure token-based authentication with refresh token support
- **Role-Based Access Control**: Different dashboards and features based on user role
- **Persistent Login**: Automatic session restoration on app restart
- **Logout with Token Invalidation**: Secure logout mechanism

### Student Features
- Dashboard with 5 tabs: Home, Homework, Results, Books, Profile
- View class-specific books with PDF support
- Track homework assignments
- Check academic results and marks
- File complaints with status tracking (All/Pending/Resolved)
- Download homework and educational materials

### Teacher Features
- Class dashboard with student management
- Post homework assignments
- Mark student attendance
- Manage marks and results
- View and respond to student complaints
- Filter complaints by status (All/Pending/Resolved)

### Admin Features
- Complete student and teacher management
- Add books with PDF upload functionality
- Manage school classes and subjects
- View system-wide statistics
- Handle student and teacher complaints
- Filter complaints by status
- Sidebar navigation with quick actions

### Super Admin Features
- System-wide administration
- User and role management
- Complete access to all admin features

### Additional Features
- Multi-language support (English & Marathi)
- PDF file handling and viewing
- Image caching and optimization
- Error handling and user feedback
- Responsive design for mobile and web
- Shimmer loading animations
- Dark/Light theme support

## 🛠 Tech Stack

### Frontend Framework
- **Flutter** 3.8.1+
- **Dart** 3.8.1+

### Key Libraries
- **http** (1.2.0) - HTTP client for API calls
- **shared_preferences** (2.2.2) - Local storage
- **jwt_decoder** (2.0.1) - JWT token decoding
- **url_launcher** (6.2.5) - URL and PDF opening
- **file_picker** (10.3.10) - File selection and upload
- **dio** (5.4.0) - Enhanced HTTP client
- **path_provider** (2.1.2) - File system paths
- **permission_handler** (11.3.0) - Platform permissions
- **table_calendar** (3.0.9) - Calendar widget
- **google_fonts** (6.2.1) - Custom fonts
- **intl** (0.18.1) - Internationalization
- **uuid** (4.5.1) - Unique ID generation

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── config/
│   ├── api_config.dart      # API endpoints configuration
│   ├── env_config.dart      # Environment variables
│   ├── app_config.dart      # App-wide configuration
│   ├── constants.dart       # Application constants
│   ├── environment.dart     # Environment setup
│   └── theme.dart          # Theme configuration
├── screens/
│   ├── splash_screen.dart   # Splash screen with image
│   ├── login_screen.dart    # Login authentication
│   ├── home_screen.dart     # Home screen routing
│   ├── student/
│   │   ├── student_dashboard_screen.dart
│   │   ├── books_screen.dart
│   │   ├── homework_screen.dart
│   │   ├── results_screen.dart
│   │   ├── my_complaints_screen.dart
│   │   └── profile_screen.dart
│   ├── teacher/
│   │   ├── class_dashboard_screen.dart
│   │   ├── student_list_screen.dart
│   │   ├── books_screen.dart
│   │   ├── homework_screen.dart
│   │   ├── attendance_screen.dart
│   │   ├── marks_screen.dart
│   │   ├── teacher_complaints_screen.dart
│   │   └── profile_screen.dart
│   ├── admin/
│   │   ├── admin_screen.dart
│   │   ├── add_book_screen.dart
│   │   ├── admin_complaints_screen.dart
│   │   ├── student_management_screen.dart
│   │   ├── teacher_management_screen.dart
│   │   └── statistics_screen.dart
│   └── superadmin/
│       └── superadmin_screen.dart
├── services/
│   ├── auth_service.dart      # Authentication logic
│   ├── student_service.dart   # Student data operations
│   ├── teacher_service.dart   # Teacher data operations
│   ├── admin_service.dart     # Admin operations
│   ├── book_service.dart      # Book management
│   ├── complaint_service.dart # Complaint handling
│   ├── homework_service.dart  # Homework operations
│   ├── marks_service.dart     # Marks management
│   ├── attendance_service.dart # Attendance tracking
│   ├── notice_service.dart    # Notice management
│   ├── user_service.dart      # User operations
│   ├── client_service.dart    # Client data
│   ├── http_service.dart      # HTTP utilities
│   ├── cache_service.dart     # Caching logic
│   ├── download_helper_mobile.dart  # Mobile downloads
│   ├── download_helper_web.dart     # Web downloads
│   └── download_helper_stub.dart    # Download stub
├── models/
│   ├── user.dart
│   ├── student.dart
│   ├── marks.dart
│   ├── attendance.dart
│   ├── school_class.dart
│   └── [other models]
├── widgets/
│   ├── common_widgets.dart    # Reusable widgets
│   ├── shimmer_loading.dart   # Loading animations
│   ├── student_card.dart      # Student card widget
│   └── [other widgets]
├── localization/
│   ├── app_en.dart            # English strings
│   ├── app_mr.dart            # Marathi strings
│   └── language_service.dart  # Language management
├── utils/
│   ├── common_extensions.dart # Extension methods
│   ├── date_utils.dart        # Date utilities
│   └── validation_utils.dart  # Validation logic
└── assets/
    ├── logo.png               # App logo
    └── splash.png             # Splash screen image
```

## 📋 Prerequisites

- **Flutter SDK** 3.8.1 or higher
- **Dart SDK** 3.8.1 or higher
- **Android Studio** / **Xcode** (for iOS)
- **Git**
- Active internet connection for API calls

### System Requirements
- **Minimum Android**: API 21 (Android 5.0)
- **Minimum iOS**: iOS 12.0
- **Web**: Modern browsers with WebGL support

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/zp-school-fe.git
cd zp-school-fe
```

### 2. Install Dependencies
```bash
flutter clean
flutter pub get
```

### 3. Generate Build Files
```bash
flutter pub get
flutter pub upgrade
```

### 4. For Android
```bash
# Build Android app
flutter build apk
```

### 5. For iOS
```bash
# Build iOS app
flutter build ios
```

### 6. For Web
```bash
# Run web app
flutter run -d chrome
```

## ⚙️ Configuration

### Environment Setup

1. **Copy environment template**:
```bash
cp .env.example .env
```

2. **Update environment variables** in `lib/config/env_config.dart`:
```dart
class EnvConfig {
  static const String apiBaseUrl = 'https://your-api-url.com';
  static const String appName = 'School Management';
  static const bool debugMode = true;
  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 20000;
  static const int cacheTimeout = 180000;
  static const int maxRetries = 3;
}
```

### API Configuration

Update API endpoints in `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = '${EnvConfig.apiBaseUrl}/api/v1';
  
  static String get loginUrl => '$baseUrl/auth/login';
  static String get logoutUrl => '$baseUrl/auth/logout';
  static String get signupUrl => '$baseUrl/auth/signup';
  // ... other endpoints
}
```

## 🎯 Running the Application

### Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with specific flavor
flutter run --flavor dev
```

### Production Mode
```bash
# Build production APK
flutter build apk --release

# Build production app bundle
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Build web
flutter build web --release
```

### Hot Reload
```bash
# During development, use 'r' to hot reload
r   # Hot reload
R   # Hot restart
q   # Quit
```

## 🔌 API Integration

### Authentication Flow
1. User logs in with ID and password
2. Backend returns `accessToken` and `refreshToken`
3. Token stored securely in `SharedPreferences`
4. Token included in all subsequent API requests
5. On logout, token is invalidated on backend

### API Request Format
```dart
final response = await http.get(
  Uri.parse(url),
  headers: {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  },
);
```

### Book Upload Endpoint
- **Endpoint**: `/books/upload-file` (POST)
- **Type**: Multipart form data
- **Response**: Returns `fileUrl` field

### Book Creation Endpoint
- **Endpoint**: `/books/{client_id}/books` (POST)
- **Body**: `{book_name, class_name, subject_name, book_url}`

### Complaint Filtering
- **Query Parameter**: `?status=pending` or `?status=resolved`
- **Supported Statuses**: `pending`, `resolved`, `all`

## 🏗️ Architecture

### MVC Pattern
- **Models**: Data structures in `models/` directory
- **Views**: UI screens in `screens/` directory
- **Controllers**: Business logic in `services/` directory

### Service Layer
- All API calls centralized in service classes
- Consistent error handling
- Token management and refresh logic
- Caching support for frequently accessed data

### State Management
- **StatefulWidget** for simple state management
- **Provider** pattern for complex states
- Local state management within services

### Error Handling
- Try-catch blocks for API calls
- User-friendly error messages
- Graceful degradation on network failures
- Automatic retry mechanism

## 👥 Key Features by Role

### Student
- View personal dashboard
- Download books and materials
- Track homework and assignments
- Check marks and results
- Submit complaints
- Manage profile

### Teacher
- Manage assigned class
- Post homework
- Mark attendance
- Record marks
- View and respond to complaints
- Manage profile

### Admin
- Add and manage books
- Create student/teacher accounts
- View statistics
- Handle complaints
- Manage classes and subjects
- System administration

### Super Admin
- All admin privileges
- User and role management
- System-wide configuration

## 📦 Project Dependencies

| Dependency | Version | Purpose |
|-----------|---------|---------|
| flutter | SDK | UI Framework |
| http | ^1.2.0 | HTTP Client |
| shared_preferences | ^2.2.2 | Local Storage |
| jwt_decoder | ^2.0.1 | JWT Handling |
| url_launcher | ^6.2.5 | Open URLs/PDFs |
| file_picker | ^10.3.10 | File Selection |
| dio | ^5.4.0 | HTTP Client |
| path_provider | ^2.1.2 | File Paths |
| permission_handler | ^11.3.0 | Permissions |
| table_calendar | ^3.0.9 | Calendar |
| google_fonts | ^6.2.1 | Custom Fonts |
| intl | ^0.18.1 | Internationalization |
| uuid | ^4.5.1 | Unique IDs |

## 🌍 Environment Variables

```env
API_BASE_URL=https://zp-school-mandave-kh.onrender.com
APP_NAME=School Management
DEBUG_MODE=true
CONNECTION_TIMEOUT=15000
RECEIVE_TIMEOUT=20000
CACHE_TIMEOUT=180000
MAX_RETRIES=3
```

## ✅ Code Quality

### Linting
```bash
flutter analyze
dart fix --dry-run
dart fix
```

### Testing
```bash
flutter test
```

### Build
```bash
flutter build apk --analyze-size
```

### Code Standards
- Follow Dart style guide
- Maintain consistent naming conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep methods small and focused

## 🔍 Issues Identified & Solutions

### Common Issues

1. **Missing Imports**: All import statements have been verified and added
2. **Image Assets**: Ensure `assets/splash.png` and `assets/logo.png` exist
3. **Network Timeout**: Increase timeout values in `EnvConfig` if needed
4. **JWT Token Expiry**: Implement token refresh logic before expiry
5. **PDF Opening**: Requires platform-specific permissions

### Recommendations

- ✅ Implement better error handling with user feedback
- ✅ Add loading states for better UX
- ✅ Implement local data caching
- ✅ Add comprehensive logging
- ✅ Implement analytics tracking
- ✅ Add crash reporting (Firebase Crashlytics)
- ✅ Implement rate limiting for API calls
- ✅ Add input validation for forms
- ✅ Implement secure token storage
- ✅ Add unit and widget tests

## 🆘 Troubleshooting

### App Won't Start
```bash
flutter clean
flutter pub get
flutter run
```

### Compilation Errors
```bash
# Check for missing imports
flutter analyze

# Update dependencies
flutter pub upgrade

# Clean and rebuild
flutter clean && flutter pub get
```

### API Connection Issues
- Verify API URL in `env_config.dart`
- Check internet connectivity
- Verify API is running and accessible
- Check firewall/proxy settings

### Token Expiry
- Implement automatic token refresh
- Handle 401 Unauthorized responses
- Redirect to login on token expiry

### File Upload Issues
- Check file permissions
- Verify file size limits
- Ensure multipart form data is correctly formatted
- Check CORS settings on backend

## 📝 Contributing

1. Create a new branch (`git checkout -b feature/AmazingFeature`)
2. Commit changes (`git commit -m 'Add some AmazingFeature'`)
3. Push to branch (`git push origin feature/AmazingFeature`)
4. Open a Pull Request

### Code Style
- Follow Dart conventions
- Use meaningful naming
- Add documentation comments
- Keep functions small
- Test before submitting PR

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👨‍💻 Author

**ZP School Management Team**

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Contact: support@zpschool.com
- Documentation: [Wiki](https://github.com/yourusername/zp-school-fe/wiki)

## 🔒 Security

- Never commit credentials or tokens
- Use environment variables for sensitive data
- Keep dependencies updated
- Implement proper authentication
- Use HTTPS for API calls
- Validate all user inputs
- Sanitize data before display

---

**Last Updated**: 2024
**Flutter Version**: 3.8.1+
**Dart Version**: 3.8.1+
