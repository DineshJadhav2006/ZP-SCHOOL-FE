import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../services/cache_service.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final String standard;
  final String division;
  final VoidCallback? onAttendanceSaved;

  AttendanceScreen({
    Key? key,
    required this.standard,
    required this.division,
    this.onAttendanceSaved,
  }) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with AutomaticKeepAliveClientMixin {

  List<dynamic> students = [];
  Map<String, String> attendanceMap = {};
  bool isAttendanceTaken = false;
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await checkAndLoadAttendance();
  }

  Future<void> checkAndLoadAttendance() async {
    String? clientId = await AuthService.getClientId();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      // Check if attendance already exists for today
      var result = await AttendanceService.getAttendance(
        clientId: clientId!,
        standard: widget.standard,
        division: widget.division,
        date: today,
      );

      // If attendance exists, load it
      if (result['total'] > 0) {
        List<dynamic> attendanceList = result['list'] ?? [];
        for (var attendance in attendanceList) {
          attendanceMap[attendance.studentId] = attendance.status;
        }
        setState(() {
          isAttendanceTaken = true;
        });
      }
    } catch (e) {
      // No attendance found, continue normally
    }

    await loadStudents();
  }

  Future<void> loadStudents() async {
    students = await StudentService.getStudents(widget.standard);

    // Set default to Present only if attendance not taken
    if (!isAttendanceTaken) {
      for (var s in students) {
        attendanceMap[s['id']] = "Present";
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveAttendance() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String? clientId = await AuthService.getClientId();
    String? teacherId = await AuthService.getTeacherId();

    List<Map<String, dynamic>> payload = [];

    attendanceMap.forEach((studentId, status) {
      payload.add({
        "client_id": clientId,
        "student_id": studentId,
        "teacher_id": teacherId,
        "date": today,
        "status": status
      });
    });

    bool success =
        await AttendanceService.createBulkAttendance(attendances: payload);

    if (success) {
      await CacheService.clearCache();
      setState(() {
        isAttendanceTaken = true;
      });
      if (widget.onAttendanceSaved != null) {
        widget.onAttendanceSaved!();
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Attendance Saved Successfully" : "Failed to Save Attendance"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 100),
                  itemCount: students.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final s = students[index];
                    String studentName = "${s['first_name']} ${s['last_name']}";
                    String studentId = s['id'];
                    String currentStatus = attendanceMap[studentId] ?? "Present";

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  s['roll_number']?.toString() ?? '?',
                                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName.trim(),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800),
                                  ),
                                  Text(
                                    "ID: ${s['unique_id'] ?? 'N/A'}",
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                            if (isAttendanceTaken)
                              _statusChip(currentStatus)
                            else
                              _buildToggleButtons(studentId, currentStatus),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: isAttendanceTaken
          ? null
          : FloatingActionButton.extended(
              onPressed: saveAttendance,
              backgroundColor: theme.primaryColor,
              icon: Icon(Icons.check_circle_outline),
              label: Text("Submit Attendance", style: TextStyle(fontWeight: FontWeight.bold)),
              elevation: 4,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text("No Students Found", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    bool isPresent = status == "Present";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isPresent ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildToggleButtons(String studentId, String currentStatus) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _attendanceIconButton(
          icon: Icons.check,
          color: Colors.green,
          isSelected: currentStatus == "Present",
          onTap: () => setState(() => attendanceMap[studentId] = "Present"),
        ),
        SizedBox(width: 12),
        _attendanceIconButton(
          icon: Icons.close,
          color: Colors.red,
          isSelected: currentStatus == "Absent",
          onTap: () => setState(() => attendanceMap[studentId] = "Absent"),
        ),
      ],
    );
  }

  Widget _attendanceIconButton({
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))] : [],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey.shade400,
          size: 20,
        ),
      ),
    );
  }
}
