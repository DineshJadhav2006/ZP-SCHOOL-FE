import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'package:uuid/uuid.dart';

class AddAdminScreen extends StatefulWidget {
  final String clientId;

  const AddAdminScreen({required this.clientId});

  @override
  State<AddAdminScreen> createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final designationController = TextEditingController(text: 'Principal');
  final mobileController = TextEditingController();
  final qualificationController = TextEditingController();
  final experienceController = TextEditingController();
  String? selectedGender;
  bool isLoading = false;

  Future<void> addAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // Generate user_id (in real app, this should come from user creation API)
    final userId = Uuid().v4();

    bool success = await AdminService.addAdmin(
      clientId: widget.clientId,
      userId: userId,
      firstName: firstNameController.text.trim(),
      middleName: middleNameController.text.trim().isEmpty ? null : middleNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      designation: designationController.text.trim(),
      mobileNumber: mobileController.text.trim(),
      qualification: qualificationController.text.trim().isEmpty ? null : qualificationController.text.trim(),
      experience: experienceController.text.trim().isEmpty ? null : int.tryParse(experienceController.text.trim()),
      gender: selectedGender,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin added successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add admin'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Admin')),
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
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.person_pin)),
                items: ['male', 'female', 'other'].map((g) => DropdownMenuItem(value: g, child: Text(g.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => selectedGender = v),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : addAdmin,
                  child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Add Admin', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
