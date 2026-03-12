import 'package:flutter/material.dart';
import '../../services/homework_service.dart';
import 'package:intl/intl.dart';

class EditHomeworkScreen extends StatefulWidget {
  final Map<String, dynamic> homework;

  EditHomeworkScreen({required this.homework});

  @override
  _EditHomeworkScreenState createState() => _EditHomeworkScreenState();
}

class _EditHomeworkScreenState extends State<EditHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController subjectName;
  late TextEditingController homeworkText;
  late TextEditingController attachmentUrl;
  
  DateTime? homeworkDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    subjectName = TextEditingController(text: widget.homework["subject_name"]);
    homeworkText = TextEditingController(text: widget.homework["homework_text"]);
    attachmentUrl = TextEditingController(text: widget.homework["attachment_url"] ?? "");
    
    try {
      homeworkDate = DateTime.parse(widget.homework["homework_date"]);
    } catch (e) {
      homeworkDate = DateTime.now();
    }
  }

  Future<void> selectHomeworkDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: homeworkDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => homeworkDate = picked);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Future<void> updateHomework() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    bool success = await HomeworkService.updateHomework(
      homeworkId: widget.homework["id"],
      className: widget.homework["class_name"],
      subjectName: subjectName.text,
      homeworkText: homeworkText.text,
      homeworkDate: DateFormat('yyyy-MM-dd').format(homeworkDate!),
      attachmentUrl: attachmentUrl.text.isEmpty ? null : attachmentUrl.text,
    );

    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Homework Updated Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Update Homework")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Edit Homework"),
        backgroundColor: Colors.white,
        foregroundColor: theme.primaryColor,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormSection(
                      "Task Details",
                      [
                        TextFormField(
                          controller: subjectName,
                          decoration: InputDecoration(
                            labelText: "Subject Name *",
                            prefixIcon: Icon(Icons.book_outlined),
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: homeworkText,
                          decoration: InputDecoration(
                            labelText: "Homework Description *",
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          maxLines: 4,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildFormSection(
                      "Schedule & Attachments",
                      [
                        InkWell(
                          onTap: selectHomeworkDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Homework Date *",
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              formatDate(homeworkDate),
                              style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: attachmentUrl,
                          decoration: InputDecoration(
                            labelText: "Attachment URL (Optional)",
                            prefixIcon: Icon(Icons.link_outlined),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: updateHomework,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: Text("Update Homework", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
