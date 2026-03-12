import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import 'complaint_screen.dart';
import 'package:intl/intl.dart';

class MyComplaintsScreen extends StatefulWidget {
  @override
  _MyComplaintsScreenState createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  bool isLoading = true;
  List<dynamic> complaints = [];
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    loadComplaints();
  }

  Future<void> loadComplaints() async {
    setState(() => isLoading = true);
    String? status = selectedFilter == 'all' ? null : selectedFilter;
    final data = await ComplaintService.getMyComplaints(status: status);
    setState(() {
      complaints = data['data'] ?? [];
      isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'resolved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
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
                              'No complaints yet',
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
                      String role = complaint['role'] ?? '';
                      String? targetName = complaint['target_name'];
                      String? response = complaint['response'];
                      String createdAt = complaint['createdAt'] ?? '';

                      DateTime date = DateTime.parse(createdAt);
                      String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

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
                              role == 'teacher' ? Icons.person : Icons.admin_panel_settings,
                              color: _getStatusColor(status),
                            ),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _deleteComplaint(complaint['id'], index),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              if (targetName != null)
                                Text(
                                  'Teacher: $targetName',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.1),
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
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      formattedDate,
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            Divider(),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Description:',
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
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.reply, size: 16, color: Colors.green),
                                        SizedBox(width: 4),
                                        Text(
                                          'Response:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.green.shade800,
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "student_add_complaint_fab",
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ComplaintScreen()),
          );
          if (result == true) {
            loadComplaints();
          }
        },
        icon: Icon(Icons.add),
        label: Text('Add Complaint'),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  Future<void> _deleteComplaint(String complaintId, int index) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Complaint'),
        content: Text('Are you sure you want to delete this complaint?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await ComplaintService.deleteComplaint(complaintId);
      if (success) {
        setState(() {
          complaints.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint deleted successfully'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete complaint'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatResponseDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
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
        setState(() => selectedFilter = value);
        loadComplaints();
      },
      backgroundColor: Colors.white,
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      side: BorderSide(color: chipColor),
    );
  }
}
