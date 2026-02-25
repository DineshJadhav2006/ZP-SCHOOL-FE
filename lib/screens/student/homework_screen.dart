import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/homework_service.dart';

class HomeworkScreen extends StatefulWidget {
  final String className;
  final Future<void> Function() onRefresh;

  const HomeworkScreen({
    required this.className,
    required this.onRefresh,
  });

  @override
  _HomeworkScreenState createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  DateTime? selectedDate;
  List<dynamic> homeworkList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadHomework();
  }

  Future<void> loadHomework() async {
    setState(() => isLoading = true);
    
    var data = await HomeworkService.getHomeworkByClass(widget.className, date: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null);
    
    // Filter to show only last 3 days by default (unless date filter is active)
    if (selectedDate == null) {
      DateTime now = DateTime.now();
      DateTime threeDaysAgo = DateTime(now.year, now.month, now.day).subtract(Duration(days: 2));
      data = data.where((hw) {
        String? dateStr = hw['homework_date'];
        if (dateStr == null) return false;
        try {
          DateTime hwDate = DateTime.parse(dateStr.split('T')[0]);
          return !hwDate.isBefore(threeDaysAgo);
        } catch (_) {
          return false;
        }
      }).toList();
    }
    
    setState(() {
      homeworkList = data;
      isLoading = false;
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  String formatDateTime(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      return DateFormat('dd MMM yyyy, hh:mm a')
          .format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  String teacherName(dynamic hw) {
    if (hw["teacher"] == null) return "";
    String first = hw["teacher"]["first_name"] ?? "";
    String last = hw["teacher"]["last_name"] ?? "";
    return "$first $last";
  }

  Future<void> openAttachment(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open attachment';
    }
  }

  bool isPdf(String url) {
    return url.toLowerCase().endsWith(".pdf");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: loadHomework,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Text(
                    "Homework",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(selectedDate != null ? Icons.filter_alt : Icons.filter_alt_outlined),
                    color: theme.primaryColor,
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                        loadHomework();
                      }
                    },
                    tooltip: "Filter by Date",
                  ),
                  if (selectedDate != null)
                    IconButton(
                      icon: Icon(Icons.clear),
                      color: Colors.red,
                      onPressed: () {
                        setState(() => selectedDate = null);
                        loadHomework();
                      },
                      tooltip: "Clear Filter",
                    ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : homeworkList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey.shade300),
                              SizedBox(height: 16),
                              Text("No homework assigned", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          ),
                        )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: homeworkList.length,
                    itemBuilder: (context, index) {
                      final hw = homeworkList[index];
                      final attachment = hw["attachment_url"];
                      final subjectColor = _getSubjectColor(hw["subject_name"] ?? "");

                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subject Header
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: subjectColor.withOpacity(0.1),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.book_outlined, color: subjectColor, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    hw["subject_name"] ?? "Subject",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: subjectColor,
                                    ),
                                  ),
                                  Spacer(),
                                  if (attachment != null && attachment.toString().isNotEmpty)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => openAttachment(attachment),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(isPdf(attachment) ? Icons.picture_as_pdf : Icons.image, 
                                                color: Colors.red, size: 14),
                                              SizedBox(width: 4),
                                              Text("View", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _infoTag(Icons.event_available, "Due: ${formatDate(hw["homework_date"])}", Colors.orange),
                                      SizedBox(width: 12),
                                      _infoTag(Icons.person_outline, teacherName(hw), theme.primaryColor),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    hw["homework_text"] ?? "-",
                                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                                  ),
                                  SizedBox(height: 16),
                                  Divider(height: 1, color: Colors.grey.shade100),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                                      SizedBox(width: 4),
                                      Text(
                                        "Assigned: ${formatDateTime(hw["created_on"])}",
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTag(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.7)),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    subject = subject.toLowerCase();
    if (subject.contains("math")) return Colors.blue;
    if (subject.contains("science")) return Colors.green;
    if (subject.contains("english")) return Colors.orange;
    if (subject.contains("marathi") || subject.contains("hindi")) return Colors.purple;
    if (subject.contains("history") || subject.contains("geography")) return Colors.brown;
    return Colors.indigo;
  }
}