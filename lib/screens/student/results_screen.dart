import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildExam("Half Yearly"),
        _buildExam("Quarterly"),
      ],
    );
  }

  Widget _buildExam(String name) {
    return Card(
      child: ExpansionTile(
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          _row("Math", "85/100"),
          _row("English", "78/100"),
          _row("Science", "92/100"),
        ],
      ),
    );
  }

  Widget _row(String subject, String marks) {
    return ListTile(
      title: Text(subject),
      trailing: Text(marks, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}