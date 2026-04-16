import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/teacher_service.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'package:intl/intl.dart';
import '../../localization/language_service.dart';

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
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : admin == null
          ? Center(child: Text(LanguageService.text("failed_to_load_profile")))
          : RefreshIndicator(
              onRefresh: () async => loadAdminProfile(),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, Colors.indigo.shade800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfileHeader(theme),
                        Transform.translate(
                          offset: Offset(0, -30),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 30),
                                _buildSectionHeader(LanguageService.text("personal_details")),
                                _buildInfoGrid([
                                  _premiumTile(LanguageService.text("phone"), admin!["mobile_number"] ?? "-", Icons.phone_android_rounded, Colors.green),
                                  _premiumTile(LanguageService.text("gender"), admin!["gender"] ?? "-", Icons.person_search_rounded, Colors.pink),
                                  _premiumTile(LanguageService.text("date_of_birth"), formatDate(admin!["date_of_birth"]), Icons.cake_rounded, Colors.orange, isLast: true),
                                ]),
                                SizedBox(height: 25),
                                _buildSectionHeader(LanguageService.text("professional_hub")),
                                _buildInfoGrid([
                                  _premiumTile(LanguageService.text("qualification"), admin!["qualification"] ?? "-", Icons.school_rounded, Colors.blue),
                                  _premiumTile(LanguageService.text("experience"), "${admin!["experience"] ?? 0} ${LanguageService.text('years')}", Icons.work_history_rounded, Colors.teal),
                                  _premiumTile(LanguageService.text("joined_date"), formatDate(admin!["created_on"]), Icons.calendar_month_rounded, Colors.indigo.shade700, isLast: true),
                                ]),
                                SizedBox(height: 40),
                                _buildLogoutButton(context, theme),
                                SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.9),
            Colors.indigo.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Icon(Icons.admin_panel_settings_rounded, size: 60, color: theme.primaryColor),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            SizedBox(height: 16),
            Text(
              "${admin!["first_name"]} ${admin!["last_name"]}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
            SizedBox(height: 4),
            Text(
              admin!["designation"] ?? LanguageService.text("school_administrator"),
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ).animate().fadeIn(duration: 600.ms),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1);
  }

  Widget _buildInfoGrid(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _premiumTile(String label, String value, IconData icon, Color color, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              value.isEmpty ? "-" : value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 70, endIndent: 20, color: Colors.grey.shade200),
      ],
    );
  }

  Future<void> handleLogout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageService.text("logout")),
        content: Text(LanguageService.text("are_you_sure_logout")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LanguageService.text("cancel")),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(LanguageService.text("logout"), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: handleLogout,
        icon: Icon(Icons.logout_rounded, color: Colors.red),
        label: Text(LanguageService.text("logout_securely"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}
