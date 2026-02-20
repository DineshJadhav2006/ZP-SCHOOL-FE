import 'package:flutter/material.dart';
import '../../services/teacher_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import '../login_screen.dart';

class TeacherProfileScreen extends StatefulWidget {
  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  Map<String, dynamic>? teacher;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeacherProfile();
  }

  Future<void> loadTeacherProfile() async {
    var data = await TeacherService.getTeacher();
    setState(() {
      teacher = data;
      isLoading = false;
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return "-";
    }
  }

  Widget infoCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : teacher == null
              ? Center(child: Text("Failed to load profile"))
              : RefreshIndicator(
                  onRefresh: loadTeacherProfile,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header Section
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade700, Colors.blue.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: SafeArea(
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "${teacher!["first_name"]} ${teacher!["middle_name"] ?? ""} ${teacher!["last_name"]}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  teacher!["designation"] ?? "Teacher",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                SizedBox(height: 8),
                                if (teacher!["unique_id"] != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "ID: ${teacher!["unique_id"]}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Personal Information
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),

                        infoCard("Mobile Number", teacher!["mobile_number"] ?? "-", 
                            Icons.phone, Colors.green),
                        infoCard("Gender", teacher!["gender"] ?? "-", 
                            Icons.person_outline, Colors.purple),
                        infoCard("Date of Birth", formatDate(teacher!["date_of_birth"]), 
                            Icons.cake, Colors.pink),

                        SizedBox(height: 16),

                        // Professional Information
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Professional Information",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),

                        infoCard("Qualification", teacher!["qualification"] ?? "-", 
                            Icons.school, Colors.orange),
                        infoCard("Experience", "${teacher!["experience_years"] ?? 0} years", 
                            Icons.work, Colors.teal),
                        infoCard("Joining Date", formatDate(teacher!["joining_date"]), 
                            Icons.calendar_today, Colors.blue),
                        
                        if (teacher!["is_class_teacher"] == true)
                          infoCard(
                            "Class Teacher", 
                            "${teacher!["assigned_standard"]} - ${teacher!["assigned_division"]}", 
                            Icons.class_, 
                            Colors.indigo
                          ),

                        SizedBox(height: 24),

                        // Logout Button
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await AuthService.logout();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => LoginScreen()),
                                  (route) => false,
                                );
                              },
                              icon: Icon(Icons.logout),
                              label: Text("Logout", style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }
}
