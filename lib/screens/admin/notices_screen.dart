import 'package:flutter/material.dart';
import '../../services/notice_service.dart';
import 'send_notice_screen.dart';
import 'package:intl/intl.dart';

class NoticesScreen extends StatefulWidget {
  @override
  _NoticesScreenState createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  List<dynamic> notices = [];
  bool isLoading = true;
  int total = 0;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadNotices();
  }

  Future<void> loadNotices() async {
    setState(() => isLoading = true);
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
    
    setState(() {
      notices = allNotices;
      total = result['total'];
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

  String getRoleText(String? role, String? className) {
    if (role == "all") return "Everyone";
    if (role == "teacher") return "Teachers";
    if (role == "student") {
      if (className != null) return "Students - $className";
      return "All Students";
    }
    return role ?? "-";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade300),
                      SizedBox(height: 16),
                      Text("No notices found", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadNotices,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      var notice = notices[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => _showNoticeDetails(notice),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          getRoleText(notice['role'], notice['class_name']),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      _buildActionMenu(notice),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    notice['description'] ?? '-',
                                    style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _metaInfo(Icons.event, formatDate(notice['notice_date'])),
                                      SizedBox(width: 16),
                                      _metaInfo(Icons.history, formatDateTime(notice['created_at']).split(',').last.trim()),
                                      Spacer(),
                                      _metaInfo(Icons.person_outline, 
                                        "${notice['creator']?['first_name'] ?? ''}".trim(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: "admin_notices_fab",
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SendNoticeScreen()),
          );
          if (result == true) loadNotices();
        },
        backgroundColor: theme.primaryColor,
        elevation: 6,
        child: Icon(Icons.add_comment, color: Colors.white),
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

  Widget _buildActionMenu(Map<String, dynamic> notice) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade400),
      onSelected: (value) {
        if (value == 'edit') _editNotice(notice);
        if (value == 'delete') _deleteNotice(notice);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit', 
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text("Edit"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete', 
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text("Delete", style: TextStyle(color: Colors.red)),
            ],
          ),
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
              _detailRow("Sent To", getRoleText(notice['role'], notice['class_name'])),
              _detailRow(
                "Created By",
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
            width: 100,
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

  void _editNotice(Map<String, dynamic> notice) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SendNoticeScreen(notice: notice),
      ),
    );
    if (result == true) {
      setState(() => isLoading = true);
      await loadNotices();
    }
  }

  void _deleteNotice(Map<String, dynamic> notice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Notice"),
        content: Text("Are you sure you want to delete this notice?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              bool success = await NoticeService.deleteNotice(notice['id']);
              if (success) {
                await loadNotices();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Notice deleted successfully")),
                );
              } else {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete notice")),
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
