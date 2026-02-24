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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text("Success!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Teacher registered successfully!", style: TextStyle(fontSize: 15)),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "UNIQUE ID",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 20, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        uniqueId,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.grey.shade600),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to list
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Add New Teacher"),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            _sectionHeader(Icons.person, "Personal Details"),
            _buildFormCard([
              _buildTextField(firstNameController, "First Name *", Icons.person_outline),
              _buildTextField(middleNameController, "Middle Name", Icons.person_outline),
              _buildTextField(lastNameController, "Last Name *", Icons.person_outline),
              _buildDropdownField(
                value: gender,
                label: "Gender *",
                items: ["male", "female"],
                icon: Icons.wc,
                onChanged: (v) => setState(() => gender = v!),
              ),
              _buildDatePicker(
                label: "Date of Birth",
                value: dateOfBirth,
                onTap: () async {
                  var date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1990),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => dateOfBirth = date);
                },
              ),
            ]),

            SizedBox(height: 24),
            _sectionHeader(Icons.work, "Professional Details"),
            _buildFormCard([
              _buildTextField(designationController, "Designation *", Icons.badge_outlined),
              _buildTextField(qualificationController, "Qualification *", Icons.school_outlined),
              _buildDatePicker(
                label: "Joining Date",
                value: joiningDate,
                onTap: () async {
                  var date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => joiningDate = date);
                },
              ),
              _buildTextField(
                TextEditingController(text: experienceYears > 0 ? experienceYears.toString() : ""),
                "Experience (Years)",
                Icons.history,
                keyboardType: TextInputType.number,
                onChanged: (v) => experienceYears = int.tryParse(v) ?? 0,
              ),
            ]),

            SizedBox(height: 24),
            _sectionHeader(Icons.admin_panel_settings, "Account & Assignment"),
            _buildFormCard([
              _buildTextField(mobileController, "Mobile Number *", Icons.phone_android, keyboardType: TextInputType.number),
              _buildTextField(passwordController, "Login Password *", Icons.lock_outline, obscureText: true),
              
              Divider(height: 32),
              
              SwitchListTile(
                title: Text("Is Class Teacher?", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text("Assign a primary class to this teacher"),
                value: isClassTeacher,
                activeColor: theme.primaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => isClassTeacher = v),
              ),
              
              if (isClassTeacher) ...[
                SizedBox(height: 12),
                _buildDropdownField(
                  value: assignedStandard,
                  label: "Assigned Class",
                  items: classes,
                  icon: Icons.meeting_room,
                  onChanged: (v) => setState(() => assignedStandard = v),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  TextEditingController(text: assignedDivision),
                  "Division", 
                  Icons.grid_view,
                  onChanged: (v) => assignedDivision = v,
                ),
              ],
            ]),

            SizedBox(height: 40),
            Container(
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
                onPressed: isLoading ? null : addTeacher,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("Register Teacher", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 40),
          ],
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
    int maxLines = 1,
    bool obscureText = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
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
