import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../services/homework_service.dart';
import '../../services/notice_service.dart';
import '../../services/auth_service.dart';
import 'home_screen.dart';
import 'homework_screen.dart';
import 'results_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'student_notices_screen.dart';
import 'books_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDashboardScreen extends StatefulWidget {
  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;

  Map<String, dynamic>? studentData;
  List<dynamic> homeworkList = [];

  bool isLoading = true;
  bool isHomeworkLoading = false;

  String? studentName = "Student";
  String? studentClass = "Class";
  int unreadCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadStudentData();
    _loadUnreadCount();
    _checkNewNotices();
  }

  Future<void> _loadUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      unreadCount = prefs.getInt('unread_notices') ?? 0;
    });
  }

  Future<void> _checkNewNotices() async {
    await NoticeService.updateUnreadCount();
    _loadUnreadCount();
  }

  // ================= LOAD STUDENT =================
  Future<void> loadStudentData() async {
    try {
      final student = await StudentService.getStudent();

      if (student != null) {
        String firstName = student['first_name'] ?? '';
        String lastName = student['last_name'] ?? '';
        String standard = student['standard'] ?? '';

        setState(() {
          studentData = student;
          studentName = '$firstName $lastName'.trim();
          studentClass = standard;
          isLoading = false;
        });

        await loadHomework(standard);
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error loading student: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= LOAD HOMEWORK =================
  Future<void> loadHomework(String className) async {
    setState(() => isHomeworkLoading = true);
    try {
      var data = await HomeworkService.getHomeworkByClass(className);
      setState(() {
        homeworkList = data;
        isHomeworkLoading = false;
      });
    } catch (e) {
      print("Homework error: $e");
      setState(() => isHomeworkLoading = false);
    }
  }

  // ================= GREETING =================
  String greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 20) return "Good Evening";
    return "Good Night";
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Placeholder: No action as requested
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ZP SCHOOL MANDAVE KH", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              "Student Dashboard",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => StudentNoticesScreen()),
                  );
                  _loadUnreadCount();
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: selectedIndex,
              children: [
                HomeScreen(
                  studentData: studentData,
                  studentName: studentName,
                  studentClass: studentClass,
                  greeting: greeting(),
                  onTabChange: (index) => setState(() => selectedIndex = index),
                ),
                HomeworkScreen(
                  className: studentClass ?? "",
                  onRefresh: () => loadHomework(studentClass ?? ""),
                ),
                const ResultsScreen(),
                BooksScreen(className: studentClass ?? ""),
                ProfileScreen(
                  studentData: studentData,
                  studentName: studentName,
                  studentClass: studentClass,
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() => selectedIndex = index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1 ? Icons.assignment : Icons.assignment_outlined),
              label: "Homework",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 2 ? Icons.assessment : Icons.assessment_outlined),
              label: "Results",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 3 ? Icons.book : Icons.book_outlined),
              label: "Books",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 4 ? Icons.person : Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
