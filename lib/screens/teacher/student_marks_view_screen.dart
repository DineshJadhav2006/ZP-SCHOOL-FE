import 'package:flutter/material.dart';
import '../../services/marks_service.dart';

class StudentMarksViewScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentMarksViewScreen({required this.student});

  @override
  _StudentMarksViewScreenState createState() => _StudentMarksViewScreenState();
}

class _StudentMarksViewScreenState extends State<StudentMarksViewScreen> {
  bool isLoading = true;
  List<dynamic> marks = [];
  String selectedExam = 'First Term';
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
      loadMarks();
    }
  }

  Future<void> loadMarks() async {
    setState(() => isLoading = true);
    final data = await MarksService.getStudentMarks(
      studentId: widget.student['id'],
      examName: selectedExam,
    );
    setState(() {
      marks = data['marks'] ?? [];
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

  @override
  Widget build(BuildContext context) {
    String studentName = '${widget.student['first_name']} ${widget.student['last_name']}';
    String studentClass = widget.student['standard'] ?? '';
    if (widget.student['division'] != null) {
      studentClass += '-${widget.student['division']}';
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Student Results', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 30),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(studentName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Class: $studentClass', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedExam,
                  decoration: InputDecoration(
                    labelText: 'Select Exam',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: examOptions.map((exam) => DropdownMenuItem(value: exam, child: Text(exam))).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedExam = value);
                      loadMarks();
                    }
                  },
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
                : marks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text('No marks found for $selectedExam', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: marks.length,
                        itemBuilder: (context, index) {
                          final mark = marks[index];
                          String subject = mark['subject_name'] ?? '';
                          int obtainedMarks = mark['marks_obtained'] ?? 0;
                          int totalMarks = mark['total_marks'] ?? 100;
                          String grade = getGrade(obtainedMarks);
                          double percentage = totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(subject, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 4),
                                        Text('$obtainedMarks / $totalMarks', style: TextStyle(color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: getGradeColor(grade).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          grade,
                                          style: TextStyle(
                                            color: getGradeColor(grade),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ],
                              ),
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