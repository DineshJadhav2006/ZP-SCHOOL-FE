import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/student_service.dart';
import 'package:intl/intl.dart';

class EditStudentScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const EditStudentScreen({required this.student});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _parentNameController;
  late TextEditingController _dobController;
  late TextEditingController _mobileController;
  late TextEditingController _aadharController;
  late TextEditingController _addressController;
  late TextEditingController _rollNumberController;
  String? _selectedGender;
  String? _selectedStandard;
  String? _selectedDivision;
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.student['first_name']);
    _middleNameController = TextEditingController(text: widget.student['middle_name']);
    _lastNameController = TextEditingController(text: widget.student['last_name']);
    _parentNameController = TextEditingController(text: widget.student['parent_name']);
    _dobController = TextEditingController(text: _formatDate(widget.student['date_of_birth']));
    _mobileController = TextEditingController(text: widget.student['mobile_number']);
    _aadharController = TextEditingController(text: widget.student['aadhar_number']);
    _addressController = TextEditingController(text: widget.student['address']);
    _rollNumberController = TextEditingController(text: widget.student['roll_number']?.toString() ?? '');
    _selectedGender = widget.student['gender'];
    _selectedStandard = widget.student['standard'];
    _selectedDivision = widget.student['division'];
    _selectedCategory = widget.student['category'];
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr));
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _parentNameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _aadharController.dispose();
    _addressController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "first_name": _firstNameController.text.trim(),
      "middle_name": _middleNameController.text.trim(),
      "last_name": _lastNameController.text.trim(),
      "parent_name": _parentNameController.text.trim(),
      "date_of_birth": _dobController.text.trim(),
      "gender": _selectedGender,
      "mobile_number": _mobileController.text.trim(),
      "roll_number": _rollNumberController.text.trim(),
      "aadhar_number": _aadharController.text.trim(),
      "standard": _selectedStandard,
      "division": _selectedDivision,
      "address": _addressController.text.trim(),
      "category": _selectedCategory,
    };

    bool success = await StudentService.updateStudent(widget.student['id'], data);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student updated successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update student"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Student"),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: "First Name *"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _middleNameController,
                      decoration: InputDecoration(labelText: "Middle Name"),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: "Last Name *"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _parentNameController,
                      decoration: InputDecoration(labelText: "Parent Name *"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(labelText: "Date of Birth (YYYY-MM-DD) *"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(labelText: "Gender *"),
                      items: ["male", "female", "other"]
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGender = v),
                      validator: (v) => v == null ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _mobileController,
                      decoration: InputDecoration(labelText: "Mobile Number *"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v!.isEmpty) return "Required";
                        // Remove +91 prefix if present for validation
                        String cleanNumber = v.replaceAll(RegExp(r'^(\+91|91)'), '');
                        if (cleanNumber.length != 10) return "Must be 10 digits (excluding +91)";
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _rollNumberController,
                      decoration: InputDecoration(labelText: "Roll Number"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _aadharController,
                      decoration: InputDecoration(labelText: "Aadhar Number"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedStandard,
                      decoration: InputDecoration(labelText: "Standard *"),
                      items: ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th"]
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedStandard = v),
                      validator: (v) => v == null ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedDivision,
                      decoration: InputDecoration(labelText: "Division"),
                      items: ["A", "B", "C", "D"]
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDivision = v),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: "Address"),
                      maxLines: 2,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(labelText: "Category"),
                      items: ["General", "OBC", "SC", "ST"]
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text("Update Student", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
