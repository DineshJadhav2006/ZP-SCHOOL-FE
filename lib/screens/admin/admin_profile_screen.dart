import 'package:flutter/material.dart';
import '../../services/teacher_service.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'package:intl/intl.dart';

class AdminProfileScreen extends StatefulWidget {
  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  Map<String, dynamic>? admin;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAdminProfile();
  }

  Future<void> loadAdminProfile() async {
    var data = await TeacherService.getAdmin();
    setState(() {
      admin = data;
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
          : admin == null
          ? Center(child: Text("Failed to load profile"))
          : RefreshIndicator(
              onRefresh: () async {
                await loadAdminProfile();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header Section with Gradient
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade700,
                            Colors.purple.shade400,
                          ],
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
                                    backgroundColor: Colors.purple.shade100,
                                    child: Icon(
                                      Icons.admin_panel_settings,
                                      size: 60,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                            SizedBox(height: 16),
                            Text(
                              "${admin!["first_name"]} ${admin!["middle_name"] ?? ""} ${admin!["last_name"]}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              admin!["designation"] ?? "Administrator",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: 8),
                            if (admin!["unique_id"] != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "ID: ${admin!["unique_id"]}",
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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

                    infoCard(
                      "Mobile Number",
                      admin!["mobile_number"] ?? "-",
                      Icons.phone,
                      Colors.green,
                    ),
                    infoCard(
                      "Gender",
                      admin!["gender"] ?? "-",
                      Icons.person_outline,
                      Colors.pink,
                    ),
                    infoCard(
                      "Date of Birth",
                      formatDate(admin!["date_of_birth"]),
                      Icons.cake,
                      Colors.orange,
                    ),

                    SizedBox(height: 16),

                    // Professional Information
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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

                    infoCard(
                      "Qualification",
                      admin!["qualification"] ?? "-",
                      Icons.school,
                      Colors.blue,
                    ),
                    infoCard(
                      "Experience",
                      "${admin!["experience"] ?? 0} years",
                      Icons.work,
                      Colors.teal,
                    ),
                    infoCard(
                      "Joined Date",
                      formatDate(admin!["created_on"]),
                      Icons.calendar_today,
                      Colors.indigo,
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
