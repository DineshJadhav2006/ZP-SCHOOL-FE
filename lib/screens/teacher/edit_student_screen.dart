import 'package:flutter/material.dart';
import '../../services/student_service.dart';

class EditStudentScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  EditStudentScreen({required this.student});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  late TextEditingController firstName;
  late TextEditingController middleName;
  late TextEditingController lastName;
  late TextEditingController parentName;
  late TextEditingController mobile;
  late TextEditingController division;
  late TextEditingController category;
  late TextEditingController address;
  late TextEditingController rollNumber;
  late TextEditingController studentId;
  late TextEditingController generalRegisterNo;
  late TextEditingController mothersName;

  String? gender;
  String? standard;

  final List<String> standards = [
    "1st","2nd","3rd","4th","5th","6th","7th"
  ];

  final List<String> genders = ["male", "female"];

  @override
  void initState() {
    super.initState();

    firstName = TextEditingController(text: widget.student["first_name"]);
    middleName = TextEditingController(text: widget.student["middle_name"]);
    lastName = TextEditingController(text: widget.student["last_name"]);
    parentName = TextEditingController(text: widget.student["parent_name"]);
    mobile = TextEditingController(text: widget.student["mobile_number"]);
    division = TextEditingController(text: widget.student["division"]);
    category = TextEditingController(text: widget.student["category"]);
    address = TextEditingController(text: widget.student["address"]);
    rollNumber = TextEditingController(text: widget.student["roll_number"]?.toString() ?? "");
    studentId = TextEditingController(text: widget.student["student_id"] ?? "");
    generalRegisterNo = TextEditingController(text: widget.student["general_register_no"] ?? "");
    mothersName = TextEditingController(text: widget.student["mothers_name"] ?? "");

    gender = widget.student["gender"];
    standard = widget.student["standard"];
  }

  Widget textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget dropdownField(String label, String? value,
      List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items.map((e) {
          return DropdownMenuItem(value: e, child: Text(e));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  void updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> body = {
      "first_name": firstName.text,
      "middle_name": middleName.text,
      "last_name": lastName.text,
      "parent_name": parentName.text,
      "mobile_number": mobile.text,
      "gender": gender,
      "standard": standard,
      "division": division.text,
      "roll_number": rollNumber.text.isEmpty ? null : rollNumber.text,
      if (studentId.text.isNotEmpty) "student_id": studentId.text,
      if (generalRegisterNo.text.isNotEmpty) "general_register_no": generalRegisterNo.text,
      if (mothersName.text.isNotEmpty) "mothers_name": mothersName.text,
      "address": address.text,
      "category": category.text,
    };

    bool success = await StudentService.updateStudent(widget.student["id"], body);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student Updated Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Edit Student Details"),
        backgroundColor: Colors.white,
        foregroundColor: theme.primaryColor,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
            _buildFormSection(
              "Personal Details",
              [
                _buildTextField("First Name", firstName, Icons.person_outline),
                _buildTextField("Middle Name", middleName, Icons.person_outline),
                _buildTextField("Last Name", lastName, Icons.person_outline),
                _buildDropdownField("Gender", gender, genders, (val) => setState(() => gender = val), Icons.wc_outlined),
              ],
            ),
            SizedBox(height: 24),
            _buildFormSection(
              "Academic Information",
              [
                _buildDropdownField("Standard", standard, standards, (val) => setState(() => standard = val), Icons.school_outlined),
                _buildTextField("Division", division, Icons.meeting_room_outlined),
                _buildTextField("Roll Number", rollNumber, Icons.numbers_outlined),
                _buildTextField("Student ID", studentId, Icons.badge_outlined),
                _buildTextField("General Register No", generalRegisterNo, Icons.app_registration_outlined),
                _buildTextField("Mother's Name", mothersName, Icons.woman_outlined),
                _buildTextField("Category", category, Icons.category_outlined),
              ],
            ),
            SizedBox(height: 24),
            _buildFormSection(
              "Parent & Contact",
              [
                _buildTextField("Parent Name", parentName, Icons.family_restroom_outlined),
                _buildTextField("Mobile Number", mobile, Icons.phone_android_outlined),
                _buildTextField("Address", address, Icons.location_on_outlined, maxLines: 2),
              ],
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: updateStudent,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: Text("Update Student", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          SizedBox(height: 20),
          ...children.expand((element) => [element, SizedBox(height: 16)]).toList()..removeLast(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: label == "Mobile Number" ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: label == "Mobile Number" ? (v) {
        if (v == null || v.isEmpty) return "Required";
        // Remove +91 prefix if present for validation
        String cleanNumber = v.replaceAll(RegExp(r'^(\+91|91)'), '');
        if (cleanNumber.length != 10) return "Must be 10 digits (excluding +91)";
        return null;
      } : null,
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, Function(String?) onChanged, IconData icon) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
