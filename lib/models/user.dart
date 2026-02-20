class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String name;
  final String? classAssigned;
  final String? division;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.name,
    this.classAssigned,
    this.division,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      classAssigned: json['classAssigned'],
      division: json['division'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'name': name,
      'classAssigned': classAssigned,
      'division': division,
    };
  }
}