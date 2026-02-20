import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import 'student_profile_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String standard;

  StudentListScreen({required this.standard});

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List students = [];
  List filteredStudents = [];
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  void loadStudents() async {
    var data = await StudentService.getStudents(widget.standard);

    setState(() {
      students = data;
      filteredStudents = data;
      isLoading = false;
    });
  }

  void searchStudent(String value) {
    setState(() {
      filteredStudents = students.where((s) {
        String name = "${s["first_name"]} ${s["middle_name"] ?? ''} ${s["last_name"]}".toLowerCase();
        String uniqueId = (s["unique_id"] ?? "").toLowerCase();
        return name.contains(value.toLowerCase()) || uniqueId.contains(value.toLowerCase());
      }).toList();
    });
  }

  Widget studentCard(Map<String, dynamic> s) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(
          "${s["first_name"]} ${s["middle_name"] ?? ''} ${s["last_name"]}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Roll: ${s["roll_number"] ?? '-'} | ID: ${s["unique_id"] ?? '-'}"),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentProfileScreen(studentId: s["id"]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Class ${widget.standard} Students"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                loadStudents();
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Total Students: ${students.length}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: searchController,
                      onChanged: searchStudent,
                      decoration: InputDecoration(
                        hintText: "Search Student",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? Center(child: Text("No Students Found"))
                        : ListView.builder(
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              return studentCard(filteredStudents[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
