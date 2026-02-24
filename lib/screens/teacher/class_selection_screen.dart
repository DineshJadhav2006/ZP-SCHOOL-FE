import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/teacher_service.dart';
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
      appBar: AppBar(
        title: Text("Select Your Class"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: theme.primaryColor,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(theme),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: classes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      return _buildClassCard(classes[index], theme);
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
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, color: theme.primaryColor, size: 30),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome,",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                Text(
                  teacherName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                ),
                Text(
                  designation,
                  style: TextStyle(fontSize: 13, color: theme.primaryColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(String className, ThemeData theme) {
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
            BoxShadow(color: theme.primaryColor.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.class_rounded, color: theme.primaryColor, size: 28),
            ),
            SizedBox(height: 16),
            Text(
              className,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            SizedBox(height: 4),
            Text(
              "Standard",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
