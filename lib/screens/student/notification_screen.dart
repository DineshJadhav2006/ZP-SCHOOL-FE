import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _notificationCard(
            "Homework Added",
            "Science homework assigned for 24 Feb. Please check the homework section for details.",
            "2 hours ago",
            Icons.book_outlined,
            Colors.blue,
          ),
          _notificationCard(
            "Attendance Update",
            "You were marked Present for the morning session today. Keep it up!",
            "5 hours ago",
            Icons.check_circle_outline,
            Colors.green,
          ),
          _notificationCard(
            "New Notice",
            "Upcoming school annual sports meet registration is now open. Register before 1st March.",
            "Yesterday",
            Icons.campaign_outlined,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(String title, String message, String time, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
        ),
      ),
    );
  }
}