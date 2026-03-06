class SubjectMarks {
  final String subjectName;
  final int marksObtained;
  final int totalMarks;

  SubjectMarks({
    required this.subjectName,
    required this.marksObtained,
    required this.totalMarks,
  });

  Map<String, dynamic> toJson() => {
    'subject_name': subjectName,
    'marks_obtained': marksObtained,
    'total_marks': totalMarks,
  };
}

class StudentMarks {
  final String rollNumber;
  final List<SubjectMarks> subjects;

  StudentMarks({
    required this.rollNumber,
    required this.subjects,
  });

  Map<String, dynamic> toJson() => {
    'roll_number': rollNumber,
    'subjects': subjects.map((s) => s.toJson()).toList(),
  };
}
