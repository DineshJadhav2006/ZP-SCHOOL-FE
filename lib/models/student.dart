class Student {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String standard;
  final String division;
  final String mobileNumber;
  final String parentName;

  Student({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.standard,
    required this.division,
    required this.mobileNumber,
    required this.parentName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      standard: json['standard'] ?? '',
      division: json['division'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      parentName: json['parent_name'] ?? '',
    );
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return "$firstName $middleName $lastName";
    }
    return "$firstName $lastName";
  }
}
