import 'package:flutter/material.dart';
import '../../services/teacher_service.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'package:intl/intl.dart';

class AdminProfileScreen extends StatefulWidget {
  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  Map<String, dynamic>? admin;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAdminProfile();
  }

  Future<void> loadAdminProfile() async {
    var data = await TeacherService.getAdmin();
    setState(() {
      admin = data;
      isLoading = false;
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return "-";
    }
  }

  Widget infoCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : admin == null
          ? Center(child: Text("Failed to load profile"))
          : RefreshIndicator(
              onRefresh: () async => loadAdminProfile(),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(theme),
                    SizedBox(height: 24),
                    _buildSectionHeader("Personal Information"),
                    _buildInfoGrid([
                      _infoTile("Phone", admin!["mobile_number"] ?? "-", Icons.phone_outlined, Colors.green),
                      _infoTile("Gender", admin!["gender"] ?? "-", Icons.person_outline, Colors.pink),
                      _infoTile("Date of Birth", formatDate(admin!["date_of_birth"]), Icons.cake_outlined, Colors.orange),
                    ]),
                    SizedBox(height: 24),
                    _buildSectionHeader("Professional Information"),
                    _buildInfoGrid([
                      _infoTile("Qualification", admin!["qualification"] ?? "-", Icons.school_outlined, Colors.blue),
                      _infoTile("Experience", "${admin!["experience"] ?? 0} years", Icons.work_outline, Colors.teal),
                      _infoTile("Joined Date", formatDate(admin!["created_on"]), Icons.calendar_today_outlined, Colors.indigo),
                    ]),
                    SizedBox(height: 40),
                    _buildLogoutButton(context, theme),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Icon(Icons.admin_panel_settings, size: 50, color: theme.primaryColor),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "${admin!["first_name"]} ${admin!["last_name"]}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 6),
            Text(
              admin!["designation"] ?? "School Administrator",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            SizedBox(height: 16),
            if (admin!["unique_id"] != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "ID: ${admin!["unique_id"]}",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          Spacer(),
          Container(height: 1, width: 60, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(List<Widget> children) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }

  Widget _infoTile(String label, String value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        subtitle: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () async {
            await AuthService.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          },
          icon: Icon(Icons.power_settings_new),
          label: Text("Logout Securely", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            side: BorderSide(color: Colors.red.withOpacity(0.2)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
