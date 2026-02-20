import 'package:flutter/material.dart';
import '../../services/homework_service.dart';
import 'package:intl/intl.dart';

class AddHomeworkScreen extends StatefulWidget {
  final String className;

  AddHomeworkScreen({required this.className});

  @override
  _AddHomeworkScreenState createState() => _AddHomeworkScreenState();
}

class _AddHomeworkScreenState extends State<AddHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController subjectName = TextEditingController();
  TextEditingController homeworkText = TextEditingController();
  TextEditingController attachmentUrl = TextEditingController();
  
  DateTime? homeworkDate = DateTime.now();
  bool isLoading = false;

  Future<void> selectHomeworkDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: homeworkDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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

  Future<void> addHomework() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    bool success = await HomeworkService.createHomework(
      className: widget.className,
      subjectName: subjectName.text,
      homeworkText: homeworkText.text,
      homeworkDate: DateFormat('yyyy-MM-dd').format(homeworkDate!),
      attachmentUrl: attachmentUrl.text.isEmpty ? null : attachmentUrl.text,
    );

    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Homework Added Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Add Homework")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Homework")),
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
                        hintText: "Math, Science, English...",
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: homeworkText,
                      decoration: InputDecoration(
                        labelText: "Homework Description *",
                        border: OutlineInputBorder(),
                        hintText: "Complete chapter 5...",
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
                        hintText: "https://example.com/file.pdf",
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: addHomework,
                        child: Text("Add Homework", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
