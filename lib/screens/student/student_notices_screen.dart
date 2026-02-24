import 'package:flutter/material.dart';
import '../../services/notice_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentNoticesScreen extends StatefulWidget {
  @override
  _StudentNoticesScreenState createState() => _StudentNoticesScreenState();
}

class _StudentNoticesScreenState extends State<StudentNoticesScreen> {
  List<dynamic> notices = [];
  bool isLoading = true;
  String? studentClass;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadNotices();
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_notices', 0);
    await prefs.setString('last_notice_check', DateTime.now().toIso8601String());
  }

  Future<void> loadNotices() async {
    setState(() => isLoading = true);
    
    // Get student's class
    var studentData = await AuthService.getStudentData();
    studentClass = studentData?['standard'];
    
    String? dateStr = selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null;
    var result = await NoticeService.getNotices(date: dateStr, limit: 50);
    List<dynamic> allNotices = result['data'];
    
    // Filter to show only last 7 days by default (unless date filter is active)
    if (selectedDate == null) {
      DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      allNotices = allNotices.where((notice) {
        String? dateStr = notice['notice_date'];
        if (dateStr == null) return false;
        try {
          DateTime noticeDate = DateTime.parse(dateStr);
          return noticeDate.isAfter(sevenDaysAgo) || noticeDate.isAtSameMomentAs(sevenDaysAgo);
        } catch (_) {
          return false;
        }
      }).toList();
    }
    
    // Filter notices for student
    List<dynamic> filteredNotices = allNotices.where((notice) {
      String role = notice['role'] ?? '';
      String? className = notice['class_name'];
      
      // Show if role is "all" or "student"
      if (role == 'all') return true;
      if (role == 'student') {
        // Show if no specific class or matches student's class
        if (className == null || className.isEmpty) return true;
        if (className == studentClass) return true;
      }
      return false;
    }).toList();
    
    setState(() {
      notices = filteredNotices;
      isLoading = false;
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return "-";
    }
  }

  String formatDateTime(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      print("Error parsing date: $dateStr, error: $e");
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("School Notices"),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(selectedDate != null ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
                loadNotices();
              }
            },
            tooltip: "Filter by Date",
          ),
          if (selectedDate != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() => selectedDate = null);
                loadNotices();
              },
              tooltip: "Clear Filter",
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No notices found", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadNotices,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      var notice = notices[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                          border: Border.all(color: Colors.grey.shade100, width: 1),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showNoticeDetails(notice),
                          child: Padding(
                            padding: EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notice['title'] ?? '-',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  notice['description'] ?? '-',
                                  style: TextStyle(color: Colors.grey.shade600, height: 1.4, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 18),
                                Row(
                                  children: [
                                    _metaInfo(Icons.event_note_rounded, formatDate(notice['notice_date'])),
                                    SizedBox(width: 16),
                                    _metaInfo(Icons.history_rounded, formatDateTime(notice['created_at']).split(',').last.trim()),
                                    Spacer(),
                                    _metaInfo(Icons.person_pin_circle_rounded, 
                                      "${notice['creator']?['first_name'] ?? ''}".trim(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _metaInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showNoticeDetails(Map<String, dynamic> notice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notice['title'] ?? '-'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notice['description'] ?? '-',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              _detailRow("Date", formatDate(notice['notice_date'])),
              _detailRow(
                "From",
                "${notice['creator']?['first_name'] ?? ''} ${notice['creator']?['last_name'] ?? ''}".trim(),
              ),
              _detailRow("Created At", formatDateTime(notice['created_at'])),
            ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
