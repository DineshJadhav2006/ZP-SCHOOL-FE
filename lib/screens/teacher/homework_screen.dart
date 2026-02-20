import 'package:flutter/material.dart';
import '../../services/homework_service.dart';
import 'add_homework_screen.dart';
import 'edit_homework_screen.dart';
import 'package:intl/intl.dart';

class HomeworkScreen extends StatefulWidget {
  final String className;

  HomeworkScreen({required this.className});

  @override
  _HomeworkScreenState createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  List<dynamic> homeworkList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHomework();
  }

  Future<void> loadHomework() async {
    setState(() => isLoading = true);
    var data = await HomeworkService.getHomeworkByClass(widget.className);
    setState(() {
      homeworkList = data;
      isLoading = false;
    });
  }

  Future<void> deleteHomework(String homeworkId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Homework"),
        content: Text("Are you sure you want to delete this homework?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await HomeworkService.deleteHomework(homeworkId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Homework Deleted Successfully")),
        );
        loadHomework();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Delete Homework")),
        );
      }
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget homeworkCard(Map<String, dynamic> hw) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hw["subject_name"] ?? "Subject",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () async {
                        bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditHomeworkScreen(homework: hw),
                          ),
                        );
                        if (result == true) {
                          loadHomework();
                        }
                      },
                      tooltip: "Edit",
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => deleteHomework(hw["id"]),
                      tooltip: "Delete",
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formatDate(hw["homework_date"]),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              hw["homework_text"] ?? "",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  "By: ${hw["teacher"]?["first_name"] ?? ""} ${hw["teacher"]?["last_name"] ?? ""}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            if (hw["attachment_url"] != null && hw["attachment_url"].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Attachment",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadHomework,
              child: homeworkList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No Homework Found",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: homeworkList.length,
                      itemBuilder: (context, index) {
                        return homeworkCard(homeworkList[index]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddHomeworkScreen(className: widget.className),
            ),
          );
          if (result == true) {
            loadHomework();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
