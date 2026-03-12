import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/marks_service.dart';
import '../../models/marks.dart';

class StudentMarksEditScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String examName;

  const StudentMarksEditScreen({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.examName,
  });

  @override
  _StudentMarksEditScreenState createState() => _StudentMarksEditScreenState();
}

class _StudentMarksEditScreenState extends State<StudentMarksEditScreen> {
  bool isLoading = true;
  bool isSaving = false;
  List<Map<String, dynamic>> subjects = [];
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    loadMarks();
  }

  Future<void> loadMarks() async {
    setState(() => isLoading = true);
    
    final data = await MarksService.getStudentMarks(
      studentId: widget.studentId,
      examName: widget.examName,
    );
    
    List<dynamic> marks = data['marks'] ?? [];
    List<Map<String, dynamic>> subjectList = [];
    
    for (var mark in marks) {
      String subjectName = mark['subject_name'] ?? '';
      int marksObtained = mark['marks_obtained'] ?? 0;
      int totalMarks = mark['total_marks'] ?? 0;
      
      subjectList.add({
        'subject_name': subjectName,
        'total_marks': totalMarks,
      });
      
      controllers[subjectName] = TextEditingController(text: marksObtained.toString());
    }
    
    setState(() {
      subjects = subjectList;
      isLoading = false;
    });
  }

  Future<void> saveMarks() async {
    List<SubjectMarks> subjectMarks = [];
    
    for (var subject in subjects) {
      String subjectName = subject['subject_name'];
      int totalMarks = subject['total_marks'];
      String marksText = controllers[subjectName]!.text.trim();
      
      if (marksText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter marks for $subjectName')),
        );
        return;
      }
      
      int marksObtained = int.tryParse(marksText) ?? 0;
      
      if (marksObtained > totalMarks) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$subjectName marks cannot exceed $totalMarks')),
        );
        return;
      }
      
      subjectMarks.add(SubjectMarks(
        subjectName: subjectName,
        marksObtained: marksObtained,
        totalMarks: totalMarks,
      ));
    }
    
    setState(() => isSaving = true);
    
    bool success = await MarksService.saveMarks(
      studentId: widget.studentId,
      examName: widget.examName,
      subjects: subjectMarks,
    );
    
    setState(() => isSaving = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marks updated successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update marks'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Marks', style: TextStyle(fontSize: 16, color: Colors.white)),
            Text('${widget.studentName} (Roll: ${widget.rollNumber})', 
              style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : subjects.isEmpty
              ? Center(child: Text('No marks found'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.assignment, color: theme.primaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    widget.examName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              ...subjects.map((subject) {
                                String subjectName = subject['subject_name'];
                                int totalMarks = subject['total_marks'];
                                
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subjectName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: controllers[subjectName],
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                labelText: 'Marks Obtained',
                                                hintText: 'Enter marks',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.primaryColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '/ $totalMarks',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : saveMarks,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Save Marks',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}
