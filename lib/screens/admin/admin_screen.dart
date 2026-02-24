import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/teacher_service.dart';
import '../login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_students_screen.dart';
import 'admin_teachers_screen.dart';
import 'admin_profile_screen.dart';

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
      print("Error loading admin data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> refreshData() async {
    await loadAdminData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ZP SCHOOL MANDAVE KH", style: TextStyle(fontSize: 16)),
            Text(
              "Admin Dashboard",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: selectedIndex,
              children: [
                /// DASHBOARD
                AdminDashboardScreen(
                  adminName: adminName,
                  totalStudents: totalStudents,
                  totalTeachers: totalTeachers,
                  onRefresh: refreshData,
                  onTabChange: (index) {
                    setState(() => selectedIndex = index);
                  },
                ),

                /// STUDENTS
                AdminStudentsScreen(totalStudents: totalStudents),

                /// TEACHERS
                AdminTeachersScreen(totalTeachers: totalTeachers),

                /// PROFILE
                AdminProfileScreen(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Teachers"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
