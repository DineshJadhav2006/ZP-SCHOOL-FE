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

  String? gender;
  String? standard;

  final List<String> standards = [
    "1st","2nd","3rd","4th","5th","6th","7th","8th","9th","10th"
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

  void updateStudent() async {
    Map<String, dynamic> body = {
      "first_name": firstName.text,
      "middle_name": middleName.text,
      "last_name": lastName.text,
      "parent_name": parentName.text,
      "mobile_number": mobile.text,
      "gender": gender,
      "standard": standard,
      "division": division.text,
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
    return Scaffold(
      appBar: AppBar(title: Text("Edit Student")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            textField("First Name", firstName),
            textField("Middle Name", middleName),
            textField("Last Name", lastName),
            textField("Parent Name", parentName),
            textField("Mobile Number", mobile),
            dropdownField("Gender", gender, genders, (val) => setState(() => gender = val)),
            dropdownField("Standard", standard, standards, (val) => setState(() => standard = val)),
            textField("Division", division),
            textField("Category", category),
            textField("Address", address),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: updateStudent,
                  child: Text("Update", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
