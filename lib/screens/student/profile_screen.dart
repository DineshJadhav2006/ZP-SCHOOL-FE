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
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Default Profile Icon (No Network Image)
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.blue,
            ),
          ),
        ),

        SizedBox(height: 12),

        Center(
          child: Text(
            studentName ?? "",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        Center(
          child: Text(
            "Class: $studentClass",
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),

        SizedBox(height: 20),

        if (studentData != null)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  row("Unique ID", studentData!['unique_id']),
                  row("Roll No", studentData!['roll_number']),
                  row("Standard", studentData!['standard']),
                  // Division removed
                  row("Gender", studentData!['gender']),
                  row("Date of Birth",
                      formatDate(studentData!['date_of_birth'])),
                  row("Admission Date",
                      formatDate(studentData!['admission_date'])),
                  row("Category", studentData!['category']),
                  row("Aadhar No", studentData!['aadhar_number']),
                  row("Mobile", studentData!['mobile_number']),
                  row("Parent Name", studentData!['parent_name']),
                  row("Address", studentData!['address']),
                ],
              ),
            ),
          ),

        SizedBox(height: 30),

        // Logout Button
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: Icon(Icons.logout),
            label: Text("Logout"),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }
}