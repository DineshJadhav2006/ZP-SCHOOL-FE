import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class AdminReportsScreen extends StatefulWidget {
  @override
  _AdminReportsScreenState createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  DateTime selectedDate = DateTime.now();
  int totalStudents = 0;
  int presentStudents = 0;
  int absentStudents = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> last7DaysData = [];
  bool isClassWiseView = false;
  String? selectedClass;
  String selectedDivision = "A";

  final List<String> classes = [
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th"
  ];

  @override
  void initState() {
    super.initState();
    loadStatistics();
    loadLast7DaysData();
  }

  Future<void> loadStatistics() async {
    setState(() => isLoading = true);
    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    
    if (isClassWiseView && selectedClass != null) {
      await loadClassWiseStatistics(dateStr);
    } else {
      var data = await AttendanceService.getAttendanceStatistics(dateStr);
      setState(() {
        totalStudents = data?['total'] ?? 0;
        presentStudents = data?['present'] ?? 0;
        absentStudents = data?['absent'] ?? 0;
        isLoading = false;
      });
    }
  }

  Future<void> loadClassWiseStatistics(String dateStr) async {
    String? clientId = await AuthService.getClientId();
    if (clientId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      var result = await AttendanceService.getAttendance(
        clientId: clientId,
        standard: selectedClass!,
        division: selectedDivision,
        date: dateStr,
      );

      setState(() {
        totalStudents = result['total'] ?? 0;
        presentStudents = result['present'] ?? 0;
        absentStudents = result['absent'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        totalStudents = 0;
        presentStudents = 0;
        absentStudents = 0;
        isLoading = false;
      });
    }
  }

  Future<void> loadLast7DaysData() async {
    List<Map<String, dynamic>> tempData = [];
    
    if (isClassWiseView && selectedClass != null) {
      String? clientId = await AuthService.getClientId();
      if (clientId == null) return;

      for (int i = 6; i >= 0; i--) {
        DateTime date = DateTime.now().subtract(Duration(days: i));
        String dateStr = DateFormat('yyyy-MM-dd').format(date);
        try {
          var result = await AttendanceService.getAttendance(
            clientId: clientId,
            standard: selectedClass!,
            division: selectedDivision,
            date: dateStr,
          );
          tempData.add({
            'date': date,
            'present': result['present'] ?? 0,
            'absent': result['absent'] ?? 0,
          });
        } catch (e) {
          tempData.add({
            'date': date,
            'present': 0,
            'absent': 0,
          });
        }
      }
    } else {
      for (int i = 6; i >= 0; i--) {
        DateTime date = DateTime.now().subtract(Duration(days: i));
        String dateStr = DateFormat('yyyy-MM-dd').format(date);
        var data = await AttendanceService.getAttendanceStatistics(dateStr);
        tempData.add({
          'date': date,
          'present': data?['present'] ?? 0,
          'absent': data?['absent'] ?? 0,
        });
      }
    }
    setState(() => last7DaysData = tempData);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Reports"),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.purple),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Selected Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy').format(selectedDate),
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _selectDate,
                                icon: Icon(Icons.edit_calendar, size: 18),
                                label: Text("Change"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text("View Class-wise", style: TextStyle(fontWeight: FontWeight.w500)),
                                    SizedBox(width: 8),
                                    Switch(
                                      value: isClassWiseView,
                                      onChanged: (value) {
                                        setState(() {
                                          isClassWiseView = value;
                                          if (value && selectedClass == null) {
                                            selectedClass = "1st";
                                          }
                                        });
                                        loadStatistics();
                                        loadLast7DaysData();
                                      },
                                      activeColor: Colors.purple,
                                    ),
                                  ],
                                ),
                              ),
                              if (isClassWiseView)
                                ElevatedButton(
                                  onPressed: _showClassSelector,
                                  child: Text(selectedClass ?? "Select Class"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade100,
                                    foregroundColor: Colors.purple,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Attendance Statistics",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Total Students",
                          totalStudents.toString(),
                          Colors.blue,
                          Icons.people,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          "Present",
                          presentStudents.toString(),
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Absent",
                          absentStudents.toString(),
                          Colors.red,
                          Icons.cancel,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          "Attendance %",
                          totalStudents > 0
                              ? "${((presentStudents / totalStudents) * 100).toStringAsFixed(1)}%"
                              : "0%",
                          Colors.orange,
                          Icons.percent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Last 7 Days Attendance",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  last7DaysData.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : _buildAttendanceGraph(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceGraph() {
    int maxValue = 0;
    for (var data in last7DaysData) {
      int total = data['present'] + data['absent'];
      if (total > maxValue) maxValue = total;
    }
    if (maxValue == 0) maxValue = 1;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Container(width: 16, height: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text("Present", style: TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Container(width: 16, height: 16, color: Colors.red),
                    SizedBox(width: 4),
                    Text("Absent", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: 200,
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: last7DaysData.map((data) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: _buildBar(data, maxValue),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(Map<String, dynamic> data, int maxValue) {
    int present = data['present'];
    int absent = data['absent'];
    DateTime date = data['date'];
    int total = present + absent;
    
    double presentHeight = maxValue > 0 ? (present / maxValue) * 150 : 0;
    double absentHeight = maxValue > 0 ? (absent / maxValue) * 150 : 0;

    bool isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(selectedDate);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
          totalStudents = total;
          presentStudents = present;
          absentStudents = absent;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: Colors.purple, width: 2) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (present > 0)
              Container(
                width: 30,
                height: presentHeight,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: Center(
                  child: Text(
                    present.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (absent > 0)
              Container(
                width: 30,
                height: absentHeight,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: present == 0 ? BorderRadius.vertical(top: Radius.circular(4)) : BorderRadius.zero,
                ),
                child: Center(
                  child: Text(
                    absent.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (present == 0 && absent == 0)
              Container(
                width: 30,
                height: 5,
                color: Colors.grey.shade300,
              ),
            SizedBox(height: 8),
            Text(
              DateFormat('dd').format(date),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.purple : Colors.black,
              ),
            ),
            Text(
              DateFormat('MMM').format(date),
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? Colors.purple : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClassSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Class"),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: classes.length,
            itemBuilder: (context, index) {
              String className = classes[index];
              bool isSelected = className == selectedClass;
              return ListTile(
                leading: Icon(
                  Icons.class_,
                  color: isSelected ? Colors.purple : Colors.grey,
                ),
                title: Text(
                  className,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.purple : Colors.black,
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check_circle, color: Colors.purple) : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => selectedClass = className);
                  loadStatistics();
                  loadLast7DaysData();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
