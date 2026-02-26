import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class SuperAdminProfileScreen extends StatefulWidget {
  @override
  State<SuperAdminProfileScreen> createState() => _SuperAdminProfileScreenState();
}

class _SuperAdminProfileScreenState extends State<SuperAdminProfileScreen> {
  String userId = "";
  String role = "";
  String firstName = "";
  String lastName = "";
  String phone = "";
  String uniqueId = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    
    String? id = await AuthService.getUserId();
    String? userRole = await AuthService.getRole();
    
    if (id != null) {
      Map<String, dynamic>? userData = await UserService.getUserById(id);
      
      if (userData != null) {
        setState(() {
          userId = id;
          role = userRole ?? "N/A";
          firstName = userData['first_name'] ?? "N/A";
          lastName = userData['last_name'] ?? "N/A";
          phone = userData['phone'] ?? "N/A";
          uniqueId = userData['unique_id'] ?? "N/A";
          isLoading = false;
        });
        return;
      }
    }
    
    setState(() {
      userId = id ?? "N/A";
      role = userRole ?? "N/A";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.primaryColor.withOpacity(0.2),
            child: Icon(Icons.supervisor_account, size: 60, color: theme.primaryColor),
          ),
          SizedBox(height: 16),
          Text("$firstName $lastName", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(uniqueId, style: TextStyle(fontSize: 14, color: Colors.grey)),
          SizedBox(height: 32),
          _profileCard("First Name", firstName, Icons.person),
          _profileCard("Last Name", lastName, Icons.person_outline),
          _profileCard("Phone", phone, Icons.phone),
          _profileCard("Unique ID", uniqueId, Icons.badge),
          _profileCard("Role", role, Icons.admin_panel_settings),
          _profileCard("Access Level", "Full System Access", Icons.security),
          _profileCard("Status", "Active", Icons.check_circle, Colors.green),
          SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: Icon(Icons.settings, color: theme.primaryColor),
              title: Text("Account Settings"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Account Settings - Coming Soon')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.lock, color: theme.primaryColor),
              title: Text("Change Password"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Change Password - Coming Soon')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.help, color: theme.primaryColor),
              title: Text("Help & Support"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Help & Support - Coming Soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(String label, String value, IconData icon, [Color? color]) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.grey),
        title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
