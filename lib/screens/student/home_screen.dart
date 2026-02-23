import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/attendance_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? studentData;
  final String? studentName;
  final String? studentClass;
  final String greeting;
  final Function(int) onTabChange;

  const HomeScreen({
    required this.studentData,
    required this.studentName,
    required this.studentClass,
    required this.greeting,
    required this.onTabChange,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<DateTime, String> attendanceMap = {};
  bool isLoadingAttendance = true;

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  int totalDays = 0;
  int presentCount = 0;
  int absentCount = 0;
  int lateCount = 0;

  @override
  void initState() {
    super.initState();
    loadMonthlyAttendance();
  }

  // ================= LOAD ATTENDANCE =================
  Future<void> loadMonthlyAttendance() async {
    if (widget.studentData == null) return;

    try {
      setState(() {
        isLoadingAttendance = true;
      });

      String studentId = widget.studentData!['id'];

      int month = focusedDay.month;
      int year = focusedDay.year;

      var response =
          await AttendanceService.getStudentMonthlyAttendanceFull(
        studentId: studentId,
        month: month.toString().padLeft(2, '0'),
        year: year.toString(),
      );

      totalDays = response['totalDays'] ?? 0;
      presentCount = response['present'] ?? 0;
      absentCount = response['absent'] ?? 0;
      lateCount = response['late'] ?? 0;

      List list = response['data'];

      Map<DateTime, String> tempMap = {};

      for (var item in list) {
        DateTime d = DateTime.parse(item['date']);
        tempMap[DateTime(d.year, d.month, d.day)] = item['status'];
      }

      setState(() {
        attendanceMap = tempMap;
        isLoadingAttendance = false;
      });
    } catch (e) {
      print("Attendance load error: $e");
      setState(() => isLoadingAttendance = false);
    }
  }

  // ================= CALENDAR =================
  Widget buildCalendar() {
    DateTime today = DateTime.now();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: TableCalendar(
          // IMPORTANT: Month navigation enable
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2035, 12, 31),

          focusedDay: focusedDay,

          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(Icons.chevron_left),
            rightChevronIcon: Icon(Icons.chevron_right),
          ),

          selectedDayPredicate: (day) {
            return selectedDay != null &&
                day.year == selectedDay!.year &&
                day.month == selectedDay!.month &&
                day.day == selectedDay!.day;
          },

          onDaySelected: (selected, focused) {
            if (selected.isAfter(today)) return;
            setState(() {
              selectedDay = selected;
              focusedDay = focused;
            });
          },

          // Month change → API call
          onPageChanged: (day) {
            setState(() {
              focusedDay = day;
            });
            loadMonthlyAttendance();
          },

          calendarBuilders: CalendarBuilders(
            todayBuilder: (context, day, focusedDay) {
              return _dayBuilder(day, today);
            },
            defaultBuilder: (context, day, focusedDay) {
              return _dayBuilder(day, today);
            },
          ),
        ),
      ),
    );
  }

  // ================= DAY BUILDER =================
  Widget _dayBuilder(DateTime day, DateTime today) {
    DateTime key = DateTime(day.year, day.month, day.day);

    // Future disabled
    if (day.isAfter(today)) {
      return Center(
        child: Text('${day.day}', style: TextStyle(color: Colors.grey)),
      );
    }

    // Sunday
    if (day.weekday == DateTime.sunday) {
      return Center(
        child: Text('${day.day}', style: TextStyle(color: Colors.red)),
      );
    }

    String? status = attendanceMap[key];

    Color? bgColor;
    if (status == "Present") bgColor = Colors.green;
    if (status == "Absent") bgColor = Colors.red;
    if (status == "Late") bgColor = Colors.orange;

    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: bgColor != null ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget buildSummaryCard() {
    return Card(
      margin: EdgeInsets.only(top: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_monthName(focusedDay.month)} ${focusedDay.year} Attendance Summary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem("Total", totalDays, Colors.blue),
                _summaryItem("Present", presentCount, Colors.green),
                _summaryItem("Absent", absentCount, Colors.red),
                _summaryItem("Late", lateCount, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$count",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        SizedBox(height: 4),
        Text(title),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      "",
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month];
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.greeting, style: TextStyle(fontSize: 20)),
          Text(
            widget.studentName ?? "Student",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("Class: ${widget.studentClass}"),
          SizedBox(height: 20),

          isLoadingAttendance
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    buildCalendar(),
                    buildSummaryCard(),
                  ],
                ),
        ],
      ),
    );
  }
}