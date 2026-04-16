import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/notice_service.dart';
import 'package:intl/intl.dart';
import '../../localization/language_service.dart';

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
        SnackBar(content: Text(isEditMode ? LanguageService.text("notice_updated_success") : LanguageService.text("notice_sent_success"))),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? LanguageService.text("notice_updated_failed") : LanguageService.text("notice_sent_failed")), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? LanguageService.text("edit_notice") : LanguageService.text("send_notice")),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Theme(
                  data: theme.copyWith(
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.primaryColor, width: 2)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageService.text("notice_details"),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: LanguageService.text("title_required"),
                                prefixIcon: Icon(Icons.title_rounded, color: theme.primaryColor),
                              ),
                              validator: (v) => v!.isEmpty ? LanguageService.text("required") : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                labelText: LanguageService.text("description_required"),
                                prefixIcon: Icon(Icons.description_outlined, color: theme.primaryColor),
                              ),
                              maxLines: 4,
                              validator: (v) => v!.isEmpty ? LanguageService.text("required") : null,
                            ),
                            SizedBox(height: 16),
                            InkWell(
                              onTap: _selectDate,
                              borderRadius: BorderRadius.circular(16),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: LanguageService.text("notice_date_required"),
                                  prefixIcon: Icon(Icons.calendar_month_rounded, color: theme.primaryColor),
                                ),
                                child: Text(
                                  DateFormat('dd MMM yyyy').format(selectedDate),
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageService.text("recipients"),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                            SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: selectedRole,
                              decoration: InputDecoration(
                                labelText: LanguageService.text("sent_to") + " *",
                                prefixIcon: Icon(Icons.people_alt_rounded, color: theme.primaryColor),
                              ),
                              items: [
                                DropdownMenuItem(value: "student", child: Text(LanguageService.text("students"))),
                                DropdownMenuItem(value: "teacher", child: Text(LanguageService.text("teachers"))),
                                DropdownMenuItem(value: "all", child: Text(LanguageService.text("everyone"))),
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
                                  labelText: LanguageService.text("select_class_optional"),
                                  prefixIcon: Icon(Icons.school_rounded, color: theme.primaryColor),
                                  hintText: LanguageService.text("all_classes"),
                                ),
                                items: [
                                  DropdownMenuItem(value: null, child: Text(LanguageService.text("all_classes"))),
                                  ...classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                                ],
                                onChanged: (v) => setState(() => selectedClass = v),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
                      SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _sendNotice,
                          icon: Icon(isEditMode ? Icons.check_circle_rounded : Icons.send_rounded),
                          label: Text(isEditMode ? LanguageService.text("update_notice") : LanguageService.text("send_notice"), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
