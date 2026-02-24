import 'package:flutter/material.dart';
import '../../services/teacher_service.dart';
import 'add_teacher_screen.dart';
import 'edit_teacher_screen.dart';
import 'package:intl/intl.dart';

class AdminTeachersScreen extends StatefulWidget {
  final int totalTeachers;

  const AdminTeachersScreen({required this.totalTeachers});

  @override
  _AdminTeachersScreenState createState() => _AdminTeachersScreenState();
}

class _AdminTeachersScreenState extends State<AdminTeachersScreen> {
  List<dynamic> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    setState(() => isLoading = true);
    var data = await TeacherService.getAllTeachers();
    setState(() {
      teachers = data;
      isLoading = false;
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.green.shade50,
          child: Row(
            children: [
              Icon(Icons.school, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Teachers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.person_add, color: Colors.green),
                onPressed: () async {
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddTeacherScreen()),
                  );
                  if (result == true) loadTeachers();
                },
                tooltip: "Add Teacher",
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadTeachers,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : teachers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("No teachers found"),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: teachers.length,
                        itemBuilder: (context, index) {
                          var teacher = teachers[index];
                          String name =
                              "${teacher['first_name']} ${teacher['middle_name'] ?? ''} ${teacher['last_name']}"
                                  .trim();
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Icon(Icons.person, color: Colors.green),
                              ),
                              title: Text(
                                name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(teacher['designation'] ?? 'Teacher'),
                                  Text("ID: ${teacher['unique_id'] ?? '-'}"),
                                  if (teacher['is_class_teacher'] == true)
                                    Text(
                                      "Class: ${teacher['assigned_standard']} - ${teacher['assigned_division']}",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    var result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditTeacherScreen(teacher: teacher),
                                      ),
                                    );
                                    if (result == true) loadTeachers();
                                  } else if (value == 'delete') {
                                    _confirmDelete(teacher);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue, size: 20),
                                        SizedBox(width: 12),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red, size: 20),
                                        SizedBox(width: 12),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showTeacherDetails(teacher);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  void _showTeacherDetails(Map<String, dynamic> teacher) {
    String name =
        "${teacher['first_name']} ${teacher['middle_name'] ?? ''} ${teacher['last_name']}"
            .trim();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("ID", teacher['unique_id'] ?? '-'),
              _detailRow("Mobile", teacher['mobile_number'] ?? '-'),
              _detailRow("Gender", teacher['gender'] ?? '-'),
              _detailRow("Designation", teacher['designation'] ?? '-'),
              _detailRow("Qualification", teacher['qualification'] ?? '-'),
              _detailRow("Experience", "${teacher['experience_years'] ?? 0} years"),
              _detailRow("Joining Date", formatDate(teacher['joining_date'])),
              if (teacher['is_class_teacher'] == true)
                _detailRow(
                  "Class Teacher",
                  "${teacher['assigned_standard']} - ${teacher['assigned_division']}",
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> teacher) {
    String name = "${teacher['first_name']} ${teacher['last_name']}";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Teacher"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await TeacherService.deleteTeacher(teacher['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Teacher deleted successfully")),
                );
                loadTeachers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete teacher"), backgroundColor: Colors.red),
                );
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
