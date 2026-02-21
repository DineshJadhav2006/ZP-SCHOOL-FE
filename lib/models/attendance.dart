class Attendance {
  final String id;
  final String studentId;
  final String teacherId;
  final String status;
  final String? remark;
  final AttendanceStudent student;
  final AttendanceTeacher teacher;

  Attendance({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.status,
    this.remark,
    required this.student,
    required this.teacher,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      status: json['status'] ?? '',
      remark: json['remark'],
      student: AttendanceStudent.fromJson(json['student'] ?? {}),
      teacher: AttendanceTeacher.fromJson(json['teacher'] ?? {}),
    );
  }
}

class AttendanceStudent {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String standard;
  final String division;
  final String? rollNumber;
  final String mobileNumber; // ✅ ADDED

  AttendanceStudent({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.standard,
    required this.division,
    this.rollNumber,
    required this.mobileNumber,
  });

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) {
    return AttendanceStudent(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      standard: json['standard'] ?? '',
      division: json['division'] ?? '',
      rollNumber: json['roll_number'],
      mobileNumber: json['mobile_number'] ?? '', // ✅ IMPORTANT
    );
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return "$firstName $middleName $lastName";
    }
    return "$firstName $lastName";
  }
}

class AttendanceTeacher {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;

  AttendanceTeacher({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
  });

  factory AttendanceTeacher.fromJson(Map<String, dynamic> json) {
    return AttendanceTeacher(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
    );
  }
}