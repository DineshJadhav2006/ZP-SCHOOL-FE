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
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th"
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Reports"),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await loadStatistics();
                await loadLast7DaysData();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateSelector(theme),
                    SizedBox(height: 30),
                    _buildSectionHeader("Today's Overview"),
                    SizedBox(height: 16),
                    _buildStatsGrid(theme),
                    SizedBox(height: 32),
                    _buildSectionHeader("Attendance Trends (7 Days)"),
                    SizedBox(height: 16),
                    _buildAttendanceGraph(theme),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.calendar_today, color: theme.primaryColor, size: 20),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Report Date", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  Text(DateFormat('dd MMMM yyyy').format(selectedDate), 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Spacer(),
              IconButton(onPressed: _selectDate, icon: Icon(Icons.edit_calendar, color: theme.primaryColor)),
            ],
          ),
          Divider(height: 32),
          Row(
            children: [
              Text("Class-wise View", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              SizedBox(width: 12),
              Switch.adaptive(
                value: isClassWiseView,
                onChanged: (value) {
                  setState(() {
                    isClassWiseView = value;
                    if (value && selectedClass == null) selectedClass = "1st";
                  });
                  loadStatistics();
                  loadLast7DaysData();
                },
                activeColor: theme.primaryColor,
              ),
              if (isClassWiseView) ...[
                Spacer(),
                GestureDetector(
                  onTap: _showClassSelector,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(selectedClass ?? "Select", 
                            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        Icon(Icons.unfold_more, size: 14, color: theme.primaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _statCard("Total Students", totalStudents.toString(), Colors.blue, Icons.people_outline),
        _statCard("Present Today", presentStudents.toString(), Colors.green, Icons.check_circle_outline),
        _statCard("Absent Today", absentStudents.toString(), Colors.red, Icons.cancel_outlined),
        _statCard("Efficiency", totalStudents > 0 ? "${((presentStudents / totalStudents) * 100).toStringAsFixed(1)}%" : "0%",
            Colors.orange, Icons.insights),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAttendanceGraph(ThemeData theme) {
    if (last7DaysData.isEmpty) return Center(child: CircularProgressIndicator());
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem("Present", Colors.green),
              SizedBox(width: 24),
              _legendItem("Absent", Colors.red),
            ],
          ),
          SizedBox(height: 24),
          _customChart(theme),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _customChart(ThemeData theme) {
    int maxValue = 0;
    for (var data in last7DaysData) {
      int total = data['present'] + data['absent'];
      if (total > maxValue) maxValue = total;
    }
    if (maxValue == 0) maxValue = 1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 200,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: last7DaysData.map((data) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: _buildBar(data, maxValue, theme),
            );
          }).toList(),
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

  Widget _buildBar(Map<String, dynamic> data, int maxValue, ThemeData theme) {
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Select Class",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "View attendance reports by class",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  String className = classes[index];
                  bool isSelected = className == selectedClass;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          selectedClass = className;
                          loadStatistics();
                          loadLast7DaysData();
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purple.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.purple.shade200 : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.purple.shade100 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.class_rounded,
                                color: isSelected ? Colors.purple.shade700 : Colors.grey.shade400,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              className,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.purple.shade900 : Colors.black87,
                              ),
                            ),
                            Spacer(),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: Colors.purple.shade700, size: 28),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
