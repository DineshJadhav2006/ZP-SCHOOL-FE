import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/student_service.dart';
import '../../services/marks_service.dart';
import '../../services/auth_service.dart';
import '../../models/marks.dart';

class MarksEntryScreen extends StatefulWidget {
  final String className;
  final String examName;

  const MarksEntryScreen({
    required this.className,
    required this.examName,
  });

  @override
  _MarksEntryScreenState createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  List<dynamic> students = [];
  Map<String, dynamic> existingMarks = {};
  bool isLoading = true;
  bool isSaving = false;
  
  List<Map<String, dynamic>> subjects = [
    {'name': 'Marathi', 'totalMarks': 100},
    {'name': 'English', 'totalMarks': 100},
    {'name': 'Mathematics', 'totalMarks': 100},
  ];
  Map<String, Map<String, TextEditingController>> controllers = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      await Future.wait([
        loadStudents(),
        loadExistingMarks(),
      ]);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> loadExistingMarks() async {
    final data = await MarksService.getMarksByClass(
      standard: widget.className,
      examName: widget.examName,
    );
    
    List<dynamic> marks = data['marks'] ?? [];
    Map<String, dynamic> marksMap = {};
    
    for (var mark in marks) {
      String studentId = mark['student_id'] ?? '';
      String subjectName = mark['subject_name'] ?? '';
      
      if (!marksMap.containsKey(studentId)) {
        marksMap[studentId] = {};
      }
      
      marksMap[studentId][subjectName] = {
        'marks_obtained': mark['marks_obtained'],
        'total_marks': mark['total_marks'],
      };
    }
    
    setState(() {
      existingMarks = marksMap;
      _prefillMarks();
    });
  }

  void _prefillMarks() {
    for (var student in students) {
      String studentId = student['id'] ?? '';
      String rollNo = student['roll_number']?.toString() ?? '';
      
      if (existingMarks.containsKey(studentId)) {
        Map<String, dynamic> studentMarks = existingMarks[studentId];
        
        for (var subject in subjects) {
          String subjectName = subject['name'];
          
          if (studentMarks.containsKey(subjectName)) {
            int marksObtained = studentMarks[subjectName]['marks_obtained'] ?? 0;
            controllers[rollNo]![subjectName]!.text = marksObtained.toString();
          }
        }
      }
    }
  }

  Future<void> loadStudents() async {
    final data = await StudentService.getStudents(widget.className);
    
    if (mounted) {
      setState(() {
        students = data;
        controllers.clear();
        for (var student in students) {
          String rollNo = student['roll_number']?.toString() ?? '';
          controllers[rollNo] = {};
          for (var subject in subjects) {
            controllers[rollNo]![subject['name']] = TextEditingController();
          }
        }
      });
    }
  }

  Future<void> saveMarks() async {
    List<StudentMarks> studentMarksList = [];
    
    for (var student in students) {
      String rollNo = student['roll_number']?.toString() ?? '';
      List<SubjectMarks> subjectMarks = [];
      
      bool hasMarks = false;
      for (var subject in subjects) {
        String subjectName = subject['name'];
        int totalMarks = subject['totalMarks'];
        String marksText = controllers[rollNo]![subjectName]!.text.trim();
        if (marksText.isNotEmpty) {
          hasMarks = true;
          subjectMarks.add(SubjectMarks(
            subjectName: subjectName,
            marksObtained: int.parse(marksText),
            totalMarks: totalMarks,
          ));
        }
      }
      
      if (hasMarks) {
        studentMarksList.add(StudentMarks(
          rollNumber: rollNo,
          subjects: subjectMarks,
        ));
      }
    }
    
    if (studentMarksList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter marks for at least one student')),
      );
      return;
    }
    
    setState(() => isSaving = true);
    
    String? teacherId = await AuthService.getTeacherId();
    debugPrint('Teacher ID: $teacherId');
    
    if (teacherId == null || teacherId.isEmpty) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teacher ID not found. Please login again.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    bool success = await MarksService.bulkSaveMarks(
      teacherId: teacherId,
      examName: widget.examName,
      students: studentMarksList,
    );
    
