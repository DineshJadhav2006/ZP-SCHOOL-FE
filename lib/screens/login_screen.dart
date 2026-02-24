import 'package:flutter/material.dart';
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

  void loginUser() async {
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
          print("Error fetching admin details: $e");
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
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService.text("school_login")),
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
            icon: Icon(Icons.language),
          ),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LanguageService.text("school_login"),
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 30),

                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: LanguageService.text("unique_id"),
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: LanguageService.text("password"),
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 25),

                isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loginUser,
                          child: Text(
                            LanguageService.text("login"),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
