import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'add_admin_screen.dart';
import 'edit_admin_screen.dart';

class SchoolDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> school;

  const SchoolDetailsScreen({required this.school});

  @override
  State<SchoolDetailsScreen> createState() => _SchoolDetailsScreenState();
}

class _SchoolDetailsScreenState extends State<SchoolDetailsScreen> {
  List<dynamic> admins = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadAdmins();
  }

  Future<void> loadAdmins() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await AdminService.getAdminsByClient(widget.school['id']);
      setState(() {
        admins = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading admins: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load admins';
      });
    }
  }

  Future<void> deleteAdmin(String adminId, String adminName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Admin"),
        content: Text("Are you sure you want to delete $adminName?"),
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
      bool success = await AdminService.deleteAdmin(widget.school['id'], adminId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin deleted successfully'), backgroundColor: Colors.green),
        );
        loadAdmins();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete admin'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.school['name'] ?? 'School Details'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.school['name'] ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _infoRow(Icons.qr_code, 'Code', widget.school['code'] ?? 'N/A'),
                _infoRow(Icons.phone, 'Phone', widget.school['phone'] ?? 'N/A'),
                _infoRow(Icons.info, 'Info', widget.school['info'] ?? 'N/A'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Admins (${admins.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () async {
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddAdminScreen(clientId: widget.school['id']),
                      ),
                    );
                    if (result == true) loadAdmins();
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Admin'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : admins.isEmpty
                        ? Center(child: Text('No admins found'))
                        : RefreshIndicator(
                            onRefresh: loadAdmins,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: admins.length,
                              itemBuilder: (context, index) {
                                final admin = admins[index];
                                final user = admin['user'];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        (admin['first_name']?[0] ?? 'A').toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      '${admin['first_name']} ${admin['last_name']}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(admin['designation'] ?? 'N/A', overflow: TextOverflow.ellipsis),
                                        Text(admin['mobile_number'] ?? 'N/A', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                    trailing: PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 20, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          bool? result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditAdminScreen(
                                                clientId: widget.school['id'],
                                                admin: admin,
                                              ),
                                            ),
                                          );
                                          if (result == true) loadAdmins();
                                        } else if (value == 'delete') {
                                          deleteAdmin(admin['id'], '${admin['first_name']} ${admin['last_name']}');
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
