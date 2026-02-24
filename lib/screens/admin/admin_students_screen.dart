import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../teacher/add_student_screen.dart';
import 'edit_student_screen.dart';
import 'package:intl/intl.dart';

class AdminStudentsScreen extends StatefulWidget {
  final int totalStudents;

  const AdminStudentsScreen({required this.totalStudents});

  @override
  _AdminStudentsScreenState createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  String? selectedClass = "1st";
  List<dynamic> students = [];
  List<dynamic> attendanceList = [];
  bool isLoading = false;
  int totalStudents = 0;
  int todayPresent = 0;
  int todayAbsent = 0;

  final List<String> classes = [
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th"
  ];

  @override
  void initState() {
    super.initState();
    loadClassData(selectedClass!);
  }

  Future<void> loadClassData(String className) async {
    await loadStudents(className);
    await loadTodayAttendance(className);
  }

  Future<void> loadStudents(String className) async {
    setState(() => isLoading = true);
    var data = await StudentService.getStudents(className);
    setState(() {
      students = data;
      totalStudents = data.length;
      isLoading = false;
    });
  }

  Future<void> loadTodayAttendance(String className) async {
    try {
      String? clientId = await AuthService.getClientId();
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      var result = await AttendanceService.getAttendance(
        clientId: clientId!,
        standard: className,
        division: "A",
        date: today,
      );

      setState(() {
        todayPresent = result['present'] ?? 0;
        todayAbsent = result['absent'] ?? 0;
        attendanceList = result['list'] ?? [];
      });
    } catch (e) {
      print("Error loading attendance: $e");
      setState(() {
        todayPresent = 0;
        todayAbsent = 0;
        attendanceList = [];
      });
    }
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
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.class_, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Class: $selectedClass",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.person_add, color: Colors.blue),
                onPressed: () async {
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddStudentScreen(standard: selectedClass!),
                    ),
                  );
                  if (result == true) loadClassData(selectedClass!);
                },
                tooltip: "Add Student",
              ),
              ElevatedButton.icon(
                onPressed: _showClassSelector,
                icon: Icon(Icons.swap_horiz, size: 20),
                label: Text("Switch"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No students found in $selectedClass",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    "Total",
                                    totalStudents.toString(),
                                    Colors.blue,
                                    Icons.people,
                                    () {},
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    "Present",
                                    todayPresent.toString(),
                                    Colors.green,
                                    Icons.check_circle,
                                    () => _showFilteredStudents("Present"),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    "Absent",
                                    todayAbsent.toString(),
                                    Colors.red,
                                    Icons.cancel,
                                    () => _showFilteredStudents("Absent"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              var student = students[index];
                              String name =
                                  "${student['first_name']} ${student['middle_name'] ?? ''} ${student['last_name']}"
                                      .trim();
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      student['roll_number']?.toString() ?? '?',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                          "ID: ${student['unique_id'] ?? '-'}"),
                                      Text(
                                          "Class: ${student['standard'] ?? '-'}"),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        var result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditStudentScreen(student: student),
                                          ),
                                        );
                                        if (result == true) loadClassData(selectedClass!);
                                      } else if (value == 'delete') {
                                        _confirmDelete(student);
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
                                    _showStudentDetails(student);
                                  },
                                ),
                              );
                            },
                            childCount: students.length,
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          height: 100,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilteredStudents(String status) {
    var filtered = attendanceList.where((att) => att.status == status).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$status Students - $selectedClass"),
        content: Container(
          width: double.maxFinite,
          child: filtered.isEmpty
              ? Center(child: Text("No $status students today"))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    var att = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: status == "Present"
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          status == "Present" ? Icons.check : Icons.close,
                          color: status == "Present" ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(att.student.fullName),
                      subtitle: Text("Roll: ${att.student.rollNumber ?? '-'}"),
                    );
                  },
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

  void _showClassSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Class"),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: classes.length,
            itemBuilder: (context, index) {
              String className = classes[index];
              bool isSelected = className == selectedClass;
              return ListTile(
                leading: Icon(
                  Icons.class_,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  className,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => selectedClass = className);
                  loadClassData(className);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    String name =
        "${student['first_name']} ${student['middle_name'] ?? ''} ${student['last_name']}"
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
              _detailRow("Roll No", student['roll_number']?.toString() ?? '-'),
              _detailRow("Unique ID", student['unique_id'] ?? '-'),
              _detailRow("Class", student['standard'] ?? '-'),
              _detailRow("Gender", student['gender'] ?? '-'),
              _detailRow("Date of Birth", formatDate(student['date_of_birth'])),
              _detailRow("Mobile", student['mobile_number'] ?? '-'),
              _detailRow("Parent Name", student['parent_name'] ?? '-'),
              _detailRow("Category", student['category'] ?? '-'),
              _detailRow("Aadhar", student['aadhar_number'] ?? '-'),
              _detailRow("Address", student['address'] ?? '-'),
              _detailRow(
                  "Admission Date", formatDate(student['admission_date'])),
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

  void _confirmDelete(Map<String, dynamic> student) {
    String name = "${student['first_name']} ${student['last_name']}";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Student"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await StudentService.deleteStudent(student['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Student deleted successfully")),
                );
                loadClassData(selectedClass!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete student"), backgroundColor: Colors.red),
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
