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
import 'books_screen.dart';
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.1), width: 1),
        ),
        child: Container(
          height: 120,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HOME =================
  Widget homePage() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                    Text(
                      "${greeting()},",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    Text(
                      widget.teacherName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.person_add_outlined, color: theme.primaryColor),
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
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            "Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),
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

  // ================= BOOKS =================
  Widget booksPage() {
    return BooksScreen(className: widget.className);
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
    super.build(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: _buildDrawer(theme),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ZP SCHOOL MANDAVE KH", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              "Class Teacher: ${widget.className}",
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoticesScreen()),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          homePage(),
          attendancePage(),
          homeworkPage(),
          booksPage(),
          profilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          onTap: (index) {
            setState(() => selectedIndex = index);
            if (index == 0) loadTodayAttendance();
            if (index == 1) setState(() => attendanceKey = UniqueKey());
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1 ? Icons.fact_check_rounded : Icons.fact_check_outlined),
              label: "Attendance",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 2 ? Icons.assignment_rounded : Icons.assignment_outlined),
              label: "Homework",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 3 ? Icons.book : Icons.book_outlined),
              label: "Books",
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 4 ? Icons.account_circle_rounded : Icons.account_circle_outlined),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 40, color: theme.primaryColor),
              ),
            ),
            accountName: Text(widget.teacherName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(widget.designation, style: TextStyle(color: Colors.white70)),
          ),
          ListTile(
            leading: Icon(Icons.swap_horiz_rounded, color: theme.primaryColor),
            title: Text("Switch Class", style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              showClassSelectionDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline_rounded, color: theme.primaryColor),
            title: Text("School Information", style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          Spacer(),
          Divider(indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Logout"),
                  content: Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Logout", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
