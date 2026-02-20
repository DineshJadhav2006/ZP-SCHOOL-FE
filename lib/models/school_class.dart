class SchoolClass {
  final String id;
  final String name;
  final String division;
  final String teacherId;
  final String teacherName;
  final int totalStudents;

  SchoolClass({
    required this.id,
    required this.name,
    required this.division,
    required this.teacherId,
    required this.teacherName,
    required this.totalStudents,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      division: json['division'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      totalStudents: json['totalStudents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'division': division,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'totalStudents': totalStudents,
    };
  }
}