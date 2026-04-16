import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/attendance_service.dart';
import 'complaint_screen.dart';
import 'my_complaints_screen.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.blue.shade100, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
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
              return _dayBuilder(day, today, isToday: true);
            },
            defaultBuilder: (context, day, focusedDay) {
              return _dayBuilder(day, today);
            },
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, duration: 500.ms);
  }

  // ================= DAY BUILDER =================
  Widget _dayBuilder(DateTime day, DateTime today, {bool isToday = false}) {
    DateTime key = DateTime(day.year, day.month, day.day);
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    String? status = attendanceMap[key];

    // Status available → Show color circle regardless of day type
    if (status != null) {
      Color bgColor = Colors.grey.shade300;
      if (status == "Present") bgColor = Colors.green.shade400;
      if (status == "Absent") bgColor = Colors.red.shade400;
      if (status == "Late") bgColor = Colors.orange.shade400;

      return Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.4),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ).animate(target: isToday ? 1 : 0).scale(begin: Offset(1,1), end: Offset(1.1, 1.1), duration: 500.ms);
    }

    // Future disabled
    if (key.isAfter(todayDate)) {
      return Center(
        child: Text('${day.day}', style: TextStyle(color: Colors.grey.shade400)),
      );
    }

    // Sunday
    if (day.weekday == DateTime.sunday) {
      return Center(
        child: Text('${day.day}', style: TextStyle(color: Colors.red)),
      );
    }

    return Center(
      child: Text(
        '${day.day}',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget buildSummaryCard() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.purple.shade50, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars_rounded, color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text(
                  "${_monthName(focusedDay.month)} ${focusedDay.year} Progress",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.purple.shade900),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem("Total", totalDays, Colors.blue.shade400, Icons.calendar_month_rounded),
                _summaryItem("Present", presentCount, Colors.green.shade400, Icons.check_circle_rounded),
                _summaryItem("Absent", absentCount, Colors.red.shade400, Icons.cancel_rounded),
                _summaryItem("Late", lateCount, Colors.orange.shade400, Icons.watch_later_rounded),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _summaryItem(String title, int count, Color color, IconData icon) {
    return Flexible(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(height: 4),
                Text(
                  "$count",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900, color: color),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
          ),
        ],
      ),
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
    String emoji = "👋";
    if (widget.greeting.contains("Morning")) emoji = "🌅";
    if (widget.greeting.contains("Afternoon")) emoji = "☀️";
    if (widget.greeting.contains("Evening")) emoji = "🌇";
    if (widget.greeting.contains("Night")) emoji = "🌙";

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.cyan.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: TextStyle(fontSize: 28)),
                    SizedBox(width: 8),
                    Text(
                      widget.greeting, 
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  widget.studentName ?? "Student",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Class ${widget.studentClass}",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: -0.2, duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
          
          SizedBox(height: 30),

          isLoadingAttendance
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    buildCalendar(),
                    buildSummaryCard(),
                  ],
                ),
          SizedBox(height: 20),
          _buildComplaintButton(context),
        ],
      ),
    );
  }

  Widget _buildComplaintButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MyComplaintsScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.report_problem, color: Colors.white, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Complaints',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'View and submit complaints',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}