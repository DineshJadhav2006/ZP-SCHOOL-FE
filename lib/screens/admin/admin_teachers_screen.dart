import 'package:flutter/material.dart';
import '../../services/teacher_service.dart';
import 'add_teacher_screen.dart';
import 'edit_teacher_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/common_extensions.dart';
import '../../localization/language_service.dart';

class AdminTeachersScreen extends StatefulWidget {
  final int totalTeachers;

  const AdminTeachersScreen({required this.totalTeachers});

  @override
  _AdminTeachersScreenState createState() => _AdminTeachersScreenState();
}

class _AdminTeachersScreenState extends State<AdminTeachersScreen> {
  List<dynamic> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    setState(() => isLoading = true);
    var data = await TeacherService.getAllTeachers();
    setState(() {
      teachers = data;
      isLoading = false;
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadTeachers,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : teachers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {
                            var teacher = teachers[index];
                            String name = "${teacher['first_name']} ${teacher['last_name']}".trim();
                            return _buildTeacherCard(teacher, name, theme);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school, color: theme.primaryColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.text("faculty_directory"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${LanguageService.text("total_staff")}: ${teachers.length}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.person_add_outlined, color: theme.primaryColor),
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddTeacherScreen()),
              );
              if (result == true) loadTeachers();
            },
            tooltip: LanguageService.text("add_teacher"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            LanguageService.text("no_teachers_found"),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher, String name, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'teacher_avatar_${teacher['id']}',
          child: CircleAvatar(
            radius: 25,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, color: theme.primaryColor),
          ),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(teacher['designation'] ?? LanguageService.text("staff"), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: _miniTag("${LanguageService.text("staff_id")}: ${teacher['unique_id'] ?? '-'}"),
                ),
                if (teacher['is_class_teacher'] == true) ...[
                  SizedBox(width: 8),
                  Flexible(
                    child: _miniTag("${LanguageService.text("class_label")}: ${teacher['assigned_standard']}", isPrimary: true),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: _buildTeacherActionMenu(teacher),
        onTap: () => _showTeacherDetails(teacher),
      ),
    );
  }

  Widget _miniTag(String text, {bool isPrimary = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.indigo.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10, 
          color: isPrimary ? Colors.indigo : Colors.grey.shade600, 
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTeacherActionMenu(Map<String, dynamic> teacher) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'edit') {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditTeacherScreen(teacher: teacher)),
          );
          if (result == true) loadTeachers();
        } else if (value == 'delete') {
          _confirmDelete(teacher);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Text(LanguageService.text("edit")),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text(LanguageService.text("remove_staff"), style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
    );
  }

  void _showTeacherDetails(Map<String, dynamic> teacher) {
    String name =
        "${teacher['first_name']} ${teacher['middle_name'] ?? ''} ${teacher['last_name']}"
            .trim();
    final theme = Theme.of(context);
    final primaryColor = Colors.indigo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1.0,
        maxChildSize: 1.0,
        minChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
          ),
          child: Column(
            children: [
              // Custom App Bar for Full Screen
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8, right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      LanguageService.text("teacher_profile"),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          Hero(
                            tag: 'teacher_avatar_${teacher['id']}',
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: primaryColor.withOpacity(0.1),
                                child: Text(
                                  teacher['first_name']?[0].toUpperCase() ?? "T",
                                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
                          ),
                          SizedBox(height: 4),
                          Text(
                            teacher['designation'] ?? LanguageService.text("staff"),
                            style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(
                          icon: Icons.call_outlined,
                          label: LanguageService.text("call"),
                          color: Colors.green,
                          onTap: () => _makePhoneCall(teacher['mobile_number']),
                        ),
                        _actionButton(
                          icon: Icons.edit_outlined,
                          label: LanguageService.text("edit"),
                          color: Colors.blue,
                          onTap: () async {
                            Navigator.pop(context);
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditTeacherScreen(teacher: teacher)),
                            );
                            if (result == true) loadTeachers();
                          },
                        ),
                        _actionButton(
                          icon: Icons.delete_outline,
                          label: LanguageService.text("delete"),
                          color: Colors.red,
                          onTap: () {
                            Navigator.pop(context);
                            _confirmDelete(teacher);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Info Sections
                    _sectionTitle(LanguageService.text("professional_information"), Icons.work_outline),
                    _infoCard([
                      _infoRow(Icons.fingerprint, LanguageService.text("staff_id"), teacher['unique_id'] ?? '-'),
                      _infoRow(Icons.workspace_premium_outlined, LanguageService.text("qualification"), teacher['qualification'] ?? '-'),
                      _infoRow(Icons.history_edu_outlined, LanguageService.text("experience"), "${teacher['experience_years'] ?? 0} ${LanguageService.text("years")}"),
                      _infoRow(Icons.calendar_today_outlined, LanguageService.text("joining_date"), formatDate(teacher['joining_date'])),
                    ]),

                    SizedBox(height: 20),
                    _sectionTitle(LanguageService.text("personal_information"), Icons.person_outline),
                    _infoCard([
                      _infoRow(Icons.phone_android_outlined, LanguageService.text("mobile"), teacher['mobile_number'] ?? '-', 
                        trailing: Icon(Icons.call, color: Colors.green, size: 18),
                        onTap: () => _makePhoneCall(teacher['mobile_number'])),
                      _infoRow(teacher['gender']?.toString().toLowerCase() == 'female' ? Icons.female : Icons.male, 
                        LanguageService.text("gender"), teacher['gender']?.toString().capitalize() ?? '-'),
                    ]),

                    if (teacher['is_class_teacher'] == true) ...[
                      SizedBox(height: 20),
                      _sectionTitle(LanguageService.text("class_responsibility"), Icons.class_outlined),
                      _infoCard([
                        _infoRow(Icons.school_outlined, LanguageService.text("class_teacher"), "${teacher['assigned_standard']} - ${teacher['assigned_division']}"),
                      ]),
                    ],
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: Colors.grey.shade600),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _confirmDelete(Map<String, dynamic> teacher) {
    String name = "${teacher['first_name']} ${teacher['last_name']}";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageService.text("delete_teacher")),
        content: Text("${LanguageService.text("are_you_sure_delete")} $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageService.text("cancel")),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await TeacherService.deleteTeacher(teacher['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(LanguageService.text("teacher_deleted_success"))),
                );
                loadTeachers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(LanguageService.text("teacher_deleted_failed")), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(LanguageService.text("delete"), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
