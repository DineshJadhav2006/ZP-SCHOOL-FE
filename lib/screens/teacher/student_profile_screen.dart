import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/common_extensions.dart';
import '../../services/student_service.dart';
import 'edit_student_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class StudentProfileScreen extends StatefulWidget {
  final String studentId;

  StudentProfileScreen({required this.studentId});

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  Map<String, dynamic>? student;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  void loadStudent() async {
    setState(() => isLoading = true);
    var data = await StudentService.getStudentById(widget.studentId);

    setState(() {
      student = data;
      isLoading = false;
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      if (dateStr.contains('T')) {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copied to clipboard"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(child: Text("Student not found")),
      );
    }

    final String firstName = student!["first_name"] ?? "";
    final String lastName = student!["last_name"] ?? "";
    final String fullName = "$firstName ${student!["middle_name"] ?? ''} $lastName".trim();
    final primaryColor = Colors.indigo;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Student Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        physics: BouncingScrollPhysics(),
        children: [
          // Profile Header - Matches Admin Style Exactly
          Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  fullName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
                SizedBox(height: 6),
                Text(
                  "Class ${student!['standard']} - ${student!['division'] ?? 'A'}",
                  style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 25),
              ],
            ),
          ),

          // Action Buttons - Matches Admin Style Exactly (Fixes Overflow)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                icon: Icons.call_outlined,
                label: "Call Parent",
                color: Colors.green,
                onTap: () => _makePhoneCall(student!['mobile_number']),
              ),
              _actionButton(
                icon: Icons.edit_outlined,
                label: "Edit",
                color: Colors.blue,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditStudentScreen(student: student!)),
                  );
                  loadStudent();
                },
              ),
            ],
          ),
          SizedBox(height: 30),

          // Academic Information
          _sectionTitle("Academic Information", Icons.school_outlined),
          _infoCard([
            _infoRow(Icons.fingerprint, "Student ID", student!['unique_id'] ?? '-', 
              onTap: () => _copyToClipboard(student!['unique_id'] ?? "", "Student ID")),
            _infoRow(Icons.tag, "Roll Number", student!['roll_number']?.toString() ?? '-'),
            _infoRow(Icons.calendar_today_outlined, "Admission Date", _formatDate(student!['admission_date'])),
            _infoRow(Icons.category_outlined, "Category", student!['category'] ?? 'General'),
          ]),

          SizedBox(height: 20),
          // Personal Information
          _sectionTitle("Personal Information", Icons.person_outline),
          _infoCard([
            _infoRow(Icons.credit_card_outlined, "Aadhar Number", student!['aadhar_number'] ?? '-', 
              onTap: () => _copyToClipboard(student!['aadhar_number'] ?? "", "Aadhar Number")),
            _infoRow(student!['gender']?.toString().toLowerCase() == 'female' ? Icons.female : Icons.male, 
              "Gender", student!['gender']?.toString().capitalize() ?? 'Not Specified'),
            _infoRow(Icons.cake_outlined, "Date of Birth", _formatDate(student!['date_of_birth'])),
          ]),

          SizedBox(height: 20),
          // Parent & Contact Details
          _sectionTitle("Parent & Contact Details", Icons.contact_phone_outlined),
          _infoCard([
            _infoRow(Icons.face_outlined, "Parent Name", student!['parent_name'] ?? '-'),
            _infoRow(Icons.phone_android_outlined, "Mobile", student!['mobile_number'] ?? '-', 
              trailing: Icon(Icons.call, color: Colors.green, size: 18),
              onTap: () => _makePhoneCall(student!['mobile_number'])),
            _infoRow(Icons.location_on_outlined, "Address", student!['address'] ?? '-'),
          ]),

          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: Colors.grey.shade600),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

