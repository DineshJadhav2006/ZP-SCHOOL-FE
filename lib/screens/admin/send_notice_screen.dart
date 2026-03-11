import 'package:flutter/material.dart';
import '../../services/notice_service.dart';
import 'package:intl/intl.dart';

class SendNoticeScreen extends StatefulWidget {
  final Map<String, dynamic>? notice;
  
  SendNoticeScreen({this.notice});
  
  @override
  _SendNoticeScreenState createState() => _SendNoticeScreenState();
}

class _SendNoticeScreenState extends State<SendNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  String selectedRole = "student";
  String? selectedClass;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  bool isEditMode = false;

  final List<String> classes = [
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.notice != null) {
      isEditMode = true;
      titleController.text = widget.notice!['title'] ?? '';
      descriptionController.text = widget.notice!['description'] ?? '';
      selectedRole = widget.notice!['role'] ?? 'student';
      selectedClass = widget.notice!['class_name'];
      try {
        selectedDate = DateTime.parse(widget.notice!['notice_date']);
      } catch (_) {}
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _sendNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    bool success;
    if (isEditMode) {
      success = await NoticeService.updateNotice(
        noticeId: widget.notice!['id'],
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        noticeDate: dateStr,
        role: selectedRole,
        className: selectedRole == "student" ? selectedClass : null,
      );
    } else {
      success = await NoticeService.sendNotice(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        noticeDate: dateStr,
        role: selectedRole,
        className: selectedRole == "student" ? selectedClass : null,
      );
    }

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? "Notice updated successfully" : "Notice sent successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? "Failed to update notice" : "Failed to send notice"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Notice" : "Send Notice"),
        backgroundColor: theme.primaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Title *",
                        prefixIcon: Icon(Icons.title_rounded, color: theme.primaryColor),
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: "Description *",
                        prefixIcon: Icon(Icons.description_outlined, color: theme.primaryColor),
                      ),
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Notice Date *",
                          prefixIcon: Icon(Icons.calendar_month_rounded, color: theme.primaryColor),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: "Send To *",
                        prefixIcon: Icon(Icons.people_alt_rounded, color: theme.primaryColor),
                      ),
                      items: [
                        DropdownMenuItem(value: "student", child: Text("Students")),
                        DropdownMenuItem(value: "teacher", child: Text("Teachers")),
                        DropdownMenuItem(value: "all", child: Text("Everyone")),
                      ],
                      onChanged: (v) => setState(() {
                        selectedRole = v!;
                        if (v != "student") selectedClass = null;
                      }),
                    ),
                    if (selectedRole == "student") ...[
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedClass,
                        decoration: InputDecoration(
                          labelText: "Select Class (Optional)",
                          prefixIcon: Icon(Icons.school_rounded, color: theme.primaryColor),
                          hintText: "All Classes",
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text("All Classes")),
                          ...classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                        ],
                        onChanged: (v) => setState(() => selectedClass = v),
                      ),
                    ],
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _sendNotice,
                        icon: Icon(isEditMode ? Icons.check_circle_rounded : Icons.send_rounded),
                        label: Text(isEditMode ? "Update Notice" : "Send Notice", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: theme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
