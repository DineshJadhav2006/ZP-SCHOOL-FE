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
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book, color: theme.primaryColor, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hw["subject_name"] ?? "Subject",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      Text(
                        formatDate(hw["homework_date"]),
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _actionButton(
                  icon: Icons.edit_outlined,
                  color: Colors.blue,
                  onTap: () async {
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditHomeworkScreen(homework: hw),
                      ),
                    );
                    if (result == true) loadHomework();
                  },
                ),
                SizedBox(width: 8),
                _actionButton(
                  icon: Icons.delete_outline,
                  color: Colors.red,
                  onTap: () => deleteHomework(hw["id"]),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              hw["homework_text"] ?? "",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
            ),
            SizedBox(height: 16),
            Divider(height: 1),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  "By: ${hw["teacher"]?["first_name"] ?? ""} ${hw["teacher"]?["last_name"] ?? ""}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                Spacer(),
                if (hw["attachment_url"] != null && hw["attachment_url"].isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file, size: 14, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          "Files",
                          style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadHomework,
              child: homeworkList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      itemCount: homeworkList.length,
                      itemBuilder: (context, index) {
                        return homeworkCard(homeworkList[index]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddHomeworkScreen(className: widget.className),
            ),
          );
          if (result == true) loadHomework();
        },
        backgroundColor: theme.primaryColor,
        icon: Icon(Icons.add),
        label: Text("Post Homework", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            "No Homework Posted",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
