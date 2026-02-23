import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _notificationCard(
            "Homework Added",
            "Science homework assigned for 22 Feb",
            Icons.book,
          ),
          _notificationCard(
            "Attendance Update",
            "You were marked Present today",
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(String title, String message, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(message),
      ),
    );
  }
}