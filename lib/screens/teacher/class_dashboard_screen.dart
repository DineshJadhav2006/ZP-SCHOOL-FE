import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../../services/cache_service.dart';
import 'package:intl/intl.dart';
import 'student_list_screen.dart';
import 'attendance_screen.dart';
import 'attendance_list_screen.dart';
import 'add_student_screen.dart';
import 'homework_screen.dart';
import 'teacher_profile_screen.dart';
import '../admin/notices_screen.dart';
import '../login_screen.dart';

class ClassDashboardScreen extends StatefulWidget {
  final String className;
  final String teacherName;
  final String designation;

  ClassDashboardScreen({
    required this.className,
    required this.teacherName,
    required this.designation,
  });

  @override
  _ClassDashboardScreenState createState() =>
      _ClassDashboardScreenState();
}

class _ClassDashboardScreenState extends State<ClassDashboardScreen> with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;
  int totalStudents = 0;
  int todayPresent = 0;
  int todayAbsent = 0;
  bool isLoading = true;
  Key attendanceKey = UniqueKey();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadStudentCount();
  }

  void loadStudentCount() async {
    // Show UI immediately with placeholder
    setState(() {
      isLoading = true;
    });
    
    // Load from API in background
    int count = await StudentService.getStudentCount(widget.className);
    await loadTodayAttendance();
    
    if (mounted) {
      setState(() {
        totalStudents = count;
        isLoading = false;
      });
    }
  }

  Future<void> loadTodayAttendance() async {
    try {
      String? clientId = await AuthService.getClientId();
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      var result = await AttendanceService.getAttendance(
        clientId: clientId!,
        standard: widget.className,
        division: "A",
        date: today,
      );
      
      setState(() {
        todayPresent = result['present'] ?? 0;
        todayAbsent = result['absent'] ?? 0;
      });
    } catch (e) {
      print("Error loading attendance: $e");
      setState(() {
        todayPresent = 0;
        todayAbsent = 0;
      });
    }
  }

  String greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 20) return "Good Evening";
    return "Good Night";
  }

  Widget infoBox(String title, String value, Color color, Future<void> Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HOME =================
  Widget homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting(), style: TextStyle(fontSize: 20)),
                    Text(
                      widget.teacherName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text("Class: ${widget.className}"),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.person_add, size: 32, color: Colors.blue),
                onPressed: () async {
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddStudentScreen(standard: widget.className),
                    ),
                  );
                  if (result == true) {
                    loadStudentCount();
                  }
                },
                tooltip: "Add Student",
              ),
            ],
          ),
          SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              infoBox(
                "Total Students",
                isLoading ? "..." : totalStudents.toString(),
                Colors.blue,
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StudentListScreen(standard: widget.className),
                    ),
                  );
                },
              ),
              infoBox(
                "Today Present",
                isLoading ? "..." : todayPresent.toString(),
                Colors.green,
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceListScreen(
                        standard: widget.className,
                        division: "A",
                        filterStatus: "Present",
                      ),
                    ),
                  );
                  loadTodayAttendance();
                  setState(() {
                    attendanceKey = UniqueKey();
                  });
                },
              ),
              infoBox(
                "Today Absent",
                isLoading ? "..." : todayAbsent.toString(),
                Colors.red,
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceListScreen(
                        standard: widget.className,
                        division: "A",
                        filterStatus: "Absent",
                      ),
                    ),
                  );
                  loadTodayAttendance();
                  setState(() {
                    attendanceKey = UniqueKey();
                  });
                },
              ),
              infoBox("Other", "-", Colors.orange, () async {}),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ATTENDANCE =================
  Widget attendancePage() {
    return AttendanceScreen(
      key: attendanceKey,
      standard: widget.className,
      division: "A",
      onAttendanceSaved: () {
        loadTodayAttendance();
        setState(() {
          attendanceKey = UniqueKey();
        });
      },
    );
  }

  // ================= HOMEWORK =================
  Widget homeworkPage() {
    return HomeworkScreen(className: widget.className);
  }

  // ================= PROFILE =================
  Widget profilePage() {
    return TeacherProfileScreen();
  }

  void showClassSelectionDialog() {
    final List<String> classes = [
      "1st", "2nd", "3rd", "4th", "5th", "6th", "7th"
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Switch Class"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final className = classes[index];
              return ListTile(
                title: Text(className),
                trailing: widget.className == className
                    ? Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  if (className != widget.className) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClassDashboardScreen(
                          className: className,
                          teacherName: widget.teacherName,
                          designation: widget.designation,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ZP SCHOOL MANDAVE KH",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Class: ${widget.className}",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.teacherName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.designation,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.class_, color: Colors.blue),
              title: Text("Switch Class"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                showClassSelectionDialog();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout"),
              onTap: () async {
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
      ),
      body: Builder(
        builder: (context) {
          return PageStorage(
            bucket: PageStorageBucket(),
            child: IndexedStack(
              index: selectedIndex,
              children: [
                homePage(),
                attendancePage(),
                homeworkPage(),
                profilePage(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          if (index == 0) {
            loadTodayAttendance();
          } else if (index == 1) {
            setState(() {
              attendanceKey = UniqueKey();
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Homework",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
