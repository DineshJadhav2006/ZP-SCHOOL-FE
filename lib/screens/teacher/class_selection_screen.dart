import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/teacher_service.dart';
import '../../localization/language_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'class_dashboard_screen.dart';

class ClassSelectionScreen extends StatefulWidget {
  @override
  _ClassSelectionScreenState createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  String teacherName = "";
  String designation = "";
  bool isLoading = true;

  final List<String> classes = [
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th"
  ];

  @override
  void initState() {
    super.initState();
    loadTeacher();
  }

  void loadTeacher() async {
    var teacher = await TeacherService.getTeacher();

    if (teacher != null) {
      setState(() {
        teacherName = "${teacher["first_name"]} ${teacher["last_name"]}";
        designation = teacher["designation"] ?? "";
        isLoading = false;
      });
    }
  }

  Widget classCard(String className) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("teacher_name", teacherName);
        await prefs.setString("class_name", className);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassDashboardScreen(
              className: className,
              teacherName: teacherName,
              designation: designation,
            ),
          ),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              className,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(theme).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    itemCount: classes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      return _buildClassCard(classes[index], theme, index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
        boxShadow: [
          BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                LanguageService.text("select_class") ?? "Select Your Class",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.9)),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: Colors.white, size: 36),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LanguageService.text("welcome") ?? "Welcome,",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        Text(
                          teacherName,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                        ),
                        SizedBox(height: 2),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            designation,
                            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(String className, ThemeData theme, int index) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("teacher_name", teacherName);
        await prefs.setString("class_name", className);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassDashboardScreen(
              className: className,
              teacherName: teacherName,
              designation: designation,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: theme.primaryColor.withValues(alpha: 0.08), blurRadius: 15, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor.withValues(alpha: 0.1), theme.primaryColor.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.meeting_room_rounded, color: theme.primaryColor, size: 32),
            ),
            SizedBox(height: 12),
            Text(
              className,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.grey.shade800, letterSpacing: -1.0),
            ),
            Text(
              LanguageService.text("standard") ?? "Standard",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms, duration: 400.ms).scaleXY(begin: 0.9, end: 1.0, duration: 400.ms, curve: Curves.easeOutBack);
  }
}
