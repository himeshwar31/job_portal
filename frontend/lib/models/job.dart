class Job {
  final int id;
  final int recruiterId;
  final String title;
  final String company;
  final String description;
  final List<String> requiredSkills;
  final String location;
  final String salary;
  final String postedAt;
  final double? matchScore;
  final List<String>? missingSkills;
  final String? recruiterName;

  Job({
    required this.id,
    required this.recruiterId,
    required this.title,
    required this.company,
    required this.description,
    required this.requiredSkills,
    required this.location,
    required this.salary,
    required this.postedAt,
    this.matchScore,
    this.missingSkills,
    this.recruiterName,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? 0,
      recruiterId: json['recruiter_id'] ?? 0,
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      description: json['description'] ?? '',
      requiredSkills: json['required_skills'] != null
          ? List<String>.from(json['required_skills'])
          : [],
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      postedAt: json['posted_at'] ?? '',
      matchScore: json['matchScore']?.toDouble(),
      missingSkills: json['missingSkills'] != null
          ? List<String>.from(json['missingSkills'])
          : null,
      recruiterName: json['recruiter_name'],
    );
  }
}
