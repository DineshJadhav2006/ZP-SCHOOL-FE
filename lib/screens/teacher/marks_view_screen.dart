import 'package:flutter/material.dart';
import '../../services/marks_service.dart';
import 'student_marks_edit_screen.dart';
import 'marks_entry_screen.dart';

class MarksViewScreen extends StatefulWidget {
  final String className;
  final String examName;

  const MarksViewScreen({
    required this.className,
    required this.examName,
  });

  @override
  _MarksViewScreenState createState() => _MarksViewScreenState();
}

class _MarksViewScreenState extends State<MarksViewScreen> {
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> studentMarks = {};
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    loadMarks();
  }

  Future<void> loadMarks() async {
    setState(() => isLoading = true);
    
    final data = await MarksService.getMarksByClass(
      standard: widget.className,
      examName: widget.examName,
    );
    
    List<dynamic> marks = data['marks'] ?? [];
    
    Map<String, List<Map<String, dynamic>>> grouped = {};
    Set<String> subjectSet = {};
    
    for (var mark in marks) {
      String studentId = mark['student_id'] ?? '';
      String firstName = mark['first_name'] ?? '';
      String rollNumber = mark['roll_number']?.toString() ?? '';
      String subjectName = mark['subject_name'] ?? '';
      
      subjectSet.add(subjectName);
      
      if (!grouped.containsKey(studentId)) {
        grouped[studentId] = [];
      }
      
      grouped[studentId]!.add({
        'first_name': firstName,
        'roll_number': rollNumber,
        'subject_name': subjectName,
        'marks_obtained': mark['marks_obtained'],
        'total_marks': mark['total_marks'],
      });
    }
    
    setState(() {
      studentMarks = grouped;
      subjects = subjectSet.toList()..sort();
      isLoading = false;
    });
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
            Text(widget.examName, style: TextStyle(fontSize: 16, color: Colors.white)),
            Text('Class ${widget.className}', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : studentMarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade400),
                      SizedBox(height: 16),
                      Text(
                        'No marks found',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: studentMarks.length,
                  itemBuilder: (context, index) {
                    String studentId = studentMarks.keys.elementAt(index);
                    List<Map<String, dynamic>> marks = studentMarks[studentId]!;
                    
                    String studentName = marks.first['first_name'] ?? '';
                    String rollNumber = marks.first['roll_number'] ?? '';
                    
                    int totalObtained = 0;
                    int totalMax = 0;
                    
                    for (var mark in marks) {
                      totalObtained += (mark['marks_obtained'] as int?) ?? 0;
                      totalMax += (mark['total_marks'] as int?) ?? 0;
                    }
                    
                    double percentage = totalMax > 0 ? (totalObtained / totalMax) * 100 : 0;
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Text(
                            rollNumber,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          studentName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Text(
                                'Total: $totalObtained/$totalMax',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                              ),
                              SizedBox(width: 12),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPercentageColor(percentage).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getPercentageColor(percentage),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        children: [
                          Divider(),
                          ...marks.map((mark) {
                            String subject = mark['subject_name'] ?? '';
                            int obtained = mark['marks_obtained'] ?? 0;
                            int total = mark['total_marks'] ?? 0;
                            double subPercentage = total > 0 ? (obtained / total) * 100 : 0;
                            
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      subject,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$obtained/$total',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getPercentageColor(subPercentage).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${subPercentage.toStringAsFixed(0)}%',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _getPercentageColor(subPercentage),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () async {
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudentMarksEditScreen(
                                      studentId: studentId,
                                      studentName: studentName,
                                      rollNumber: rollNumber,
                                      examName: widget.examName,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  loadMarks();
                                }
                              },
                              icon: Icon(Icons.edit, size: 18),
                              label: Text('Edit'),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: !isLoading && studentMarks.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MarksEntryScreen(
                      className: widget.className,
                      examName: widget.examName,
                    ),
                  ),
                );
                if (result == true) {
                  loadMarks();
                }
              },
              icon: Icon(Icons.add),
              label: Text('Add Marks'),
              backgroundColor: theme.primaryColor,
            )
          : null,
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }
}
