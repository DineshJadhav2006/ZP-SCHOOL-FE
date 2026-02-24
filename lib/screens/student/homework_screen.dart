import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeworkScreen extends StatelessWidget {
  final List<dynamic> homeworkList;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const HomeworkScreen({
    required this.homeworkList,
    required this.isLoading,
    required this.onRefresh,
  });

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
      onRefresh: onRefresh,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: isLoading
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