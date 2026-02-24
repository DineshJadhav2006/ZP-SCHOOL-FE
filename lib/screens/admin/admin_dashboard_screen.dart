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
    return RefreshIndicator(
      onRefresh: () async {
        await onRefresh();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// GREETING
            Text(
              greeting(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              adminName,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 24),

            /// STATS CARDS
            Text(
              "Overview",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildStatCard(
              title: "Total Students",
              value: totalStudents.toString(),
              icon: Icons.people,
              color: Colors.blue,
              onTap: () => onTabChange?.call(1),
            ),
            SizedBox(height: 12),
            _buildStatCard(
              title: "Total Teachers",
              value: totalTeachers.toString(),
              icon: Icons.school,
              color: Colors.green,
              onTap: () => onTabChange?.call(2),
            ),
            SizedBox(height: 24),

            /// QUICK ACTIONS
            Text(
              "Quick Actions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.person_add,
                    label: "Add Student",
                    color: Colors.blue,
                    onTap: () async {
                      _showClassSelectorForStudent(context);
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.school,
                    label: "Add Teacher",
                    color: Colors.green,
                    onTap: () async {
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
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.assessment,
                    label: "Reports",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminReportsScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.notifications,
                    label: "Notices",
                    color: Colors.deepOrange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NoticesScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          height: 90,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
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
