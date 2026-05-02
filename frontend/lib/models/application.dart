class Application {
  final int id;
  final int jobId;
  final int userId;
  final String status;
  final double matchScore;
  final List<String> missingSkills;
  final String appliedAt;
  final String? interviewDate;
  final String? jobTitle;
  final String? company;
  final String? location;
  // Recruiter-specific fields
  final String? applicantName;
  final String? applicantEmail;
  final List<String>? applicantSkills;
  final String? applicantEducation;
  final String? applicantExperience;

  Application({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.status,
    required this.matchScore,
    required this.missingSkills,
    required this.appliedAt,
    this.interviewDate,
    this.jobTitle,
    this.company,
    this.location,
    this.applicantName,
    this.applicantEmail,
    this.applicantSkills,
    this.applicantEducation,
    this.applicantExperience,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] ?? 0,
      jobId: json['job_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? 'pending',
      matchScore: (json['match_score'] ?? 0).toDouble(),
      missingSkills: json['missing_skills'] != null
          ? List<String>.from(json['missing_skills'])
          : [],
      appliedAt: json['applied_at'] ?? '',
      interviewDate: json['interview_date'],
      jobTitle: json['job_title'],
      company: json['company'],
      location: json['location'],
      applicantName: json['applicant_name'],
      applicantEmail: json['applicant_email'],
      applicantSkills: json['applicant_skills'] != null
          ? List<String>.from(json['applicant_skills'])
          : null,
      applicantEducation: json['applicant_education'],
      applicantExperience: json['applicant_experience'],
    );
  }
}
