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
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildProfileCard(theme),
            SizedBox(height: 24),
            if (studentData != null) _buildDetailsCard(theme),
            SizedBox(height: 32),
            _buildLogoutButton(context),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, size: 45, color: theme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            studentName ?? "Student",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          SizedBox(height: 6),
          _infoTag(Icons.school, "Class: $studentClass", theme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Academic & Personal Details", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            SizedBox(height: 16),
            _row("Unique ID", studentData!['unique_id']),
            _row("Roll Number", studentData!['roll_number']),
            _row("Gender", studentData!['gender']),
            _row("Date of Birth", formatDate(studentData!['date_of_birth'])),
            _row("Admission Date", formatDate(studentData!['admission_date'])),
            _row("Category", studentData!['category']),
            _row("Aadhar No", studentData!['aadhar_number']),
            _row("Mobile", studentData!['mobile_number']),
            _row("Parent Name", studentData!['parent_name']),
            _row("Address", studentData!['address']),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value?.toString() == null || value.toString().isEmpty ? "-" : value.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTag(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withOpacity(0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: Icon(Icons.logout),
        label: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          await AuthService.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        },
      ),
    );
  }
}