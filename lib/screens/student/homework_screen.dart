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
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : homeworkList.isEmpty
              ? Center(child: Text("No homework assigned"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: homeworkList.length,
                  itemBuilder: (context, index) {
                    final hw = homeworkList[index];
                    final attachment = hw["attachment_url"];

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subject + View Icon
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  hw["subject_name"] ?? "Subject",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),

                                // Attachment Icon
                                if (attachment != null &&
                                    attachment.toString().isNotEmpty)
                                  IconButton(
                                    icon: Icon(
                                      isPdf(attachment)
                                          ? Icons.picture_as_pdf
                                          : Icons.image,
                                      color: Colors.red,
                                    ),
                                    tooltip: "View Attachment",
                                    onPressed: () {
                                      openAttachment(attachment);
                                    },
                                  ),
                              ],
                            ),

                            SizedBox(height: 8),

                            // Homework Date
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Due: ${formatDate(hw["homework_date"])}",
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            // Homework Text
                            Text(
                              hw["homework_text"] ?? "-",
                              style: TextStyle(fontSize: 15),
                            ),

                            SizedBox(height: 12),

                            // Teacher + Created Time
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "By: ${teacherName(hw)}",
                                    style:
                                        TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 4),

                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 6),
                                Text(
                                  "Created: ${formatDateTime(hw["created_on"])}",
                                  style:
                                      TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}