import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class EditAdminScreen extends StatefulWidget {
  final String clientId;
  final Map<String, dynamic> admin;

  const EditAdminScreen({required this.clientId, required this.admin});

  @override
  State<EditAdminScreen> createState() => _EditAdminScreenState();
}

class _EditAdminScreenState extends State<EditAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController lastNameController;
  late TextEditingController designationController;
  late TextEditingController mobileController;
  late TextEditingController qualificationController;
  late TextEditingController experienceController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.admin['first_name']);
    middleNameController = TextEditingController(text: widget.admin['middle_name'] ?? '');
    lastNameController = TextEditingController(text: widget.admin['last_name']);
    designationController = TextEditingController(text: widget.admin['designation']);
    mobileController = TextEditingController(text: widget.admin['mobile_number']);
    qualificationController = TextEditingController(text: widget.admin['qualification'] ?? '');
    experienceController = TextEditingController(text: widget.admin['experience']?.toString() ?? '');
  }

  Future<void> updateAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    bool success = await AdminService.updateAdmin(
      clientId: widget.clientId,
      adminId: widget.admin['id'],
      firstName: firstNameController.text.trim(),
      middleName: middleNameController.text.trim().isEmpty ? null : middleNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      designation: designationController.text.trim(),
      mobileNumber: mobileController.text.trim(),
      qualification: qualificationController.text.trim().isEmpty ? null : qualificationController.text.trim(),
      experience: experienceController.text.trim().isEmpty ? null : int.tryParse(experienceController.text.trim()),
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin updated successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update admin'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Admin')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name *', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: middleNameController,
                decoration: InputDecoration(labelText: 'Middle Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name *', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: designationController,
                decoration: InputDecoration(labelText: 'Designation *', prefixIcon: Icon(Icons.work)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: mobileController,
                decoration: InputDecoration(labelText: 'Mobile Number *', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: qualificationController,
                decoration: InputDecoration(labelText: 'Qualification', prefixIcon: Icon(Icons.school)),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: experienceController,
                decoration: InputDecoration(labelText: 'Experience (years)', prefixIcon: Icon(Icons.work_history)),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateAdmin,
                  child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Update Admin', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
