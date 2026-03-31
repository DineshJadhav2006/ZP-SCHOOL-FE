import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../teacher/add_student_screen.dart';
import 'edit_student_screen.dart';
import '../teacher/student_marks_view_screen.dart';
import 'admin_class_results_screen.dart';
import '../teacher/student_profile_screen.dart'; // Import added
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/common_extensions.dart';

class AdminStudentsScreen extends StatefulWidget {
  final int totalStudents;

  const AdminStudentsScreen({required this.totalStudents});

  @override
  _AdminStudentsScreenState createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  String? selectedClass = "1st";
  List<dynamic> students = [];
  List<dynamic> attendanceList = [];
  bool isLoading = false;
  int totalStudents = 0;
  int todayPresent = 0;
  int todayAbsent = 0;

  final List<String> classes = [
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th"
  ];

  @override
  void initState() {
    super.initState();
    loadClassData(selectedClass!);
  }

  Future<void> loadClassData(String className) async {
    if (!mounted) return;
    
    try {
      await Future.wait([
        loadStudents(className),
        loadTodayAttendance(className),
      ]);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> loadStudents(String className) async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      var data = await StudentService.getStudents(className);
      if (mounted) {
        setState(() {
          students = data;
          totalStudents = data.length;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          students = [];
          totalStudents = 0;
          isLoading = false;
        });
      }
    }
  }

