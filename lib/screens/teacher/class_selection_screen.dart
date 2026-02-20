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
    return Scaffold(
      appBar: AppBar(title: Text("Select Class")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: EdgeInsets.all(12),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(teacherName),
                    subtitle: Text(designation),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      itemCount: classes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        return classCard(classes[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
