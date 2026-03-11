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
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th"
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Edit Teacher Profile"),
        backgroundColor: Colors.white,
        foregroundColor: theme.primaryColor,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  _buildFormSection(
                    "Personal Information",
                    [
                      _buildTextField("First Name *", firstNameController, Icons.person_outline),
                      _buildTextField("Middle Name", middleNameController, Icons.person_outline),
                      _buildTextField("Last Name *", lastNameController, Icons.person_outline),
                      _buildDropdownField("Gender", gender, ["male", "female"], (v) => setState(() => gender = v!), Icons.wc_outlined),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildFormSection(
                    "Professional Details",
                    [
                      _buildTextField("Designation *", designationController, Icons.work_outline),
                      _buildTextField("Qualification *", qualificationController, Icons.school_outlined),
                      _buildTextField("Experience (Years)", null, Icons.history_edu_outlined, initialValue: experienceYears.toString(), onChanged: (v) => experienceYears = int.tryParse(v) ?? 0),
                      _buildDatePicker("Date of Birth", dateOfBirth, (date) => setState(() => dateOfBirth = date)),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildFormSection(
                    "Contact & Class Assignment",
                    [
                      _buildTextField("Mobile Number *", mobileController, Icons.phone_android_outlined, maxLength: 10, keyboardType: TextInputType.number),
                      SwitchListTile(
                        title: Text("Is Class Teacher?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        value: isClassTeacher,
                        activeColor: theme.primaryColor,
                        onChanged: (v) => setState(() => isClassTeacher = v),
                      ),
                      if (isClassTeacher) ...[
                        _buildDropdownField("Assigned Class", assignedStandard, classes, (v) => setState(() => assignedStandard = v), Icons.class_outlined),
                        SizedBox(height: 16),
                        _buildTextField("Division", null, Icons.meeting_room_outlined, initialValue: assignedDivision, onChanged: (v) => assignedDivision = v),
                      ],
                    ],
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: updateTeacher,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: Text("Update Teacher", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
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
          ...children.expand((element) => element is SwitchListTile ? [element] : [element, SizedBox(height: 16)]).toList()..removeLast(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController? controller, IconData icon, {String? initialValue, Function(String)? onChanged, int? maxLength, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        counterText: "",
      ),
      validator: (v) => (label.contains("*") && (v == null || v.isEmpty)) ? "Required" : null,
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

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onSelected) {
    return InkWell(
      onTap: () async {
        var picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime(1990),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) onSelected(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          date != null ? DateFormat('dd/MM/yyyy').format(date) : "Select Date",
          style: TextStyle(color: date != null ? Colors.grey.shade800 : Colors.grey.shade500, fontWeight: date != null ? FontWeight.w500 : FontWeight.normal),
        ),
      ),
    );
  }
}