  Future<void> loadTodayAttendance(String className) async {
    try {
      String? clientId = await AuthService.getClientId();
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      var result = await AttendanceService.getAttendance(
        clientId: clientId!,
        standard: className,
        division: "A",
        date: today,
      );

      setState(() {
        todayPresent = result['present'] ?? 0;
        todayAbsent = result['absent'] ?? 0;
        attendanceList = result['list'] ?? [];
      });
    } catch (e) {
      print("Error loading attendance: $e");
      setState(() {
        todayPresent = 0;
        todayAbsent = 0;
        attendanceList = [];
      });
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => loadClassData(selectedClass!),
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        "Total",
                                        totalStudents.toString(),
                                        theme.primaryColor,
                                        Icons.people_outline,
                                        () {},
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        "Present",
                                        todayPresent.toString(),
                                        Colors.green,
                                        Icons.check_circle_outline,
                                        () => _showFilteredStudents("Present"),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        "Absent",
                                        todayAbsent.toString(),
                                        Colors.red,
                                        Icons.highlight_off,
                                        () => _showFilteredStudents("Absent"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return _buildStudentCard(students[index], theme);
                                  },
                                  childCount: students.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, ThemeData theme) {
    String firstName = student["first_name"] ?? "";
    String lastName = student["last_name"] ?? "";
    String fullName = "$firstName ${student["middle_name"] ?? ''} $lastName".trim();
    String rollNumber = student["roll_number"]?.toString() ?? '-';
    String uniqueId = student["unique_id"] ?? '-';
    String gender = student["gender"] ?? 'Not specified';
    
    String dob = student["date_of_birth"] ?? 'N/A';
    if (dob.contains('T')) {
      dob = dob.split('T')[0];
    }
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      child: InkWell(
        onTap: () => _showStudentDetails(student),
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
                          color: Colors.black.withOpacity(0.04),
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

  void _showStudentDetails(Map<String, dynamic> student) {
    String firstName = student["first_name"] ?? "";
    String lastName = student["last_name"] ?? "";
    String fullName = "$firstName ${student["middle_name"] ?? ''} $lastName".trim();
    final primaryColor = Colors.indigo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1.0,
        maxChildSize: 1.0,
        minChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
          ),
          child: Column(
            children: [
              // Custom App Bar for Full Screen
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8, right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Student Profile",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: primaryColor.withOpacity(0.1),
                              child: Text(
                                firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
                                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            fullName,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Class ${student['standard'] ?? selectedClass} - ${student['division'] ?? 'A'}",
                            style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(
                          icon: Icons.call_outlined,
                          label: "Call Parent",
                          color: Colors.green,
                          onTap: () => _makePhoneCall(student['mobile_number']),
                        ),
                        _actionButton(
                          icon: Icons.edit_outlined,
                          label: "Edit",
                          color: Colors.blue,
                          onTap: () async {
                            Navigator.pop(context);
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditStudentScreen(student: student)),
                            );
                            if (result == true) loadClassData(selectedClass!);
                          },
                        ),
                        _actionButton(
                          icon: Icons.delete_outline,
                          label: "Delete",
                          color: Colors.red,
                          onTap: () {
                            Navigator.pop(context);
                            _confirmDelete(student);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Academic Information
                    _sectionTitle("Academic Information", Icons.school_outlined),
                    _infoCard([
                      _infoRow(Icons.fingerprint, "Unique ID", student['unique_id'] ?? '-'),
                      _infoRow(Icons.badge_outlined, "Student ID", student['student_id']?.toString() ?? '-'),
                      _infoRow(Icons.numbers_outlined, "G.R. Number", student['general_register_no']?.toString() ?? '-'),
                      _infoRow(Icons.tag, "Roll Number", student['roll_number']?.toString() ?? '-'),
                      _infoRow(Icons.calendar_today_outlined, "Admission Date", _formatDateInternal(student['admission_date'])),
                      _infoRow(Icons.category_outlined, "Category", student['category'] ?? 'General'),
                    ]),

                    SizedBox(height: 20),
                    // Personal Information
                    _sectionTitle("Personal Information", Icons.person_outline),
                    _infoCard([
                      _infoRow(Icons.credit_card_outlined, "Aadhar Number", student['aadhar_number'] ?? '-'),
                      _infoRow(student['gender']?.toString().toLowerCase() == 'female' ? Icons.female : Icons.male, 
                        "Gender", student['gender']?.toString().capitalize() ?? 'Not Specified'),
                      _infoRow(Icons.cake_outlined, "Date of Birth", _formatDateInternal(student['date_of_birth'])),
                    ]),

                    SizedBox(height: 20),
                    // Parent & Contact Details
                    _sectionTitle("Parent & Contact Details", Icons.contact_phone_outlined),
                    _infoCard([
                      _infoRow(Icons.face_outlined, "Father/Parent Name", student['parent_name'] ?? '-'),
                      _infoRow(Icons.person_outline, "Mother's Name", student['mothers_name'] ?? '-'),
                      _infoRow(Icons.phone_android_outlined, "Mobile", student['mobile_number'] ?? '-', 
                        trailing: Icon(Icons.call, color: Colors.green, size: 18),
                        onTap: () => _makePhoneCall(student['mobile_number'])),
                      _infoRow(Icons.location_on_outlined, "Address", student['address'] ?? '-'),
                    ]),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: Colors.grey.shade600),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  String _formatDateInternal(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      if (dateStr.contains('T')) {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
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
                  _showStudentDetails(student);
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
                  ).then((value) {
                    if (value == true) loadClassData(selectedClass!);
                  });
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

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school_rounded, color: theme.primaryColor, size: 24),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Student Directory",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "Class $selectedClass",
                      style: TextStyle(
                        color: Colors.grey.shade600, 
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    InkWell(
                      onTap: _showClassSelector,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Change",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.unfold_more_rounded, color: theme.primaryColor, size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddStudentScreen(standard: selectedClass!)),
              );
              if (result == true) loadClassData(selectedClass!);
            },
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_add_rounded, color: Colors.indigo.shade700, size: 20),
            ),
            tooltip: "Add Student",
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
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            "No students found in $selectedClass",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          height: 100,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilteredStudents(String status) {
    var filtered = attendanceList.where((att) => att.status == status).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$status Students - $selectedClass"),
        content: Container(
          width: double.maxFinite,
          child: filtered.isEmpty
              ? Center(child: Text("No $status students today"))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    var att = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: status == "Present"
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          status == "Present" ? Icons.check : Icons.close,
                          color: status == "Present" ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(att.student.fullName),
                      subtitle: Text("Roll: ${att.student.rollNumber ?? '-'}"),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showClassSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Select Class",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Choose a class to manage students",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  String className = classes[index];
                  bool isSelected = className == selectedClass;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => selectedClass = className);
                        loadClassData(className);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.blue.shade200 : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue.shade100 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.class_rounded,
                                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              className,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.blue.shade900 : Colors.black87,
                              ),
                            ),
                            Spacer(),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: Colors.blue.shade700, size: 28),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
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
                loadClassData(selectedClass!);
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
