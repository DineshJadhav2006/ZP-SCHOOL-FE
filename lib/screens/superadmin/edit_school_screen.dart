import 'package:flutter/material.dart';
import '../../services/client_service.dart';

class EditSchoolScreen extends StatefulWidget {
  final Map<String, dynamic> school;

  const EditSchoolScreen({required this.school});

  @override
  State<EditSchoolScreen> createState() => _EditSchoolScreenState();
}

class _EditSchoolScreenState extends State<EditSchoolScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController infoController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.school['name']);
    phoneController = TextEditingController(text: widget.school['phone']);
    infoController = TextEditingController(text: widget.school['info'] ?? '');
  }

  Future<void> updateSchool() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    bool success = await ClientService.updateClient(
      clientId: widget.school['id'],
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      info: infoController.text.trim().isEmpty ? null : infoController.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('School updated successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update school'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit School')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'School Name *',
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: infoController,
                decoration: InputDecoration(
                  labelText: 'Additional Info',
                  prefixIcon: Icon(Icons.info),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateSchool,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Update School', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
