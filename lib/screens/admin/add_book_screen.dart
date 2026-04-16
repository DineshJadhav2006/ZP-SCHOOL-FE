import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/book_service.dart';
import '../../localization/language_service.dart';

class AddBookScreen extends StatefulWidget {
  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookNameController = TextEditingController();
  final _subjectController = TextEditingController();
  
  String? selectedClass;
  PlatformFile? selectedFile;
  bool isUploading = false;

  final List<String> classes = [
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th"
  ];

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  Future<void> submitBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.text("please_select_class"))),
      );
      return;
    }
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.text("please_select_pdf"))),
      );
      return;
    }

    setState(() => isUploading = true);

    // Upload file first
    String? fileUrl = await BookService.uploadBookFile(selectedFile!);
    
    if (fileUrl == null) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.text("failed_to_upload_file"))),
      );
      return;
    }

    // Add book with file URL
    bool success = await BookService.addBook(
      bookName: _bookNameController.text.trim(),
      className: selectedClass!,
      subjectName: _subjectController.text.trim(),
      bookUrl: fileUrl,
    );

    setState(() => isUploading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.text("book_added_success"))),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.text("book_added_failed"))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(LanguageService.text("add_new_book")),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _bookNameController,
                decoration: InputDecoration(
                  labelText: LanguageService.text("book_name"),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (val) => val!.isEmpty ? LanguageService.text("required") : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: InputDecoration(
                  labelText: LanguageService.text("class_label"),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.class_),
                ),
                items: classes.map((className) {
                  return DropdownMenuItem(value: className, child: Text(className));
                }).toList(),
                onChanged: (val) => setState(() => selectedClass = val),
                validator: (val) => val == null ? LanguageService.text("required") : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: LanguageService.text("subject_name"),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.subject),
                ),
                validator: (val) => val!.isEmpty ? LanguageService.text("required") : null,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, color: theme.primaryColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedFile != null ? selectedFile!.name : LanguageService.text("select_pdf_file"),
                          style: TextStyle(
                            color: selectedFile != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isUploading ? null : submitBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(LanguageService.text("add_book"), style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
