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
    return Scaffold(
      appBar: AppBar(title: Text("Edit Homework")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: subjectName,
                      decoration: InputDecoration(
                        labelText: "Subject Name *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: homeworkText,
                      decoration: InputDecoration(
                        labelText: "Homework Description *",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: selectHomeworkDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Homework Date *",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          formatDate(homeworkDate),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: attachmentUrl,
                      decoration: InputDecoration(
                        labelText: "Attachment URL (Optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: updateHomework,
                        child: Text("Update Homework", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
