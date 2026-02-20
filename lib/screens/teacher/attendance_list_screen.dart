import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class AttendanceListScreen extends StatefulWidget {
  final String standard;
  final String division;
  final String filterStatus;

  AttendanceListScreen({
    required this.standard,
    required this.division,
    required this.filterStatus,
  });

  @override
  _AttendanceListScreenState createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  List<dynamic> attendanceList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    String? clientId = await AuthService.getClientId();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var result = await AttendanceService.getAttendance(
      clientId: clientId!,
      standard: widget.standard,
      division: widget.division,
      date: today,
    );

    List<dynamic> allList = result['list'] ?? [];
    List<dynamic> filtered = allList
        .where((item) => item.status == widget.filterStatus)
        .toList();

    setState(() {
      attendanceList = filtered;
      isLoading = false;
    });
  }

  Future<void> updateAttendanceStatus(String attendanceId, String currentStatus) async {
    String newStatus = currentStatus == "Present" ? "Absent" : "Present";
    
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Attendance"),
        content: Text("Change status from $currentStatus to $newStatus?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Update", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await AttendanceService.updateAttendance(
        attendanceId: attendanceId,
        status: newStatus,
        remark: "Updated by teacher",
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Attendance Updated to $newStatus")),
        );
        loadAttendance();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Update Attendance")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.filterStatus} Students"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : attendanceList.isEmpty
              ? Center(child: Text("No ${widget.filterStatus} Students"))
              : ListView.builder(
                  itemCount: attendanceList.length,
                  itemBuilder: (_, index) {
                    final attendance = attendanceList[index];
                    final student = attendance.student;
                    
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: widget.filterStatus == "Present"
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            widget.filterStatus == "Present"
                                ? Icons.check
                                : Icons.close,
                            color: widget.filterStatus == "Present"
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        title: Text(
                          "${student.firstName} ${student.middleName ?? ''} ${student.lastName}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Roll: ${student.rollNumber ?? '-'} | Division: ${student.division}",
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => updateAttendanceStatus(
                            attendance.id,
                            attendance.status,
                          ),
                          tooltip: "Change Status",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
