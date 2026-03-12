import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Added

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

  Future<void> updateAttendanceStatus(
    String attendanceId,
    String currentStatus,
  ) async {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to Update Attendance")));
      }
    }
  }

  // NEW FUNCTION (Added)
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cannot make call")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = widget.filterStatus == "Present" ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("${widget.filterStatus} Students"),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : attendanceList.isEmpty
          ? _buildEmptyState(statusColor)
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: attendanceList.length,
              itemBuilder: (_, index) {
                final attendance = attendanceList[index];
                final student = attendance.student;

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.filterStatus == "Present" ? Icons.check : Icons.close,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      "${student.firstName} ${student.lastName}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Roll No: ${student.rollNumber ?? '-'}  •  Class: ${widget.standard}",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _actionButton(
                          Icons.call, 
                          Colors.green, 
                          () {
                            final String phone = student.mobileNumber;
                            if (phone.trim().isNotEmpty) {
                              makePhoneCall(phone);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Mobile number not available")),
                              );
                            }
                          },
                        ),
                        SizedBox(width: 8),
                        _actionButton(
                          Icons.edit_outlined, 
                          theme.primaryColor, 
                          () => updateAttendanceStatus(attendance.id, attendance.status),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildEmptyState(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.filterStatus == "Present" ? Icons.person_off_outlined : Icons.people_outline,
            size: 80,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: 16),
          Text(
            "No ${widget.filterStatus} Students found",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
