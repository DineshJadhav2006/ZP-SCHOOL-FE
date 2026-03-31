import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? studentData;
  final String? studentName;
  final String? studentClass;

  const ProfileScreen({
    required this.studentData,
    required this.studentName,
    required this.studentClass,
  });

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  Widget row(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Flexible(
            child: Text(
              value == null || value.toString().isEmpty
                  ? "-"
                  : value.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // This container ensures the top overscroll (bounce) has the same indigo color
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
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
                        _buildSectionHeader("Academic Hub"),
                        _buildInfoGrid([
                          _premiumTile("Unique ID", studentData?['unique_id'] ?? "-", Icons.fingerprint_rounded, Colors.indigo),
                          _premiumTile("Student ID", studentData?['student_id']?.toString() ?? "-", Icons.badge_rounded, Colors.teal),
                          _premiumTile("G.R. Number", studentData?['general_register_no']?.toString() ?? "-", Icons.numbers_rounded, Colors.deepOrange),
                          _premiumTile("Roll Number", studentData?['roll_number']?.toString() ?? "-", Icons.format_list_numbered_rounded, Colors.blue),
                          _premiumTile("Admission Date", formatDate(studentData?['admission_date']), Icons.calendar_month_rounded, Colors.amber.shade700, isLast: true),
                        ]),
                        SizedBox(height: 25),
                        _buildSectionHeader("Personal Details"),
                        _buildInfoGrid([
                          _premiumTile("Gender", studentData?['gender'] ?? "-", Icons.person_search_rounded, Colors.pink),
                          _premiumTile("Date of Birth", formatDate(studentData?['date_of_birth']), Icons.cake_rounded, Colors.orange),
                          _premiumTile("Category", studentData?['category'] ?? "-", Icons.category_rounded, Colors.deepPurple),
                          _premiumTile("Aadhar Number", studentData?['aadhar_number'] ?? "-", Icons.badge_rounded, Colors.cyan.shade700),
                        ]),
                        SizedBox(height: 25),
                        _buildSectionHeader("Contact Info"),
                        _buildInfoGrid([
                          _premiumTile("Mobile", studentData?['mobile_number'] ?? "-", Icons.phone_android_rounded, Colors.green),
                          _premiumTile("Father/Guardian", studentData?['parent_name'] ?? "-", Icons.family_restroom_rounded, Colors.brown),
                          _premiumTile("Mother's Name", studentData?['mothers_name'] ?? "-", Icons.person_rounded, Colors.pinkAccent),
                          _premiumTile("Residential Address", studentData?['address'] ?? "-", Icons.map_rounded, Colors.redAccent, isLast: true),
                        ]),
                        SizedBox(height: 40),
                        _buildActionButtons(context, theme),
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
            ),
            SizedBox(height: 16),
            Text(
              studentName ?? "Student",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
            ),
            SizedBox(height: 4),
            Text(
              "Standard: $studentClass",
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 24),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(studentData?['roll_number'] ?? "-", "Roll No"),
          Container(width: 1, height: 24, color: Colors.white.withOpacity(0.2)),
          _statItem("Active", "Status"),
          Container(width: 1, height: 24, color: Colors.white.withOpacity(0.2)),
          _statItem(studentClass ?? "-", "Class"),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
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
    );
  }

  Widget _buildInfoGrid(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
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

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {}, // Placeholder for download ID card
            icon: Icon(Icons.file_download_outlined, color: Colors.white),
            label: Text("Download ID Card", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
              shadowColor: theme.primaryColor.withOpacity(0.4),
            ),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
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
                      MaterialPageRoute(builder: (context) => LoginScreen()),
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
        ),
      ],
    );
  }
}
