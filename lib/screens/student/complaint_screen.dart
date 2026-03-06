import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../services/teacher_service.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String selectedRole = 'admin';
  String? selectedTeacherName;
  List<dynamic> teachers = [];
  bool isLoadingTeachers = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    setState(() => isLoadingTeachers = true);
    final data = await TeacherService.getAllTeachers();
    setState(() {
      teachers = data;
      isLoadingTeachers = false;
    });
  }

  Future<void> submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedRole == 'teacher' && selectedTeacherName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a teacher')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    bool success = await ComplaintService.submitComplaint(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      role: selectedRole,
      targetName: selectedRole == 'teacher' ? selectedTeacherName : null,
    );

    setState(() => isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint submitted successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit complaint'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Text('Submit Complaint', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complaint Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('General'),
                      value: 'admin',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                          selectedTeacherName = null;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Teacher'),
                      value: 'teacher',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (selectedRole == 'teacher') ...[
                isLoadingTeachers
                    ? Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value: selectedTeacherName,
                        decoration: InputDecoration(
                          labelText: 'Select Teacher',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: teachers.map((teacher) {
                          String name = '${teacher['first_name']} ${teacher['last_name']}';
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedTeacherName = value);
                        },
                        validator: (value) {
                          if (selectedRole == 'teacher' && value == null) {
                            return 'Please select a teacher';
                          }
                          return null;
                        },
                      ),
                SizedBox(height: 20),
              ],
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief title of complaint',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your complaint in detail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit Complaint',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
