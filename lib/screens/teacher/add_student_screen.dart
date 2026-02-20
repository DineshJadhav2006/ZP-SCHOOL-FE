import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

class AddStudentScreen extends StatefulWidget {
  final String standard;

  AddStudentScreen({required this.standard});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController firstName = TextEditingController();
  TextEditingController middleName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController parentName = TextEditingController();
  TextEditingController aadharNumber = TextEditingController();
  TextEditingController rollNumber = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController password = TextEditingController(text: "student123");

  String? gender;
  String? division;
  String? category;
  DateTime? dateOfBirth;
  DateTime? admissionDate = DateTime.now();

  bool isLoading = false;

  Future<void> selectDateOfBirth() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => dateOfBirth = picked);
    }
  }

  Future<void> selectAdmissionDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: admissionDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => admissionDate = picked);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  Future<void> addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    if (dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select Date of Birth")),
      );
      return;
    }

    setState(() => isLoading = true);

    String? token = await AuthService.getAccessToken();
    String? clientId = await AuthService.getClientId();

    Map<String, dynamic> body = {
      "first_name": firstName.text,
      "middle_name": middleName.text,
      "last_name": lastName.text,
      "mobile_number": "+91${mobileNumber.text}",
      "password": password.text,
      "role_name": "student",
      "client_id": clientId,
      "parent_name": parentName.text,
      "gender": gender,
      "aadhar_number": aadharNumber.text,
      "roll_number": rollNumber.text,
      "standard": widget.standard,
      "division": division,
      "admission_date": admissionDate?.toIso8601String().split('T')[0],
      "address": address.text,
      "category": category,
      "date_of_birth": dateOfBirth?.toIso8601String().split('T')[0],
    };

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/signup"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student Added Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Add Student")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Student")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: firstName,
                      decoration: InputDecoration(
                        labelText: "First Name *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: middleName,
                      decoration: InputDecoration(
                        labelText: "Middle Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: lastName,
                      decoration: InputDecoration(
                        labelText: "Last Name *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: mobileNumber,
                      decoration: InputDecoration(
                        labelText: "Mobile Number *",
                        border: OutlineInputBorder(),
                        prefixText: "+91 ",
                        hintText: "9876543210",
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        if (v.length != 10) return "Must be 10 digits";
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: password,
                      decoration: InputDecoration(
                        labelText: "Password *",
                        border: OutlineInputBorder(),
                        hintText: "student123",
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: InputDecoration(
                        labelText: "Gender *",
                        border: OutlineInputBorder(),
                      ),
                      items: ["male", "female"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => gender = v),
                      validator: (v) => v == null ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: division,
                      decoration: InputDecoration(
                        labelText: "Division",
                        border: OutlineInputBorder(),
                      ),
                      items: ["A", "B", "C", "D"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => division = v),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: rollNumber,
                      decoration: InputDecoration(
                        labelText: "Roll Number *",
                        border: OutlineInputBorder(),
                        hintText: "22",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: parentName,
                      decoration: InputDecoration(
                        labelText: "Parent Name *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: aadharNumber,
                      decoration: InputDecoration(
                        labelText: "Aadhar Number",
                        border: OutlineInputBorder(),
                        hintText: "123456789012",
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length != 12) {
                          return "Must be 12 digits";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      items: ["General", "OBC", "SC", "ST", "Other"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => category = v),
                    ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: selectDateOfBirth,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Date of Birth *",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          formatDate(dateOfBirth),
                          style: TextStyle(
                            color: dateOfBirth == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: selectAdmissionDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Admission Date *",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          formatDate(admissionDate),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: address,
                      decoration: InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: addStudent,
                        child: Text("Add Student", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
