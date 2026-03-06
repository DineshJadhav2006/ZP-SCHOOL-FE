import 'package:flutter/material.dart';
import '../../services/marks_service.dart';
import '../../services/auth_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen();

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> examMarks = {};

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    setState(() => isLoading = true);
    
    String? studentId = await AuthService.getStudentId();
    if (studentId == null) {
      setState(() => isLoading = false);
      return;
    }

    List<String> exams = ['Unit Test 1', 'Mid Sem', 'Unit Test 2', 'Final Exam'];
    Map<String, List<Map<String, dynamic>>> results = {};

    for (String exam in exams) {
      final data = await MarksService.getStudentMarks(
        studentId: studentId,
        examName: exam,
      );
      
      List<dynamic> marks = data['marks'] ?? [];
      if (marks.isNotEmpty) {
        List<Map<String, dynamic>> subjects = [];
        for (var mark in marks) {
          subjects.add({
            'subject_name': mark['subject_name'],
            'marks_obtained': mark['marks_obtained'],
            'total_marks': mark['total_marks'],
          });
        }
        results[exam] = subjects;
      }
    }

    setState(() {
      examMarks = results;
      isLoading = false;
    });
  }

  String _getGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'E';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+': return Colors.green;
      case 'A': return Colors.lightGreen;
      case 'B+': return Colors.blue;
      case 'B': return Colors.lightBlue;
      case 'C': return Colors.orange;
      case 'D': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }

  IconData _getSubjectIcon(String subject) {
    if (subject.toLowerCase().contains('math')) return Icons.functions;
    if (subject.toLowerCase().contains('english')) return Icons.translate;
    if (subject.toLowerCase().contains('science')) return Icons.science;
    if (subject.toLowerCase().contains('marathi')) return Icons.language;
    return Icons.book;
  }

  Color _getSubjectColor(String subject) {
    if (subject.toLowerCase().contains('math')) return Colors.blue;
    if (subject.toLowerCase().contains('english')) return Colors.orange;
    if (subject.toLowerCase().contains('science')) return Colors.green;
    if (subject.toLowerCase().contains('marathi')) return Colors.purple;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: examMarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    'No results available',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadResults,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGradeInfoCard(theme),
                    SizedBox(height: 20),
                    ...examMarks.entries.map((entry) {
                      String examName = entry.key;
                      List<Map<String, dynamic>> subjects = entry.value;
                      
                      int totalObtained = 0;
                      int totalMax = 0;
                      for (var subject in subjects) {
                        totalObtained += (subject['marks_obtained'] as int? ?? 0);
                        totalMax += (subject['total_marks'] as int? ?? 0);
                      }
                      double percentage = totalMax > 0 ? (totalObtained / totalMax) * 100 : 0;
                      String grade = _getGrade(percentage);
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _buildExamCard(theme, examName, grade, percentage, subjects),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGradeInfoCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grade System',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _gradeItem('A+', '90%+', Colors.green),
              _gradeItem('A', '80-89%', Colors.lightGreen),
              _gradeItem('B+', '70-79%', Colors.blue),
              _gradeItem('B', '60-69%', Colors.lightBlue),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _gradeItem('C', '50-59%', Colors.orange),
              SizedBox(width: 8),
              _gradeItem('D', '40-49%', Colors.deepOrange),
              SizedBox(width: 8),
              _gradeItem('E', '<40%', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradeItem(String grade, String range, Color color) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              grade,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
        ),
        SizedBox(height: 3),
        Text(
          range,
          style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildExamCard(ThemeData theme, String title, String grade, double percentage, List<Map<String, dynamic>> subjects) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Row(
            children: [
              Text(
                "Grade: $grade",
                style: TextStyle(color: _getGradeColor(grade), fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 12),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.assignment, color: theme.primaryColor, size: 24),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: subjects.map((subject) {
                  String name = subject['subject_name'] ?? '';
                  int obtained = subject['marks_obtained'] ?? 0;
                  int total = subject['total_marks'] ?? 0;
                  return _subjectRow(name, "$obtained/$total", _getSubjectIcon(name), _getSubjectColor(name));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectRow(String name, String marks, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          ),
          Text(
            marks,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
