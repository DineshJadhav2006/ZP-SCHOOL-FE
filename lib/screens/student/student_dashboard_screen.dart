import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../localization/language_service.dart';

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
      debugPrint("Error loading student: $e");
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
      debugPrint("Homework error: $e");
      setState(() => isHomeworkLoading = false);
    }
  }

  // ================= GREETING =================
  String greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return LanguageService.text("good_morning");
    if (hour < 17) return LanguageService.text("good_afternoon");
    if (hour < 20) return LanguageService.text("good_evening");
    return LanguageService.text("good_night");
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
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school_rounded, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LanguageService.text("zp_school_short") ?? "ZP School", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                Text(
                  LanguageService.text("student_space") ?? "Student Space",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentNoticesScreen()),
                    );
                    _loadUnreadCount();
                  },
                ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(end: 1.05, duration: 800.ms),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent, 
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)
                    ),
                    constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).animate().shake(duration: 500.ms),
            ],
          ),
          SizedBox(width: 8),
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
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              setState(() => selectedIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue.shade600,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined, size: 28),
                label: LanguageService.text("home"),
              ),
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 1 ? Icons.assignment_rounded : Icons.assignment_outlined, size: 28),
                label: LanguageService.text("homework"),
              ),
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 2 ? Icons.emoji_events_rounded : Icons.emoji_events_outlined, size: 28),
                label: LanguageService.text("results"),
              ),
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 3 ? Icons.menu_book_rounded : Icons.book_outlined, size: 28),
                label: LanguageService.text("books"),
              ),
              BottomNavigationBarItem(
                icon: Icon(selectedIndex == 4 ? Icons.face_rounded : Icons.face_outlined, size: 28),
                label: LanguageService.text("profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
