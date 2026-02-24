import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryHeader(theme),
            SizedBox(height: 24),
            Text(
              "Term Examinations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            SizedBox(height: 16),
            _buildExamCard(theme, "Annual Examination 2024", "A+", [
              _subjectRow("Mathematics", "95/100", Icons.functions, Colors.blue),
              _subjectRow("English Language", "88/100", Icons.translate, Colors.orange),
              _subjectRow("General Science", "92/100", Icons.science, Colors.green),
              _subjectRow("Social Studies", "84/100", Icons.public, Colors.purple),
            ]),
            SizedBox(height: 16),
            _buildExamCard(theme, "Half Yearly Examination", "A", [
              _subjectRow("Mathematics", "92/100", Icons.functions, Colors.blue),
              _subjectRow("English Language", "82/100", Icons.translate, Colors.orange),
              _subjectRow("General Science", "89/100", Icons.science, Colors.green),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.stars, color: Colors.white, size: 35),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Overall Performance",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  "Excellent (A+)",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                "92.4%",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Aggregate",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(ThemeData theme, String title, String grade, List<Widget> subjects) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: title.contains("Annual"),
          tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text("Grade: $grade", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600)),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.assignment, color: theme.primaryColor, size: 24),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(children: subjects),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectRow(String name, String marks, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          ),
          Text(
            marks,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}