    setState(() => isSaving = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marks saved successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save marks'), backgroundColor: Colors.red),
      );
    }
  }

  void _showManageSubjectsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Manage Subjects'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      var subject = subjects[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject['name'],
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Total: ${subject['totalMarks']} marks',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                                onPressed: () => _editSubjectInline(index, setDialogState),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _deleteSubjectInline(index, setDialogState),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _addSubjectInline(setDialogState),
                  icon: Icon(Icons.add),
                  label: Text('Add New Subject'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _addSubjectInline(StateSetter setDialogState) {
    TextEditingController nameController = TextEditingController();
    TextEditingController marksController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: marksController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Marks',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setDialogState(() {
                  subjects.add({
                    'name': nameController.text.trim(),
                    'totalMarks': int.tryParse(marksController.text) ?? 100,
                  });
                  for (var student in students) {
                    String rollNo = student['roll_number']?.toString() ?? '';
                    controllers[rollNo]![nameController.text.trim()] = TextEditingController();
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editSubjectInline(int index, StateSetter setDialogState) {
    var subject = subjects[index];
    TextEditingController nameController = TextEditingController(text: subject['name']);
    TextEditingController marksController = TextEditingController(text: subject['totalMarks'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: marksController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Marks',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setDialogState(() {
                  String oldName = subjects[index]['name'];
                  subjects[index] = {
                    'name': nameController.text.trim(),
                    'totalMarks': int.tryParse(marksController.text) ?? 100,
                  };
                  if (oldName != nameController.text.trim()) {
                    for (var student in students) {
                      String rollNo = student['roll_number']?.toString() ?? '';
                      var oldController = controllers[rollNo]![oldName];
                      controllers[rollNo]!.remove(oldName);
                      controllers[rollNo]![nameController.text.trim()] = oldController ?? TextEditingController();
                    }
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteSubjectInline(int index, StateSetter setDialogState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subjects[index]['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setDialogState(() {
                String subjectName = subjects[index]['name'];
                subjects.removeAt(index);
                for (var student in students) {
                  String rollNo = student['roll_number']?.toString() ?? '';
                  controllers[rollNo]![subjectName]?.dispose();
                  controllers[rollNo]!.remove(subjectName);
                }
              });
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: _showManageSubjectsDialog,
          ),
          if (!isLoading)
            TextButton.icon(
              onPressed: isSaving ? null : saveMarks,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? Center(child: Text('No students found'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          String rollNo = student['roll_number']?.toString() ?? '';
                          String name = '${student['first_name'] ?? ''} ${student['last_name'] ?? ''}'.trim();
                          
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Roll: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text(rollNo, style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: subjects.asMap().entries.map((entry) {
                                        int idx = entry.key;
                                        var subject = entry.value;
                                        String subjectName = subject['name'];
                                        int totalMarks = subject['totalMarks'];
                                        return Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: Column(
                                            children: [
                                              Text(
                                                subjectName.length > 8 ? subjectName.substring(0, 8) : subjectName,
                                                style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                                              ),
                                              SizedBox(height: 4),
                                              SizedBox(
                                                width: 60,
                                                child: TextField(
                                                  key: ValueKey('$rollNo-$subjectName'),
                                                  controller: controllers[rollNo]![subjectName],
                                                  keyboardType: TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 13),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.digitsOnly,
                                                    LengthLimitingTextInputFormatter(3),
                                                  ],
                                                  decoration: InputDecoration(
                                                    hintText: '-',
                                                    labelText: '/$totalMarks',
                                                    labelStyle: TextStyle(fontSize: 9),
                                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
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
      floatingActionButton: !isLoading && students.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: "marks_entry_save_fab",
              onPressed: isSaving ? null : saveMarks,
              icon: isSaving ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.save),
              label: Text(isSaving ? 'Saving...' : 'Save Marks'),
              backgroundColor: theme.primaryColor,
            )
          : null,
    );
  }

  @override
  void dispose() {
    controllers.forEach((rollNo, subjectControllers) {
      subjectControllers.forEach((subject, controller) {
        controller.dispose();
      });
    });
    super.dispose();
  }
}
