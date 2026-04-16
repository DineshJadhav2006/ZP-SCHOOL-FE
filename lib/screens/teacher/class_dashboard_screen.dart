import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/student_service.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/shimmer_loading.dart';
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
import 'exams_screen.dart';
import 'teacher_complaints_screen.dart';
import '../../localization/language_service.dart';

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
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      // Load student count and attendance separately
      final studentCount = await StudentService.getStudentCount(widget.className);
      await loadTodayAttendance();
      
      debugPrint("API Data - Students: $studentCount, Present: $todayPresent, Absent: $todayAbsent");
      
      if (mounted) {
        setState(() {
          totalStudents = studentCount;
          isLoading = false;
        });
        debugPrint("UI Updated - Students: $totalStudents, Present: $todayPresent, Absent: $todayAbsent");
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        setState(() {
          totalStudents = 0;
          isLoading = false;
        });
      }
    }
  }

  Future<void> loadTodayAttendance() async {
    try {
      String? clientId = await AuthService.getClientId();
      if (clientId == null) {
        setState(() {
          todayPresent = 0;
          todayAbsent = 0;
        });
        return;
      }
      
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      var result = await AttendanceService.getAttendance(
        clientId: clientId,
        standard: widget.className,
        division: "A",
        date: today,
      );
      
      if (mounted) {
        setState(() {
          todayPresent = result['present'] ?? 0;
          todayAbsent = result['absent'] ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          todayPresent = 0;
          todayAbsent = 0;
        });
      }
    }
  }

  String greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return LanguageService.text("good_morning");
    if (hour < 17) return LanguageService.text("good_afternoon");
    if (hour < 20) return LanguageService.text("good_evening");
    return LanguageService.text("good_night");
  }

  Widget infoBox(String title, String value, Color color, IconData icon, Future<void> Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ShimmerLoading(
        isLoading: isLoading,
        child: Container(
          height: 120,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 15,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? Container(
                      width: 60,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        SizedBox(width: 12),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: color.withOpacity(0.9),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 8),
              isLoading
                  ? Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
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
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: theme.primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.person_add_rounded, color: theme.primaryColor, size: 28),
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
              ).animate().scale(delay: 200.ms, duration: 400.ms),
            ],
          ),
          SizedBox(height: 24),
          Text(
            LanguageService.text("overview"),
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
                LanguageService.text("total_students"),
                totalStudents.toString(),
                Colors.blue,
                Icons.people_alt_rounded,
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
                LanguageService.text("present"),
                todayPresent.toString(),
                Colors.green,
                Icons.check_circle_rounded,
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
                LanguageService.text("absent"),
                todayAbsent.toString(),
                Colors.red,
                Icons.cancel_rounded,
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
              infoBox(LanguageService.text("other"), "-", Colors.orange, Icons.more_horiz_rounded, () async {}),
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, color: Theme.of(context).primaryColor, size: 28),
                  SizedBox(width: 12),
                  Text(
                    LanguageService.text("switch_class"),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.9,
                ),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final className = classes[index];
                  bool isCurrent = widget.className == className;
                  
                  return InkWell(
                    onTap: () {
                      if (!isCurrent) {
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
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent ? Theme.of(context).primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCurrent 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.shade200,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCurrent 
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.3) 
                              : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            color: isCurrent ? Colors.white : Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text(
                            className,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCurrent ? Colors.white : Colors.grey.shade800,
                            ),
                          ),
                          if (isCurrent)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                LanguageService.text("current"),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
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
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LanguageService.text("zp_school_short") ?? "ZP School", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
            Text(
              "${LanguageService.text("class_teacher")}: ${widget.className}",
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_active_rounded, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NoticesScreen()),
                );
              },
            ),
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
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, -5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: selectedIndex,
            selectedItemColor: theme.primaryColor,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
            onTap: (index) {
              setState(() => selectedIndex = index);
              if (index == 0) loadTodayAttendance();
              if (index == 1) setState(() => attendanceKey = UniqueKey());
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined),
                label: LanguageService.text("home"),
              ),
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 1 ? Icons.fact_check_rounded : Icons.fact_check_outlined),
                label: LanguageService.text("attendance"),
              ),
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 2 ? Icons.assignment_rounded : Icons.assignment_outlined),
                label: LanguageService.text("homework"),
              ),
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 3 ? Icons.menu_book_rounded : Icons.book_outlined),
                label: LanguageService.text("books"),
              ),
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 4 ? Icons.account_circle_rounded : Icons.account_circle_outlined),
                label: LanguageService.text("profile"),
              ),
            ],
          ),
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
                colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                child: Icon(Icons.person, size: 40, color: theme.primaryColor),
              ),
            ),
            accountName: Text(widget.teacherName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(widget.designation, style: TextStyle(color: Colors.white70)),
          ),
          ListTile(
            leading: Icon(Icons.swap_horiz_rounded, color: theme.primaryColor),
            title: Text(LanguageService.text("switch_class"), style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              showClassSelectionDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment_turned_in, color: theme.primaryColor),
            title: Text(LanguageService.text("exams"), style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExamsScreen(className: widget.className),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.report_problem, color: Colors.orange),
            title: Text(LanguageService.text("my_complaints"), style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeacherComplaintsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline_rounded, color: theme.primaryColor),
            title: Text(LanguageService.text("school_information"), style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          Spacer(),
          Divider(indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.red),
            title: Text(LanguageService.text("logout"), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
