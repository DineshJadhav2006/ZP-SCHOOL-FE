import 'package:flutter/material.dart';
import '../../services/client_service.dart';
import 'add_school_screen.dart';
import 'edit_school_screen.dart';
import 'school_details_screen.dart';

class SuperAdminSchoolsScreen extends StatefulWidget {
  final int totalSchools;

  const SuperAdminSchoolsScreen({required this.totalSchools});

  @override
  State<SuperAdminSchoolsScreen> createState() => _SuperAdminSchoolsScreenState();
}

class _SuperAdminSchoolsScreenState extends State<SuperAdminSchoolsScreen> {
  List<dynamic> schools = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSchools();
  }

  Future<void> loadSchools() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final data = await ClientService.getAllClients();
      setState(() {
        schools = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading schools: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load schools. Please try again.';
      });
    }
  }

  Future<void> deleteSchool(String clientId, String schoolName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete School"),
        content: Text("Are you sure you want to delete $schoolName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await ClientService.deleteClient(clientId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('School deleted successfully'), backgroundColor: Colors.green),
        );
        loadSchools();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete school'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(errorMessage!, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: loadSchools,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (schools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No schools found', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadSchools,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: schools.length,
          itemBuilder: (context, index) {
            final school = schools[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.school, color: Colors.white),
                ),
                title: Text(school['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(school['info'] ?? 'No info'),
                trailing: Chip(
                  label: Text(school['code'] ?? '', style: TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Phone', school['phone'] ?? 'N/A', Icons.phone),
                        _infoRow('Code', school['code'] ?? 'N/A', Icons.qr_code),
                        _infoRow('Created', school['created_at']?.substring(0, 10) ?? 'N/A', Icons.calendar_today),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SchoolDetailsScreen(school: school),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.admin_panel_settings),
                                label: Text('Manage Admins'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  bool? result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditSchoolScreen(school: school),
                                    ),
                                  );
                                  if (result == true) loadSchools();
                                },
                                icon: Icon(Icons.edit),
                                label: Text('Edit'),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => deleteSchool(school['id'], school['name']),
                                icon: Icon(Icons.delete, color: Colors.red),
                                label: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddSchoolScreen()),
          );
          if (result == true) loadSchools();
        },
        icon: Icon(Icons.add),
        label: Text('Add School'),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(value, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
