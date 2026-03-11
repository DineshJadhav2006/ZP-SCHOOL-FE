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
    final primaryColor = theme.primaryColor;
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: examMarks.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: loadResults,
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOverallSummary(theme),
                          SizedBox(height: 24),
                          _buildGradeInfoCard(theme),
                          SizedBox(height: 24),
                          Text(
                            "Term Results",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = examMarks.entries.elementAt(index);
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
                            child: _buildExamCard(theme, examName, grade, percentage, totalObtained, totalMax, subjects),
                          );
                        },
                        childCount: examMarks.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
    );
  }

  Widget _buildOverallSummary(ThemeData theme) {
    // Calculate overall average
    double totalPerc = 0;
    examMarks.forEach((key, subjects) {
      int obtained = 0, max = 0;
      for (var s in subjects) {
        obtained += (s['marks_obtained'] as int? ?? 0);
        max += (s['total_marks'] as int? ?? 0);
      }
      totalPerc += max > 0 ? (obtained / max) * 100 : 0;
    });
    double avgPerc = examMarks.isNotEmpty ? totalPerc / examMarks.length : 0;
    String overallGrade = _getGrade(avgPerc);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Overall Performance",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  "${avgPerc.toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Keep it up! You're doing great.",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              overallGrade,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeInfoCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: theme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Grade System',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
            ],
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _gradeBadge('A+', Colors.green, '91-100%'),
                _gradeBadge('A', Colors.lightGreen, '81-90%'),
                _gradeBadge('B+', Colors.blue, '71-80%'),
                _gradeBadge('B', Colors.lightBlue, '61-70%'),
                _gradeBadge('C', Colors.orange, '51-60%'),
                _gradeBadge('D', Colors.deepOrange, '41-50%'),
                _gradeBadge('E', Colors.red, '< 40%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeBadge(String grade, Color color, String range) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            grade,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
          ),
          SizedBox(height: 2),
          Text(
            range,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(ThemeData theme, String title, String grade, double percentage, int obtained, int total, List<Map<String, dynamic>> subjects) {
    Color gradeColor = _getGradeColor(grade);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.all(20),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.grey.shade800),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: gradeColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(gradeColor),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 50,
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: TextStyle(fontWeight: FontWeight.bold, color: gradeColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Grade: $grade",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "$obtained / $total Marks",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
          leading: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.assignment_rounded, color: theme.primaryColor, size: 24),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  Divider(height: 1),
                  SizedBox(height: 12),
                  ...subjects.map((subject) {
                    String name = subject['subject_name'] ?? '';
                    int obtained = subject['marks_obtained'] ?? 0;
                    int total = subject['total_marks'] ?? 0;
                    return _subjectRow(name, obtained, total);
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectRow(String name, int obtained, int total) {
    double perc = total > 0 ? (obtained / total) * 100 : 0;
    Color color = _getPercentageColor(perc);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSubjectColor(name).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getSubjectIcon(name), color: _getSubjectColor(name), size: 18),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.grey.shade700),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$obtained/$total",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.shade800),
              ),
              Text(
                "${perc.toStringAsFixed(0)}%",
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return Colors.green.shade600;
    if (percentage >= 60) return Colors.blue.shade600;
    if (percentage >= 40) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade200),
          SizedBox(height: 20),
          Text(
            'No results published yet',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for your performance report.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
