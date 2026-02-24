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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadTeachers,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : teachers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {
                            var teacher = teachers[index];
                            String name = "${teacher['first_name']} ${teacher['last_name']}".trim();
                            return _buildTeacherCard(teacher, name, theme);
                          },
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
                  "Faculty Directory",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Total Staff: ${teachers.length}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.person_add_outlined, color: theme.primaryColor),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            "No teachers found",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher, String name, ThemeData theme) {
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
          child: Icon(Icons.person, color: theme.primaryColor),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(teacher['designation'] ?? 'Staff', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            SizedBox(height: 4),
            Row(
              children: [
                _miniTag("ID: ${teacher['unique_id'] ?? '-'}"),
                if (teacher['is_class_teacher'] == true) ...[
                  SizedBox(width: 8),
                  _miniTag("Class: ${teacher['assigned_standard']}", isPrimary: true),
                ],
              ],
            ),
          ],
        ),
        trailing: _buildTeacherActionMenu(teacher),
        onTap: () => _showTeacherDetails(teacher),
      ),
    );
  }

  Widget _miniTag(String text, {bool isPrimary = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.indigo.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10, 
          color: isPrimary ? Colors.indigo : Colors.grey.shade600, 
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTeacherActionMenu(Map<String, dynamic> teacher) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'edit') {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditTeacherScreen(teacher: teacher)),
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
              Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Text('Edit Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Remove Staff', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
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
