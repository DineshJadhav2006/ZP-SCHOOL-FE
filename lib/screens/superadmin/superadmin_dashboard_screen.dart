import 'package:flutter/material.dart';
import 'school_selection_screen.dart';
import '../admin/admin_reports_screen.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  final String superAdminName;
  final int totalSchools;
  final int totalStudents;
  final int totalTeachers;
  final Future<void> Function() onRefresh;
  final VoidCallback onNavigateToSchools;
  final VoidCallback onNavigateToReports;

  const SuperAdminDashboardScreen({
    required this.superAdminName,
    required this.totalSchools,
    required this.totalStudents,
    required this.totalTeachers,
    required this.onRefresh,
    required this.onNavigateToSchools,
    required this.onNavigateToReports,
  });

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              Spacer(),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
              SizedBox(height: 2),
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $superAdminName",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            SizedBox(height: 8),
            Text("System Overview", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              children: [
                _statCard(context, "Total Schools", totalSchools.toString(), Icons.school, Colors.blue, () {
                  onNavigateToSchools();
                }),
                _statCard(context, "Total Students", totalStudents.toString(), Icons.people, Colors.green, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SchoolSelectionScreen(type: 'students'),
                    ),
                  );
                }),
                _statCard(context, "Total Teachers", totalTeachers.toString(), Icons.person, Colors.orange, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SchoolSelectionScreen(type: 'teachers'),
                    ),
                  );
                }),
                _statCard(context, "All Users", "${totalStudents + totalTeachers}", Icons.verified_user, Colors.purple, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Total Users: ${totalStudents + totalTeachers}')),
                  );
                }),
              ],
            ),
            SizedBox(height: 24),
            Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _actionCard(context, "Manage Schools", Icons.school, Colors.blue, () {
              onNavigateToSchools();
            }),
            _actionCard(context, "View Reports", Icons.assessment, Colors.green, () {
              onNavigateToReports();
            }),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2)),
                child: Icon(icon, color: color, size: 14),
              ),
              SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              Icon(Icons.arrow_forward_ios, size: 12),
            ],
          ),
        ),
      ),
    );
  }
}
