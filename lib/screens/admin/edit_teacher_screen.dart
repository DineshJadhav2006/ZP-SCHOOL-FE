import 'package:flutter/material.dart';
import '../../services/teacher_service.dart';
import 'package:intl/intl.dart';

class EditTeacherScreen extends StatefulWidget {
  final Map<String, dynamic> teacher;

  EditTeacherScreen({required this.teacher});

  @override
  _EditTeacherScreenState createState() => _EditTeacherScreenState();
}

class _EditTeacherScreenState extends State<EditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController lastNameController;
  late TextEditingController mobileController;
  late TextEditingController designationController;
  late TextEditingController qualificationController;
  
  late String gender;
  DateTime? dateOfBirth;
  DateTime? joiningDate;
  late int experienceYears;
  late bool isClassTeacher;
  String? assignedStandard;
  late String assignedDivision;

  final List<String> classes = [
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th"
  ];

  @override
  void initState() {
    super.initState();
    var t = widget.teacher;
    
    firstNameController = TextEditingController(text: t['first_name']);
    middleNameController = TextEditingController(text: t['middle_name'] ?? '');
    lastNameController = TextEditingController(text: t['last_name']);
    mobileController = TextEditingController(text: t['mobile_number']);
    designationController = TextEditingController(text: t['designation']);
    qualificationController = TextEditingController(text: t['qualification']);
    
    gender = t['gender'] ?? 'male';
    experienceYears = t['experience_years'] ?? 0;
    isClassTeacher = t['is_class_teacher'] ?? false;
    assignedStandard = t['assigned_standard'];
    assignedDivision = t['assigned_division'] ?? 'A';
    
    if (t['date_of_birth'] != null) {
      try {
        dateOfBirth = DateTime.parse(t['date_of_birth']);
      } catch (e) {}
    }
    
    if (t['joining_date'] != null) {
      try {
        joiningDate = DateTime.parse(t['joining_date']);
      } catch (e) {}
    }
  }

  Future<void> updateTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    Map<String, dynamic> data = {
      "first_name": firstNameController.text.trim(),
      "middle_name": middleNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "date_of_birth": dateOfBirth?.toIso8601String().split('T')[0],
      "gender": gender,
      "mobile_number": mobileController.text.trim(),
      "designation": designationController.text.trim(),
      "qualification": qualificationController.text.trim(),
      "experience_years": experienceYears,
      "is_class_teacher": isClassTeacher,
      "assigned_standard": assignedStandard,
      "assigned_division": assignedDivision,
    };

    bool success = await TeacherService.updateTeacher(widget.teacher['id'], data);

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Teacher updated successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update teacher"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Teacher")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: "First Name *"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: middleNameController,
              decoration: InputDecoration(labelText: "Middle Name"),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: "Last Name *"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: mobileController,
              decoration: InputDecoration(labelText: "Mobile Number *"),
              keyboardType: TextInputType.number,
              maxLength: 10,
              validator: (v) {
                if (v == null || v.isEmpty) return "Required";
                if (v.length != 10) return "Must be 10 digits";
                if (!RegExp(r'^[0-9]+$').hasMatch(v)) return "Only numbers allowed";
                return null;
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: InputDecoration(labelText: "Gender"),
              items: [
                DropdownMenuItem(value: "male", child: Text("Male")),
                DropdownMenuItem(value: "female", child: Text("Female")),
              ],
              onChanged: (v) => setState(() => gender = v!),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: designationController,
              decoration: InputDecoration(labelText: "Designation *"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: qualificationController,
              decoration: InputDecoration(labelText: "Qualification *"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date of Birth",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                var date = await showDatePicker(
                  context: context,
                  initialDate: dateOfBirth ?? DateTime(1990),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => dateOfBirth = date);
              },
              controller: TextEditingController(
                text: dateOfBirth != null
                    ? DateFormat('dd/MM/yyyy').format(dateOfBirth!)
                    : "",
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(labelText: "Experience (Years)"),
              keyboardType: TextInputType.number,
              initialValue: experienceYears.toString(),
              onChanged: (v) => experienceYears = int.tryParse(v) ?? 0,
            ),
            SizedBox(height: 12),
            SwitchListTile(
              title: Text("Is Class Teacher?"),
              value: isClassTeacher,
              onChanged: (v) => setState(() => isClassTeacher = v),
            ),
            if (isClassTeacher) ...[
              DropdownButtonFormField<String>(
                value: assignedStandard,
                decoration: InputDecoration(labelText: "Assigned Class"),
                items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => assignedStandard = v),
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: assignedDivision,
                decoration: InputDecoration(labelText: "Division"),
                onChanged: (v) => assignedDivision = v,
              ),
            ],
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : updateTeacher,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Update Teacher"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
