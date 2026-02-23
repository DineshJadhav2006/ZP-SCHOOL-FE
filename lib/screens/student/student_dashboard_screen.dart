import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../services/homework_service.dart';
import 'home_screen.dart';
import 'homework_screen.dart';
import 'results_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadStudentData();
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ZP SCHOOL MANDAVE KH", style: TextStyle(fontSize: 16)),
            Text(
              "Student Dashboard",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),

        // Right side notification icon
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationScreen()),
              );
            },
          ),
        ],
      ),

      // ================= BODY =================
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: selectedIndex,
              children: [
                /// HOME
                HomeScreen(
                  studentData: studentData,
                  studentName: studentName,
                  studentClass: studentClass,
                  greeting: greeting(),
                  onTabChange: (index) {
                    setState(() => selectedIndex = index);
                  },
                ),

                /// HOMEWORK
                HomeworkScreen(
                  homeworkList: homeworkList,
                  isLoading: isHomeworkLoading,
                  onRefresh: () => loadHomework(studentClass ?? ""),
                ),

                /// RESULTS
                const ResultsScreen(),

                /// PROFILE
                ProfileScreen(
                  studentData: studentData,
                  studentName: studentName,
                  studentClass: studentClass,
                ),
              ],
            ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        onTap: (index) async {
          setState(() {
            selectedIndex = index;
          });

          // If Homework tab opened
          if (index == 1) {
            await loadHomework(studentClass ?? "");
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Homework",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: "Results",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
