import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AddTeacherScreen extends StatefulWidget {
  @override
  _AddTeacherScreenState createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();
  final designationController = TextEditingController();
  final qualificationController = TextEditingController();
  
  String gender = "male";
  DateTime? dateOfBirth;
  DateTime? joiningDate;
  int experienceYears = 0;
  bool isClassTeacher = false;
  String? assignedStandard;
  String assignedDivision = "A";

  final List<String> classes = [
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th"
  ];

  Future<void> addTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String? clientId = await AuthService.getClientId();

    Map<String, dynamic> data = {
      "first_name": firstNameController.text.trim(),
      "middle_name": middleNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "password": passwordController.text.trim(),
      "role_name": "teacher",
      "client_id": clientId,
      "date_of_birth": dateOfBirth?.toIso8601String().split('T')[0],
      "gender": gender,
      "mobile_number": mobileController.text.trim(),
      "designation": designationController.text.trim(),
      "qualification": qualificationController.text.trim(),
      "joining_date": joiningDate?.toIso8601String().split('T')[0],
      "experience_years": experienceYears,
      "is_class_teacher": isClassTeacher,
      "assigned_standard": assignedStandard,
      "assigned_division": assignedDivision,
    };

    var result = await AuthService.signup(data);

    setState(() => isLoading = false);

    if (result != null && result['unique_id'] != null) {
      _showSuccessDialog(result['unique_id']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add teacher"), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog(String uniqueId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text("Success!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Teacher registered successfully!"),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  Text(
                    "Unique ID: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      uniqueId,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Teacher")),
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
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password *"),
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return "Required";
                if (v.length < 6) return "Minimum 6 characters";
                return null;
              },
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
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => dateOfBirth = date);
              },
              controller: TextEditingController(
                text: dateOfBirth != null
                    ? "${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}"
                    : "",
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Joining Date",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                var date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => joiningDate = date);
              },
              controller: TextEditingController(
                text: joiningDate != null
                    ? "${joiningDate!.day}/${joiningDate!.month}/${joiningDate!.year}"
                    : "",
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(labelText: "Experience (Years)"),
              keyboardType: TextInputType.number,
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
              onPressed: isLoading ? null : addTeacher,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Add Teacher"),
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
