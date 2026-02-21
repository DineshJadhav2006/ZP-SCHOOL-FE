import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../services/homework_service.dart';
import '../../localization/language_service.dart';
import 'package:intl/intl.dart';
import '../login_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;
  Map<String, dynamic>? studentData;
  List<dynamic> homeworkList = [];
  bool isLoading = true;
  bool isHomeworkLoading = false;
  String? studentName = "Student";
  String? studentClass = "Class";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadStudentData();
  }

  Future<void> loadStudentData() async {
    try {
      final student = await StudentService.getStudent();
      
      if (student != null) {
        String firstName = student['first_name'] ?? '';
        String lastName = student['last_name'] ?? '';
        String standard = student['standard'] ?? '';
        
        setState(() {
          studentData = student;
          studentName = '$firstName $lastName'.trim();
          studentClass = standard;
          isLoading = false;
        });
        
        // Load homework for student's class
        await loadHomework(standard);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading student data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadHomework(String className) async {
    setState(() => isHomeworkLoading = true);
    try {
      var data = await HomeworkService.getHomeworkByClass(className);
      setState(() {
        homeworkList = data;
        isHomeworkLoading = false;
      });
    } catch (e) {
      print("Error loading homework: $e");
      setState(() {
        isHomeworkLoading = false;
      });
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 20) return "Good Evening";
    return "Good Night";
  }

  // ================= HOME =================
  Widget homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting(), style: TextStyle(fontSize: 20)),
              Text(
                studentName ?? "Student",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text("Class: $studentClass"),
            ],
          ),
          SizedBox(height: 30),
          
          // Info cards grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildInfoCard(
                "📚 Homework",
                "View assigned tasks",
                Colors.orange,
                () {
                  setState(() => selectedIndex = 1);
                },
              ),
              _buildInfoCard(
                "📊 Results",
                "Check your marks",
                Colors.purple,
                () {
                  setState(() => selectedIndex = 2);
                },
              ),
            ],
          ),

          SizedBox(height: 30),
          
          // Student Details
          if (studentData != null)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Student Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    "Roll No",
                    (studentData?['roll_number']?.toString() ?? "").isEmpty ? "-" : studentData?['roll_number']?.toString() ?? "-",
                  ),
                  _buildDetailRow(
                    "Unique ID",
                    studentData?['unique_id']?.toString() ?? "-",
                  ),
                  _buildDetailRow(
                    "Standard",
                    studentData?['standard']?.toString() ?? "-",
                  ),
                  _buildDetailRow(
                    "Division",
                    studentData?['division']?.toString() ?? "-",
                  ),
                  _buildDetailRow(
                    "Mobile",
                    studentData?['mobile_number']?.toString() ?? "-",
                  ),
                  _buildDetailRow(
                    "Parent Name",
                    studentData?['parent_name']?.toString() ?? "-",
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ================= HOMEWORK =================
  Widget homeworkPage() {
    return RefreshIndicator(
      onRefresh: () => loadHomework(studentClass ?? ""),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Homework",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => loadHomework(studentClass ?? ""),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            if (isHomeworkLoading)
              Center(child: CircularProgressIndicator())
            else if (homeworkList.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No homework assigned",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...homeworkList.map((hw) => _buildHomeworkCard(hw)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkCard(Map<String, dynamic> hw) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          hw["subject_name"] ?? "Subject",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        subtitle: Text(
          "Due: ${formatDate(hw['homework_date'])}",
          style: TextStyle(fontSize: 12),
        ),
        children: [
          Divider(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  hw["homework_text"] ?? "-",
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(formatDate(hw['homework_date']) ?? "-"),
                      ],
                    ),
                    if (hw["attachment_url"] != null && hw["attachment_url"].toString().isNotEmpty)
                      ElevatedButton.icon(
                        icon: Icon(Icons.download, size: 16),
                        label: Text("Attachment"),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Download feature coming soon")),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= RESULTS =================
  Widget resultsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Results",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          
          // Exam Results
          _buildResultCard("Half Yearly", [
            {"subject": "Math", "marks": "85/100"},
            {"subject": "English", "marks": "78/100"},
            {"subject": "Science", "marks": "92/100"},
            {"subject": "Marathi", "marks": "88/100"},
          ]),
          
          SizedBox(height: 16),
          
          _buildResultCard("Quarterly", [
            {"subject": "Math", "marks": "80/100"},
            {"subject": "English", "marks": "75/100"},
            {"subject": "Science", "marks": "88/100"},
            {"subject": "Marathi", "marks": "85/100"},
          ]),
        ],
      ),
    );
  }

  // ================= PROFILE =================
  Widget profilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, size: 60, color: Colors.blue),
          ),
          SizedBox(height: 20),
          
          Text(
            studentName ?? "Student",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Class: $studentClass",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          
          SizedBox(height: 30),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Personal Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow("Full Name", studentName ?? "-"),
                _buildDetailRow("Roll No", (studentData?['roll_number']?.toString() ?? "").isEmpty ? "-" : studentData?['roll_number']?.toString() ?? "-"),
                _buildDetailRow("Unique ID", studentData?['unique_id']?.toString() ?? "-"),
                _buildDetailRow("Aadhar Number", studentData?['aadhar_number']?.toString() ?? "-"),
                _buildDetailRow("Standard", studentData?['standard']?.toString() ?? "-"),
                _buildDetailRow("Division", studentData?['division']?.toString() ?? "-"),
                _buildDetailRow("Mobile", studentData?['mobile_number']?.toString() ?? "-"),
                _buildDetailRow("Parent", studentData?['parent_name']?.toString() ?? "-"),
                _buildDetailRow("Gender", studentData?['gender']?.toString() ?? "-"),
                _buildDetailRow("DOB", formatDate(studentData?['date_of_birth']?.toString())),
                _buildDetailRow("Address", studentData?['address']?.toString() ?? "-"),
                _buildDetailRow("Category", studentData?['category']?.toString() ?? "-"),
                _buildDetailRow("Admission Date", formatDate(studentData?['admission_date']?.toString())),
              ],
            ),
          ),
          
          SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await AuthService.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: Text("Logout"),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ZP SCHOOL MANDAVE KH",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Student Dashboard",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PageStorage(
              bucket: PageStorageBucket(),
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  homePage(),
                  homeworkPage(),
                  resultsPage(),
                  profilePage(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Homework",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: "Results",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String examName, List<Map<String, String>> results) {
    return Card(
      child: ExpansionTile(
        title: Text(
          examName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Divider(),
          ...results.map((result) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(result['subject'] ?? ''),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result['marks'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
