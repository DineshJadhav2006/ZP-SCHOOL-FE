import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                LanguageService.changeLanguage(value);
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "en", child: Text("English")),
              PopupMenuItem(value: "mr", child: Text("मराठी")),
            ],
            icon: Icon(Icons.language, color: theme.primaryColor),
          ),
        ],
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
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.school,
                      size: 60,
                      color: theme.primaryColor,
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Login Card
                  Card(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            LanguageService.text("school_login"),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          
                          SizedBox(height: 30),
                          
                          TextField(
                            controller: idController,
                            decoration: InputDecoration(
                              labelText: LanguageService.text("unique_id"),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          TextField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: LanguageService.text("password"),
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                          
                          SizedBox(height: 30),
                          
                          isLoading
                              ? CircularProgressIndicator()
                              : SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: loginUser,
                                    style: ElevatedButton.styleFrom(
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: Text(LanguageService.text("login")),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  
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
