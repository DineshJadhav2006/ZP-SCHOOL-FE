import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/teacher/class_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'config/theme.dart';

void main() {
  runApp(const SchoolManagementApp());
}

class SchoolManagementApp extends StatelessWidget {
  const SchoolManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    await Future.delayed(Duration(milliseconds: 100));
    
    bool isLoggedIn = await AuthService.isLoggedIn();
    
    if (!mounted) return;
    
    if (isLoggedIn) {
      String? role = await AuthService.getRole();
      String? teacherName = await AuthService.getTeacherName();
      String? className = await AuthService.getClassName();
      
      if (role == 'teacher' && teacherName != null && className != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClassDashboardScreen(
              className: className,
              teacherName: teacherName,
              designation: 'Teacher',
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
