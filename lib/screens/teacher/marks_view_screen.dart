import 'package:flutter/material.dart';
import '../../services/marks_service.dart';
import 'student_marks_edit_screen.dart';
import 'marks_entry_screen.dart';
import 'student_profile_screen.dart';
import '../../utils/common_extensions.dart';

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
  List<Map<String, dynamic>> filteredStudents = [];
  List<String> subjects = [];
  String searchQuery = "";
  String sortBy = "Percentage"; 
  bool isAscending = false;

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
        'student_id': studentId,
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
      _prepareFilteredList();
      isLoading = false;
    });
  }

  void _prepareFilteredList() {
    List<Map<String, dynamic>> list = [];
    
    studentMarks.forEach((id, marks) {
      String name = marks.first['first_name'] ?? '';
      String roll = marks.first['roll_number'] ?? '';
      
      int totalObtained = 0;
      int totalMax = 0;
      for (var mark in marks) {
        totalObtained += (mark['marks_obtained'] as int?) ?? 0;
        totalMax += (mark['total_marks'] as int?) ?? 0;
      }
      double percentage = totalMax > 0 ? (totalObtained / totalMax) * 100 : 0;

      if (name.toLowerCase().contains(searchQuery.toLowerCase()) || 
          roll.contains(searchQuery)) {
        list.add({
          'student_id': id,
          'name': name,
          'roll': roll,
          'marks': marks,
          'totalObtained': totalObtained,
          'totalMax': totalMax,
          'percentage': percentage,
        });
      }
    });

    _sortList(list);
    filteredStudents = list;
  }

  void _sortList(List<Map<String, dynamic>> list) {
    if (sortBy == "Roll Number") {
      list.sort((a, b) {
        int rollA = int.tryParse(a['roll']) ?? 0;
        int rollB = int.tryParse(b['roll']) ?? 0;
        return isAscending ? rollA.compareTo(rollB) : rollB.compareTo(rollA);
      });
    } else if (sortBy == "Percentage") {
      list.sort((a, b) => isAscending 
          ? a['percentage'].compareTo(b['percentage']) 
          : b['percentage'].compareTo(a['percentage']));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.indigo;
    
    double classAvg = 0;
    if (filteredStudents.isNotEmpty) {
      classAvg = filteredStudents.map((s) => s['percentage'] as double).reduce((a, b) => a + b) / filteredStudents.length;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading 
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: themeColor,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [themeColor, themeColor.darken(0.2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 60),
                          Text(
                            widget.examName,
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Class ${widget.className}",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem("Students", filteredStudents.length.toString(), Icons.people_outline),
                              _buildStatItem("Class Avg", "${classAvg.toStringAsFixed(1)}%", Icons.analytics_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  iconTheme: IconThemeData(color: Colors.white),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSearchBar(themeColor),
                      ],
                    ),
                  ),
                ),
                filteredStudents.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                              Text("No students found", style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildStudentCard(filteredStudents[index], themeColor),
                            childCount: filteredStudents.length,
                          ),
                        ),
                      ),
                SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: !isLoading && studentMarks.isEmpty
          ? FloatingActionButton.extended(
              heroTag: "marks_view_add_fab",
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
                if (result == true) loadMarks();
              },
              icon: Icon(Icons.add),
              label: Text('Add Marks'),
              backgroundColor: themeColor,
            )
          : null,
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSearchBar(Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: TextField(
        onChanged: (v) => setState(() {
          searchQuery = v;
          _prepareFilteredList();
        }),
        decoration: InputDecoration(
          hintText: "Search student by name or roll...",
          prefixIcon: Icon(Icons.search, color: themeColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }


  Widget _buildStudentCard(Map<String, dynamic> student, Color themeColor) {
    final double percentage = student['percentage'];
    final color = _getPercentageColor(percentage);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StudentProfileScreen(studentId: student['student_id'])),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: ExpansionTile(
            tilePadding: EdgeInsets.all(16),
            childrenPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: themeColor.withValues(alpha: 0.1),
              child: Text(student['roll'], style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
            ),
            title: Text(student['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: color.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text("${percentage.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
              ],
            ),
            children: [
              Divider(),
              ... (student['marks'] as List).map((mark) => _buildSubjectRow(mark)).toList(),
              SizedBox(height: 16),
              _buildActionButton(student, themeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectRow(Map<String, dynamic> mark) {
    double subPerc = (mark['total_marks'] > 0) ? (mark['marks_obtained'] / mark['total_marks']) * 100 : 0;
    Color subColor = _getPercentageColor(subPerc);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(mark['subject_name'], style: TextStyle(fontWeight: FontWeight.w600))),
          Text("${mark['marks_obtained']}/${mark['total_marks']}", style: TextStyle(color: Colors.grey.shade700)),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: subColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Text("${subPerc.toStringAsFixed(0)}%", style: TextStyle(color: subColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> student, Color themeColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentMarksEditScreen(
                studentId: student['student_id'],
                studentName: student['name'],
                rollNumber: student['roll'],
                examName: widget.examName,
              ),
            ),
          );
          if (result == true) loadMarks();
        },
        icon: Icon(Icons.edit_outlined, size: 18),
        label: Text("Edit Marks"),
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return Colors.green.shade600;
    if (percentage >= 60) return Colors.blue.shade600;
    if (percentage >= 40) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}
