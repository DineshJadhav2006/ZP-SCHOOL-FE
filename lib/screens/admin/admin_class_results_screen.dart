import 'package:flutter/material.dart';
import '../../services/marks_service.dart';
import '../../services/student_service.dart';

class AdminClassResultsScreen extends StatefulWidget {
  @override
  _AdminClassResultsScreenState createState() => _AdminClassResultsScreenState();
}

class _AdminClassResultsScreenState extends State<AdminClassResultsScreen> {
  bool isLoading = true;
  List<dynamic> marks = [];
  List<dynamic> students = [];
  String selectedClass = '1st';
  String selectedExam = 'First Term';
  List<String> classOptions = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th'];
  List<String> examOptions = [];
  bool isLoadingExams = true;

  @override
  void initState() {
    super.initState();
    loadExamNames();
  }

  Future<void> loadExamNames() async {
    setState(() => isLoadingExams = true);
    final exams = await MarksService.getExamNames();
    setState(() {
      examOptions = exams;
      if (examOptions.isNotEmpty) {
        selectedExam = examOptions.first;
      }
      isLoadingExams = false;
    });
    if (examOptions.isNotEmpty) {
      loadData();
    }
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final marksData = await MarksService.getMarksByClass(
      standard: selectedClass,
      examName: selectedExam,
    );
    final studentsData = await StudentService.getStudents(selectedClass);
    setState(() {
      marks = marksData['marks'] ?? [];
      students = studentsData;
      isLoading = false;
    });
  }

  String getGrade(int marks) {
    if (marks >= 90) return 'A+';
    if (marks >= 80) return 'A';
    if (marks >= 70) return 'B+';
    if (marks >= 60) return 'B';
    if (marks >= 50) return 'C';
    if (marks >= 40) return 'D';
    return 'E';
  }

  Color getGradeColor(String grade) {
    switch (grade) {
      case 'A+': return Colors.green.shade700;
      case 'A': return Colors.green;
      case 'B+': return Colors.lightGreen;
      case 'B': return Colors.orange;
      case 'C': return Colors.amber;
      case 'D': return Colors.deepOrange;
      default: return Colors.red;
    }
  }

  Map<String, List<dynamic>> groupMarksByStudent() {
    Map<String, List<dynamic>> grouped = {};
    for (var mark in marks) {
      String studentId = mark['student_id'] ?? '';
      if (!grouped.containsKey(studentId)) {
        grouped[studentId] = [];
      }
      grouped[studentId]!.add(mark);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedMarks = groupMarksByStudent();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Text('Class Results', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: InputDecoration(
                        labelText: 'Class',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: classOptions.map((cls) => DropdownMenuItem(value: cls, child: Text(cls))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedClass = value);
                          loadData();
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedExam,
                      decoration: InputDecoration(
                        labelText: 'Exam',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: examOptions.map((exam) => DropdownMenuItem(value: exam, child: Text(exam))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedExam = value);
                          loadData();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoadingExams
                ? Center(child: CircularProgressIndicator())
                : examOptions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text('No exams found', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : isLoading
                ? Center(child: CircularProgressIndicator())
                : groupedMarks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text('No results found for $selectedClass - $selectedExam', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: groupedMarks.keys.length,
                        itemBuilder: (context, index) {
                          String studentId = groupedMarks.keys.elementAt(index);
                          List<dynamic> studentMarks = groupedMarks[studentId]!;
                          
                          var student = students.firstWhere(
                            (s) => s['id'] == studentId,
                            orElse: () => {'first_name': 'Unknown', 'last_name': 'Student'},
                          );
                          
                          String studentName = '${student['first_name']} ${student['last_name']}';
                          
                          int totalObtained = studentMarks.fold<int>(0, (sum, mark) => sum + ((mark['marks_obtained'] as num?)?.toInt() ?? 0));
                          int totalMarks = studentMarks.fold<int>(0, (sum, mark) => sum + ((mark['total_marks'] as num?)?.toInt() ?? 100));
                          double percentage = totalMarks > 0 ? (totalObtained / totalMarks) * 100 : 0;
                          String overallGrade = getGrade(percentage.round());

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.all(16),
                              childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                              leading: CircleAvatar(
                                backgroundColor: theme.primaryColor.withOpacity(0.1),
                                child: Icon(Icons.person, color: theme.primaryColor),
                              ),
                              title: Text(studentName, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Total: $totalObtained / $totalMarks'),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: getGradeColor(overallGrade).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$overallGrade (${percentage.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    color: getGradeColor(overallGrade),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              children: [
                                Divider(),
                                ...studentMarks.map((mark) {
                                  String subject = mark['subject_name'] ?? '';
                                  int obtained = mark['marks_obtained'] ?? 0;
                                  int total = mark['total_marks'] ?? 100;
                                  String grade = getGrade(obtained);
                                  
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(subject)),
                                        Text('$obtained / $total'),
                                        SizedBox(width: 16),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: getGradeColor(grade).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            grade,
                                            style: TextStyle(
                                              color: getGradeColor(grade),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}