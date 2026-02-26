import 'package:flutter/material.dart';
import '../../services/client_service.dart';
import '../admin/admin_students_screen.dart';
import '../admin/admin_teachers_screen.dart';
import '../admin/admin_reports_screen.dart';

class SchoolSelectionScreen extends StatefulWidget {
  final String type; // 'students', 'teachers', or 'reports'

  const SchoolSelectionScreen({required this.type});

  @override
  State<SchoolSelectionScreen> createState() => _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState extends State<SchoolSelectionScreen> {
  List<dynamic> schools = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSchools();
  }

  Future<void> loadSchools() async {
    setState(() => isLoading = true);
    try {
      final data = await ClientService.getAllClients();
      setState(() {
        schools = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select School - ${widget.type == 'students' ? 'Students' : widget.type == 'teachers' ? 'Teachers' : 'Reports'}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : schools.isEmpty
              ? Center(child: Text('No schools found'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: schools.length,
                  itemBuilder: (context, index) {
                    final school = schools[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.school, color: Colors.white),
                        ),
                        title: Text(school['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(school['code'] ?? ''),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (widget.type == 'students') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminStudentsScreen(totalStudents: 0),
                              ),
                            );
                          } else if (widget.type == 'teachers') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminTeachersScreen(totalTeachers: 0),
                              ),
                            );
                          } else if (widget.type == 'reports') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminReportsScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
