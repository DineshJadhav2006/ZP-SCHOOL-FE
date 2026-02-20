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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: students.isEmpty
                      ? Center(child: Text("No Students Found"))
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (_, index) {
                            final s = students[index];
                            String studentName =
                                "${s['first_name']} ${s['middle_name'] ?? ''} ${s['last_name']}";
                            String studentId = s['id'];
                            String currentStatus = attendanceMap[studentId] ?? "Present";

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  s['roll_number']?.toString() ?? '?',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(studentName.trim()),
                              subtitle: Text("Div: ${s['division']}"),
                              trailing: isAttendanceTaken
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: currentStatus == "Present"
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        currentStatus,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: currentStatus == "Present"
                                              ? Colors.green.shade900
                                              : Colors.red.shade900,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.check_circle,
                                            color: currentStatus == "Present"
                                                ? Colors.green
                                                : Colors.grey,
                                            size: 32,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              attendanceMap[studentId] = "Present";
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.cancel,
                                            color: currentStatus == "Absent"
                                                ? Colors.red
                                                : Colors.grey,
                                            size: 32,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              attendanceMap[studentId] = "Absent";
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isAttendanceTaken) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Attendance Already Taken"),
                content: Text("Attendance has already been recorded for today."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              ),
            );
          } else {
            saveAttendance();
          }
        },
        backgroundColor: Colors.blue,
        icon: Icon(Icons.save),
        label: Text("Save Attendance"),
      ),
    );
  }
}
