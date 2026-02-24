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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => loadClassData(selectedClass!),
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        "Total",
                                        totalStudents.toString(),
                                        theme.primaryColor,
                                        Icons.people_outline,
                                        () {},
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        "Present",
                                        todayPresent.toString(),
                                        Colors.green,
                                        Icons.check_circle_outline,
                                        () => _showFilteredStudents("Present"),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        "Absent",
                                        todayAbsent.toString(),
                                        Colors.red,
                                        Icons.highlight_off,
                                        () => _showFilteredStudents("Absent"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    var student = students[index];
                                    String name = "${student['first_name']} ${student['last_name']}".trim();
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4)),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                                          child: Text(
                                            student['roll_number']?.toString() ?? '?',
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          name,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              _miniTag("ID: ${student['unique_id'] ?? '-'}"),
                                              SizedBox(width: 8),
                                              _miniTag("Class: ${student['standard'] ?? '-'}"),
                                            ],
                                          ),
                                        ),
                                        trailing: _buildStudentActionMenu(student),
                                        onTap: () => _showStudentDetails(student),
                                      ),
                                    );
                                  },
                                  childCount: students.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school, color: theme.primaryColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Student Directory",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Managing Class $selectedClass",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showClassSelector,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text("Change", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    Icon(Icons.unfold_more, color: theme.primaryColor, size: 16),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.person_add_outlined, color: theme.primaryColor),
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddStudentScreen(standard: selectedClass!)),
              );
              if (result == true) loadClassData(selectedClass!);
            },
            tooltip: "Add Student",
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            "No students found in $selectedClass",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentActionMenu(Map<String, dynamic> student) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'edit') {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditStudentScreen(student: student)),
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
              Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Text('Edit Info'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Delete Student', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
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
