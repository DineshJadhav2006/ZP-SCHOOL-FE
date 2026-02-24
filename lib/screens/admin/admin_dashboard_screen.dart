import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../teacher/add_student_screen.dart';
import 'add_teacher_screen.dart';
import 'admin_reports_screen.dart';
import 'notices_screen.dart';

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
      "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th"
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Class"),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: classes.length,
            itemBuilder: (context, index) {
              String className = classes[index];
              return ListTile(
                leading: Icon(Icons.class_, color: Colors.blue),
                title: Text(className),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
