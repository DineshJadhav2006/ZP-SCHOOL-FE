import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import 'student_profile_screen.dart';
import 'edit_student_screen.dart';

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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "Roll: ${s["roll_number"] ?? '-'} | ID: ${s["unique_id"] ?? '-'}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) async {
            if (value == 'edit') {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditStudentScreen(student: s),
                ),
              );
              if (result == true) loadStudents();
            } else if (value == 'delete') {
              _confirmDelete(s);
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Class ${widget.standard}"),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => loadStudents(),
              child: Column(
                children: [
                  _buildSearchBar(theme),
                  _buildSummaryInfo(theme),
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              return _studentListItem(filteredStudents[index], theme);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
      color: Colors.white,
      child: TextField(
        controller: searchController,
        onChanged: searchStudent,
        decoration: InputDecoration(
          hintText: "Search students by name or ID...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: theme.primaryColor, size: 20),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSummaryInfo(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.people_outline, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            "${students.length} Students Enrolled",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
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
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade200),
          SizedBox(height: 16),
          Text("No students match your search", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _studentListItem(Map<String, dynamic> s, ThemeData theme) {
    String name = "${s["first_name"]} ${s["last_name"]}".trim();
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Text(
            s['roll_number']?.toString() ?? '?',
            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "ID: ${s["unique_id"] ?? '-'}",
          style: TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade300),
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
                loadStudents();
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
