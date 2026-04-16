import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';
import '../../services/teacher_service.dart';
import '../login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_students_screen.dart';
import 'admin_teachers_screen.dart';
import 'admin_profile_screen.dart';
import 'notices_screen.dart';
import 'admin_books_screen.dart';
import '../../localization/language_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;
  int totalStudents = 0;
  int totalTeachers = 0;
  bool isLoading = true;
  String adminName = "Admin";
  Map<String, dynamic>? adminData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    try {
      setState(() => isLoading = true);

      // Load admin info from API
      Map<String, dynamic>? admin = await TeacherService.getAdmin();

      if (admin != null) {
        String firstName = admin['first_name'] ?? '';
        String lastName = admin['last_name'] ?? '';
        adminName = '$firstName $lastName'.trim();

        if (adminName.isEmpty) {
          // Fallback to clientId if name is empty
          String? clientId = await AuthService.getClientId();
          adminName = clientId ?? "Admin";
        }
      } else {
        // Fallback if API call fails
        String? clientId = await AuthService.getClientId();
        adminName = clientId ?? "Admin";
      }

      // Load statistics
      Map<String, dynamic>? stats = await TeacherService.getStatistics();
      int studentCount = 0;
      int teacherCount = 0;

      if (stats != null) {
        studentCount = stats['students'] ?? 0;
        teacherCount = stats['teachers'] ?? 0;
      }

      setState(() {
        adminData = admin;
        totalStudents = studentCount;
        totalTeachers = teacherCount;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading admin data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> refreshData() async {
    await loadAdminData();
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
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LanguageService.text("zp_school"), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              LanguageService.text("admin_dashboard"),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoticesScreen()),
              );
            },
            tooltip: "Notices",
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
                    child: Icon(Icons.admin_panel_settings, size: 35, color: theme.primaryColor),
                  ),
                  SizedBox(height: 10),
                  Text(adminName, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(LanguageService.text("administrator"), style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.book_outlined),
              title: Text(LanguageService.text("books")),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminBooksScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(LanguageService.text("logout"), style: TextStyle(color: Colors.red)),
              onTap: () async {
                await AuthService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
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
                AdminDashboardScreen(
                  adminName: adminName,
                  totalStudents: totalStudents,
                  totalTeachers: totalTeachers,
                  onRefresh: refreshData,
                  onTabChange: (index) => setState(() => selectedIndex = index),
                ),
                AdminStudentsScreen(totalStudents: totalStudents),
                AdminTeachersScreen(totalTeachers: totalTeachers),
                AdminProfileScreen(),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => setState(() => selectedIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined),
              label: LanguageService.text("dashboard"),
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1 ? Icons.people : Icons.people_outline),
              label: LanguageService.text("students"),
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 2 ? Icons.school : Icons.school_outlined),
              label: LanguageService.text("teachers"),
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 3 ? Icons.person : Icons.person_outline),
              label: LanguageService.text("profile"),
            ),
          ],
        ),
      ),
    );
  }
}
