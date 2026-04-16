import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../services/teacher_service.dart';
import 'admin/admin_screen.dart';
import 'superadmin/superadmin_screen.dart';
import 'teacher/class_selection_screen.dart';
import 'student/student_dashboard_screen.dart';
import '../localization/language_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  void loginUser() async {
    FocusScope.of(context).unfocus();
    if (idController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageService.text("please_enter_id_password")),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Now login returns role
    String? role = await AuthService.login(
      idController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (role != null) {
      // For admin, try to fetch and save their full name
      if (role.toLowerCase() == "admin") {
        try {
          var admin = await TeacherService.getAdmin();
          if (admin != null && admin['first_name'] != null) {
            String firstName = admin['first_name'] ?? '';
            String lastName = admin['last_name'] ?? '';
            String fullName = '$firstName $lastName'.trim();
            if (fullName.isNotEmpty) {
              await AuthService.setAdminName(fullName);
            }
          }
        } catch (e) {
          debugPrint("Error fetching admin details: $e");
          // Fallback: save the login ID as admin name
          String adminIdentifier = idController.text.trim();
          if (adminIdentifier.contains("@")) {
            adminIdentifier = adminIdentifier.split("@")[0];
          }
          await AuthService.setAdminName(adminIdentifier);
        }
      }

      // Success message (Top Light Blue)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.black),
              SizedBox(width: 10),
              Text(
                LanguageService.text("login_successful"),
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          backgroundColor: Colors.lightBlue.shade100,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate after 2 seconds based on role
      Future.delayed(Duration(seconds: 2), () {
        navigateByRole(role);
      });
    } else {
      // Error popup with icon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          duration: Duration(seconds: 2),
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  LanguageService.text("invalid_id_password"),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void navigateByRole(String role) {
    Widget screen;

    switch (role.toLowerCase()) {
      case "admin":
        screen = AdminScreen();
        break;
      case "superadmin":
        screen = SuperAdminScreen();
        break;
      case "teacher":
        screen = ClassSelectionScreen();
        break;
      case "student":
        screen = StudentDashboardScreen();
        break;
      default:
        screen = LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(LanguageService.text("school_login")),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.primaryColor,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient decoration
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or Icon
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 64,
                      color: theme.primaryColor,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                  
                  SizedBox(height: 30),
                  
                  // Login Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.05),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            LanguageService.text("school_login"),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.primaryColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          
                          SizedBox(height: 35),
                          
                          TextField(
                            controller: idController,
                            decoration: InputDecoration(
                              labelText: LanguageService.text("unique_id"),
                              prefixIcon: Icon(Icons.person_rounded),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: theme.primaryColor, width: 2),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          TextField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: LanguageService.text("password"),
                              prefixIcon: Icon(Icons.lock_rounded),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: theme.primaryColor, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: theme.primaryColor.withValues(alpha: 0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 35),
                          
                          isLoading
                              ? CircularProgressIndicator()
                              : SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: loginUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor: theme.primaryColor.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      LanguageService.text("login"),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ).animate().slideY(begin: 0.1, duration: 500.ms).fadeIn(duration: 500.ms),
                  
                  SizedBox(height: 20),
                  
                  Text(
                    "© 2026 School Management System",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
