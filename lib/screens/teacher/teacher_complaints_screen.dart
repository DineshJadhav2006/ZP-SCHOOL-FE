import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import 'package:intl/intl.dart';

class TeacherComplaintsScreen extends StatefulWidget {
  @override
  _TeacherComplaintsScreenState createState() => _TeacherComplaintsScreenState();
}

class _TeacherComplaintsScreenState extends State<TeacherComplaintsScreen> {
  bool isLoading = true;
  List<dynamic> complaints = [];
  List<dynamic> allComplaints = [];
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    loadComplaints();
  }

  Future<void> loadComplaints() async {
    setState(() => isLoading = true);
    final data = await ComplaintService.getTeacherComplaints();
    setState(() {
      allComplaints = data['data'] ?? [];
      _applyFilter();
      isLoading = false;
    });
  }

  void _applyFilter() {
    if (selectedFilter == 'all') {
      complaints = allComplaints;
    } else {
      complaints = allComplaints.where((c) => c['status'] == selectedFilter).toList();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'resolved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _respondToComplaint(String complaintId, int index) async {
    TextEditingController responseController = TextEditingController();
    
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Respond to Complaint'),
        content: TextField(
          controller: responseController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter your response...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Send Response'),
          ),
        ],
      ),
    );

    if (result == true && responseController.text.trim().isNotEmpty) {
      bool success = await ComplaintService.respondToComplaint(
        complaintId,
        responseController.text.trim(),
      );
      
      if (success) {
        setState(() {
          complaints[index]['status'] = 'resolved';
          complaints[index]['response'] = responseController.text.trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Response sent successfully'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send response'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Text('My Complaints', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 20, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text('Filter:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all', theme),
                        SizedBox(width: 8),
                        _buildFilterChip('Pending', 'pending', theme),
                        SizedBox(width: 8),
                        _buildFilterChip('Resolved', 'resolved', theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : complaints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text(
                              'No complaints found',
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadComplaints,
                        child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = complaints[index];
                      String status = complaint['status'] ?? 'pending';
                      String title = complaint['title'] ?? '';
                      String description = complaint['description'] ?? '';
                      String? response = complaint['response'];
                      String createdAt = complaint['createdAt'] ?? '';
                      
                      Map<String, dynamic>? student = complaint['student'];
                      String studentName = '';
                      String studentClass = '';
                      
                      if (student != null) {
                        studentName = '${student['first_name']} ${student['middle_name'] ?? ''} ${student['last_name']}'.trim();
                        studentClass = student['standard'] ?? '';
                        if (student['division'] != null) {
                          studentClass += '-${student['division']}';
                        }
                      }

                      DateTime date;
                      String formattedDate;
                      
                      try {
                        date = DateTime.parse(createdAt);
                        formattedDate = DateFormat('dd MMM yyyy, hh:mm:ss a').format(date);
                      } catch (e) {
                        formattedDate = createdAt.isNotEmpty ? createdAt : 'No date';
                      }

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.all(16),
                          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person,
                              color: _getStatusColor(status),
                            ),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                'Student: $studentName ($studentClass)',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          trailing: status == 'pending'
                              ? IconButton(
                                  icon: Icon(Icons.reply, color: theme.primaryColor),
                                  onPressed: () => _respondToComplaint(complaint['id'], index),
                                )
                              : Icon(Icons.check_circle, color: Colors.green),
                          children: [
                            Divider(),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Complaint:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                            ),
                            if (response != null) ...[
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.reply, size: 16, color: Colors.blue),
                                        SizedBox(width: 4),
                                        Text(
                                          'Your Response:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      response,
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                    ),
                                    if (complaint['responder'] != null) ...[
                                      SizedBox(height: 8),
                                      Text(
                                        'Responded by: ${complaint['responder']['first_name']} ${complaint['responder']['last_name']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                    if (complaint['responded_at'] != null) ...[
                                      Text(
                                        'Date: ${_formatResponseDate(complaint['responded_at'])}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ThemeData theme) {
    bool isSelected = selectedFilter == value;
    Color chipColor;
    
    if (value == 'pending') {
      chipColor = Colors.orange;
    } else if (value == 'resolved') {
      chipColor = Colors.green;
    } else {
      chipColor = theme.primaryColor;
    }
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : chipColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
          _applyFilter();
        });
      },
      backgroundColor: Colors.white,
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      side: BorderSide(color: chipColor),
    );
  }

  String _formatResponseDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}