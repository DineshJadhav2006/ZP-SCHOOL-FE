import 'package:flutter/material.dart';
import 'marks_view_screen.dart';

class ExamsScreen extends StatelessWidget {
  final String className;

  const ExamsScreen({required this.className});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final exams = [
      {'name': 'Unit Test 1', 'color': Colors.blue, 'icon': Icons.quiz},
      {'name': 'Mid Sem', 'color': Colors.orange, 'icon': Icons.school},
      {'name': 'Unit Test 2', 'color': Colors.green, 'icon': Icons.assignment},
      {'name': 'Final Exam', 'color': Colors.red, 'icon': Icons.workspace_premium},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Text('Exams - $className', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final exam = exams[index];
            return _buildExamCard(
              context,
              exam['name'] as String,
              exam['color'] as Color,
              exam['icon'] as IconData,
            );
          },
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, String examName, Color color, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarksViewScreen(
              className: className,
              examName: examName,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 12),
              Text(
                examName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
