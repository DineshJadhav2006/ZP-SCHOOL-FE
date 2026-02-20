import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import 'edit_student_screen.dart';

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
    var data = await StudentService.getStudentById(widget.studentId);

    setState(() {
      student = data;
      isLoading = false;
    });
  }

  Widget infoTile(String label, dynamic value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        value == null || value.toString().isEmpty ? "-" : value.toString(),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  String formatDate(String? date) {
    if (date == null) return "-";
    return date.split("T")[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Profile"),
        actions: [
          if (!isLoading && student != null)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditStudentScreen(student: student!),
                  ),
                ).then((_) => loadStudent());
              },
            )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 15),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, size: 45, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${student!["first_name"]} ${student!["middle_name"] ?? ""} ${student!["last_name"]}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Class ${student!["standard"]} - ${student!["division"]}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 15),
                  Divider(),
                  infoTile("Roll Number", student!["roll_number"]),
                  infoTile("Gender", student!["gender"]),
                  infoTile("Date of Birth", formatDate(student!["date_of_birth"])),
                  infoTile("Aadhaar Number", student!["aadhar_number"]),
                  infoTile("Parent Name", student!["parent_name"]),
                  infoTile("Mobile", student!["mobile_number"]),
                  infoTile("User Phone", student!["user"]?["phone"]),
                  Divider(),
                  infoTile("Standard", student!["standard"]),
                  infoTile("Division", student!["division"]),
                  infoTile("Category", student!["category"]),
                  infoTile("Admission Date", formatDate(student!["admission_date"])),
                  Divider(),
                  infoTile("Address", student!["address"]),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
