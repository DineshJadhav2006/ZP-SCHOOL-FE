import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          backgroundColor: color.withValues(alpha: 0.2),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : teacher == null
              ? Center(child: Text("Failed to load profile"))
              : RefreshIndicator(
                  onRefresh: loadTeacherProfile,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.primaryColor, Colors.indigo.shade800],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildPremiumHeader(theme),
                            Transform.translate(
                              offset: Offset(0, -30),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 30),
                                    _buildSectionHeader("Personal Details"),
                                    _buildInfoGrid([
                                      _premiumTile("Phone", teacher!["mobile_number"] ?? "-", Icons.phone_android_rounded, Colors.green),
                                      _premiumTile("Gender", teacher!["gender"] ?? "-", Icons.person_search_rounded, Colors.pink),
                                      _premiumTile("Date of Birth", formatDate(teacher!["date_of_birth"]), Icons.cake_rounded, Colors.orange, isLast: true),
                                    ]),
                                    SizedBox(height: 25),
                                    _buildSectionHeader("Professional Hub"),
                                    _buildInfoGrid([
                                      _premiumTile("Qualification", teacher!["qualification"] ?? "-", Icons.school_rounded, Colors.blue),
                                      _premiumTile("Joining Date", formatDate(teacher!["joining_date"]), Icons.calendar_month_rounded, Colors.indigo.shade700, isLast: true),
                                    ]),
                                    SizedBox(height: 40),
                                    _buildLogoutButton(context, theme),
                                    SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPremiumHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.9),
            Colors.indigo.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Icon(Icons.person_rounded, size: 60, color: theme.primaryColor),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            SizedBox(height: 16),
            Text(
              "${teacher!["first_name"]} ${teacher!["last_name"]}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
            SizedBox(height: 4),
            Text(
              teacher!["designation"] ?? "Teacher",
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
            SizedBox(height: 16),
            if (teacher!["unique_id"] != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "ID: ${teacher!["unique_id"]}",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ).animate().fadeIn(duration: 600.ms),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1);
  }

  Widget _buildInfoGrid(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _premiumTile(String label, String value, IconData icon, Color color, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              value.isEmpty ? "-" : value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 70, endIndent: 20, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () async {
          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Logout"),
              content: Text("Are you sure you want to logout?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Logout", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await AuthService.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: Icon(Icons.logout_rounded, color: Colors.red),
        label: Text("Logout Securely", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}
