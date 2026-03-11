import 'package:flutter/material.dart';
import '../../utils/common_extensions.dart';
import '../../services/student_service.dart';
import 'edit_student_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    try {
      if (date.contains('T')) {
        return date.split("T")[0];
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
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

    final theme = Theme.of(context);
    final String gender = student!["gender"]?.toString().toLowerCase() ?? "male";
    final Color primaryColor = gender == "female" ? Colors.pink : Colors.blue;
    final String fullName = "${student!["first_name"]} ${student!["middle_name"] ?? ""} ${student!["last_name"]}".trim();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // प्रीमियम हेडर विथ अवतार
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.darken(0.2), primaryColor.lighten(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade100,
                        child: Text(
                          student!["first_name"]?[0]?.toUpperCase() ?? "S",
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_note, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditStudentScreen(student: student!),
                    ),
                  ).then((_) => loadStudent());
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // नाव आणि रोल नंबर कार्ड
                      _buildMainInfoCard(fullName, student!["unique_id"], student!["roll_number"], primaryColor),
                      
                      SizedBox(height: 16),
                      // अकॅडमिक माहिती
                      _buildSectionTitle("Academic Details", Icons.school_outlined, primaryColor),
                      _buildDataSection([
                        _buildInfoRow(Icons.class_outlined, "Standard", student!["standard"] ?? "N/A"),
                        _buildInfoRow(Icons.grid_3x3, "Division", student!["division"] ?? "N/A"),
                        _buildInfoRow(Icons.event_available, "Admission Date", formatDate(student!["admission_date"])),
                        _buildInfoRow(Icons.category_outlined, "Category", student!["category"] ?? "N/A"),
                      ]),

                      SizedBox(height: 16),
                      // वैयक्तिक माहिती
                      _buildSectionTitle("Personal Details", Icons.person_outline, primaryColor),
                      _buildDataSection([
                        _buildInfoRow(Icons.fingerprint, "Aadhar Number", student!["aadhar_number"] ?? "N/A"),
                        _buildInfoRow(gender == "female" ? Icons.female : Icons.male, "Gender", gender.capitalize()),
                        _buildInfoRow(Icons.cake_outlined, "Date of Birth", formatDate(student!["date_of_birth"])),
                      ]),

                      SizedBox(height: 16),
                      // संपर्क आणि पालक
                      _buildSectionTitle("Contact & Parent Details", Icons.contact_phone_outlined, primaryColor),
                      _buildDataSection([
                        _buildInfoRow(Icons.face, "Parent Name", student!["parent_name"] ?? "N/A"),
                        _buildInfoRow(
                          Icons.phone_android, 
                          "Mobile Number", 
                          student!["mobile_number"] ?? "N/A",
                          trailing: IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () => _makePhoneCall(student!["mobile_number"]),
                          ),
                        ),
                        _buildInfoRow(Icons.location_on_outlined, "Address", student!["address"] ?? "N/A"),
                      ]),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard(String name, String? id, dynamic roll, Color accent) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "ID: ${id ?? '-'}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: accent, fontSize: 13),
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Roll: ${roll ?? '-'}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(List<Widget> children) {
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

  Widget _buildInfoRow(IconData icon, String label, String value, {Widget? trailing}) {
    return Padding(
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
    );
  }
}

