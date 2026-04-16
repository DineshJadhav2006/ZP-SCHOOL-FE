import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/student_service.dart';
import 'student_profile_screen.dart';
import 'edit_student_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String standard;

  StudentListScreen({required this.standard});

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List students = [];
  List filteredStudents = [];
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  void loadStudents() async {
    setState(() => isLoading = true);
    
    debugPrint("Loading students for class: ${widget.standard}");
    var data = await StudentService.getStudents(widget.standard);
    debugPrint("Students loaded: ${data.length}");
    debugPrint("First student: ${data.isNotEmpty ? data[0] : 'No students'}");

    setState(() {
      students = data;
      filteredStudents = data;
      isLoading = false;
    });
    
    debugPrint("UI updated - students: ${students.length}, filtered: ${filteredStudents.length}");
  }

  void searchStudent(String value) {
    setState(() {
      filteredStudents = students.where((s) {
        String name = "${s["first_name"]} ${s["middle_name"] ?? ''} ${s["last_name"]}".toLowerCase();
        String uniqueId = (s["unique_id"] ?? "").toLowerCase();
        return name.contains(value.toLowerCase()) || uniqueId.contains(value.toLowerCase());
      }).toList();
    });
  }

  // स्टुडंट कार्ड - एनहॅन्स्ड डिटेल्स आणि इंटरॅक्टिव्हिटी
  Widget _buildStudentCard(Map<String, dynamic> student) {
    String firstName = student["first_name"] ?? "";
    String lastName = student["last_name"] ?? "";
    String fullName = "$firstName ${student["middle_name"] ?? ''} $lastName".trim();
    String rollNumber = student["roll_number"]?.toString() ?? '-';
    String uniqueId = student["unique_id"] ?? '-';
    String gender = student["gender"] ?? 'Not specified';
    
    // DOB फॉरमॅटिंग - फकत तारीख दाखवा (T00:00:00.000Z काढा)
    String dob = student["date_of_birth"] ?? 'N/A';
    if (dob.contains('T')) {
      dob = dob.split('T')[0];
    }
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentProfileScreen(studentId: student["id"]),
            ),
          );
        },
        onLongPress: () => _showStudentActions(student),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gender.toLowerCase() == 'female' 
                            ? [Colors.pink.shade100, Colors.pink.shade50] 
                            : [Colors.blue.shade100, Colors.blue.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: gender.toLowerCase() == 'female' 
                              ? Colors.pink.shade700 
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            'ID: $uniqueId',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Text(
                          rollNumber == '-' || rollNumber.isEmpty ? 'Roll -' : 'Roll #$rollNumber',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.person, 
                          label: gender,
                          color: Colors.orange.shade800,
                          bgColor: Colors.orange.shade50,
                        ),
                        SizedBox(width: 10),
                        _buildInfoChip(
                          icon: Icons.cake, 
                          label: dob,
                          color: Colors.teal.shade800,
                          bgColor: Colors.teal.shade50,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // हेल्पर्स फॉर न्यू कार्ड डिझाइन
  Widget _buildInfoChip({
    required IconData icon, 
    required String label, 
    required Color color, 
    required Color bgColor
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12, 
                color: color,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentActions(Map<String, dynamic> student) {
    String name = "${student['first_name']} ${student['last_name']}";
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text("View Profile"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentProfileScreen(studentId: student["id"]),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.orange),
                title: Text("Edit Student"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditStudentScreen(student: student),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Delete Student"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(student);
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Class ${widget.standard} - Students"),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadStudents,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => loadStudents(),
              child: Column(
                children: [
                  _buildSearchBar(theme),
                  _buildSummaryInfo(theme),
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? _buildEmptyState()
                        : AnimationLimiter(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.all(12),
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 500),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: _buildStudentCard(filteredStudents[index]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new student functionality
          // तुम्ही तुमची add student स्क्रीन येथे ओपन करू शकता
        },
        heroTag: "teacher_add_student_fab",
        child: Icon(Icons.add),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
      color: Colors.white,
      child: TextField(
        controller: searchController,
        onChanged: searchStudent,
        decoration: InputDecoration(
          hintText: "Search students by name or ID...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: theme.primaryColor, size: 20),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    ).animate().slideY(begin: -0.2, duration: 400.ms).fadeIn();
  }

  Widget _buildSummaryInfo(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.people_outline, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            "${students.length} Students Enrolled",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade200),
          SizedBox(height: 16),
          Text("No students match your search", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> student) {
    String name = "${student['first_name']} ${student['last_name']}";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Student"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await StudentService.deleteStudent(student['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Student deleted successfully")),
                );
                loadStudents();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete student"), backgroundColor: Colors.red),
                );
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}