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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Add New Student"),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.person, "Basic Information"),
                    _buildFormCard([
                      _buildTextField(firstName, "First Name *", Icons.person_outline),
                      _buildTextField(middleName, "Middle Name", Icons.person_outline),
                      _buildTextField(lastName, "Last Name *", Icons.person_outline),
                      _buildDropdownField(
                        value: gender,
                        label: "Gender *",
                        items: ["male", "female"],
                        icon: Icons.wc,
                        onChanged: (v) => setState(() => gender = v),
                      ),
                      _buildDatePicker(
                        label: "Date of Birth *",
                        value: dateOfBirth,
                        onTap: selectDateOfBirth,
                      ),
                    ]),
                    
                    SizedBox(height: 24),
                    _sectionHeader(Icons.school, "Academic Details"),
                    _buildFormCard([
                      _buildTextField(rollNumber, "Roll Number *", Icons.numbers, keyboardType: TextInputType.number),
                      _buildDropdownField(
                        value: division,
                        label: "Division",
                        items: ["A", "B", "C", "D"],
                        icon: Icons.grid_view,
                        onChanged: (v) => setState(() => division = v),
                      ),
                      _buildDatePicker(
                        label: "Admission Date *",
                        value: admissionDate,
                        onTap: selectAdmissionDate,
                      ),
                      _buildDropdownField(
                        value: category,
                        label: "Category",
                        items: ["General", "OBC", "SC", "ST", "Other"],
                        icon: Icons.category,
                        onChanged: (v) => setState(() => category = v),
                      ),
                    ]),

                    SizedBox(height: 24),
                    _sectionHeader(Icons.contact_phone, "Contact & Other"),
                    _buildFormCard([
                      _buildTextField(
                        mobileNumber, 
                        "Mobile Number *", 
                        Icons.phone_android, 
                        prefixText: "+91 ",
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      ),
                      _buildTextField(parentName, "Parent Name *", Icons.family_restroom),
                      _buildTextField(
                        aadharNumber, 
                        "Aadhar Number", 
                        Icons.credit_card,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
                      ),
                      _buildTextField(password, "Login Password *", Icons.lock_outline),
                      _buildTextField(address, "Address", Icons.home_outlined, maxLines: 2),
                    ]),

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
                      child: ElevatedButton(
                        onPressed: addStudent,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text("Register Student", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: children.expand((w) => [w, SizedBox(height: 16)]).toList()..removeLast(),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        prefixText: prefixText,
      ),
      validator: (v) => (label.contains('*') && (v == null || v.isEmpty)) ? "Required" : null,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: (v) => (label.contains('*') && v == null) ? "Required" : null,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          formatDate(value),
          style: TextStyle(
            color: value == null ? Colors.grey.shade500 : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
