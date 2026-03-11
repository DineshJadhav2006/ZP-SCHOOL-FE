import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../teacher/add_student_screen.dart';
import 'add_teacher_screen.dart';
import 'admin_reports_screen.dart';
import 'notices_screen.dart';
import 'admin_complaints_screen.dart';
import 'admin_class_results_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String adminName;
  final int totalStudents;
  final int totalTeachers;
  final Future<void> Function() onRefresh;
  final Function(int)? onTabChange;

  const AdminDashboardScreen({
    required this.adminName,
    required this.totalStudents,
    required this.totalTeachers,
    required this.onRefresh,
    this.onTabChange,
  });

  String greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 20) return "Good Evening";
    return "Good Night";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        await onRefresh();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(theme),
            SizedBox(height: 30),
            _buildSectionHeader("School Overview"),
            SizedBox(height: 16),
            _buildStatsGrid(theme),
            SizedBox(height: 32),
            _buildSectionHeader("Quick Actions"),
            SizedBox(height: 16),
            _buildActionGrid(context, theme),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${greeting()},",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        Text(
          adminName,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: theme.primaryColor),
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
            SizedBox(width: 6),
            Text(
              DateFormat('EEEE, dd MMMM').format(DateTime.now()),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "Total Students",
            totalStudents.toString(),
            Colors.blue,
            Icons.people_alt_rounded,
            () => onTabChange?.call(1),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _statCard(
            "Total Teachers",
            totalTeachers.toString(),
            Colors.green,
            Icons.school_rounded,
            () => onTabChange?.call(2),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 20),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionCard(
                Icons.person_add_rounded,
                "Add Student",
                Colors.indigo,
                () => _showClassSelectorForStudent(context),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _actionCard(
                Icons.group_add_rounded,
                "Add Teacher",
                Colors.teal,
                () async {
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddTeacherScreen()),
                  );
                  if (result == true) onRefresh();
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                Icons.analytics_rounded,
                "Reports",
                Colors.amber.shade700,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminReportsScreen()));
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _actionCard(
                Icons.campaign_rounded,
                "Notices",
                Colors.orange.shade800,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NoticesScreen()));
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                Icons.report_problem,
                "Complaints",
                Colors.red.shade600,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminComplaintsScreen()));
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _actionCard(
                Icons.assignment,
                "Results",
                Colors.purple.shade600,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminClassResultsScreen()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.15)),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  Text(
                    label,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClassSelectorForStudent(BuildContext context) {
    final List<String> classes = [
      "1st", "2nd", "3rd", "4th", "5th", "6th", "7th"
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Select Class",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Choose a class to add a new student",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  String className = classes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddStudentScreen(standard: className),
                          ),
                        );
                        if (result == true) onRefresh();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.indigo.shade100,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.class_rounded,
                                color: Colors.indigo.shade700,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              className,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios_rounded, color: Colors.indigo.shade300, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
