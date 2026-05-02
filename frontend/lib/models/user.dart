class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final List<String> skills;
  final String education;
  final String experience;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.skills = const [],
    this.education = '',
    this.experience = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      skills: json['skills'] != null
          ? List<String>.from(json['skills'])
          : [],
      education: json['education'] ?? '',
      experience: json['experience'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'skills': skills,
      'education': education,
      'experience': experience,
    };
  }

  bool get isRecruiter => role == 'recruiter';
  bool get isJobSeeker => role == 'job_seeker';
}
