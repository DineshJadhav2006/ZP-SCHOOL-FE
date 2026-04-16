import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../login_screen.dart';
import 'superadmin_dashboard_screen.dart';
import 'superadmin_schools_screen.dart';
import 'superadmin_reports_screen.dart';
import 'superadmin_profile_screen.dart';
import '../../localization/language_service.dart';

class SuperAdminScreen extends StatefulWidget {
  @override
  _SuperAdminScreenState createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;
  int totalSchools = 0;
  int totalStudents = 0;
  int totalTeachers = 0;
  bool isLoading = true;
  String superAdminName = "Super Admin";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadSuperAdminData();
  }

  Future<void> loadSuperAdminData() async {
    try {
      setState(() => isLoading = true);
      
      String? userId = await AuthService.getUserId();
      
      if (userId != null) {
        Map<String, dynamic>? userData = await UserService.getUserById(userId);
        
        if (userData != null) {
          String firstName = userData['first_name'] ?? '';
          String lastName = userData['last_name'] ?? '';
          superAdminName = '$firstName $lastName'.trim();
          
          if (superAdminName.isEmpty) {
            superAdminName = userData['unique_id'] ?? 'Super Admin';
          }
        } else {
          superAdminName = 'Super Admin';
        }
      } else {
        superAdminName = 'Super Admin';
      }
      
      // Load real statistics
      Map<String, dynamic>? stats = await UserService.getAllStatistics();
      if (stats != null) {
        totalSchools = stats['clients'] ?? 0;
        totalStudents = stats['students'] ?? 0;
        totalTeachers = stats['staff'] ?? 0;
      } else {
        totalSchools = 0;
        totalStudents = 0;
        totalTeachers = 0;
      }
      
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint("Error loading super admin data: $e");
      setState(() {
        superAdminName = 'Super Admin';
        totalSchools = 0;
        totalStudents = 0;
        totalTeachers = 0;
        isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    await loadSuperAdminData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LanguageService.text("zp_school_system"), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(LanguageService.text("superadmin_dashboard"), style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: refreshData,
            tooltip: "Refresh",
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.supervisor_account, size: 35, color: theme.primaryColor),
                  ),
                  SizedBox(height: 10),
                  Text(superAdminName, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(LanguageService.text("super_administrator"), style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(LanguageService.text("system_settings")),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('System Settings - Coming Soon')),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(LanguageService.text("logout"), style: TextStyle(color: Colors.red)),
              onTap: () async {
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: selectedIndex,
              children: [
                SuperAdminDashboardScreen(
                  superAdminName: superAdminName,
                  totalSchools: totalSchools,
                  totalStudents: totalStudents,
                  totalTeachers: totalTeachers,
                  onRefresh: refreshData,
                  onNavigateToSchools: () => setState(() => selectedIndex = 1),
                  onNavigateToReports: () => setState(() => selectedIndex = 2),
                ),
                SuperAdminSchoolsScreen(totalSchools: totalSchools),
                SuperAdminReportsScreen(),
                SuperAdminProfileScreen(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined),
            label: LanguageService.text("dashboard"),
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 1 ? Icons.school : Icons.school_outlined),
            label: LanguageService.text("schools"),
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 2 ? Icons.assessment : Icons.assessment_outlined),
            label: LanguageService.text("reports"),
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 3 ? Icons.person : Icons.person_outline),
            label: LanguageService.text("profile"),
          ),
        ],
      ),
    );
  }
}