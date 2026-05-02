import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/job_service.dart';

class JobProvider extends ChangeNotifier {
  final JobService _jobService = JobService();

  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadJobs({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jobs = await _jobService.getJobs(search: search);
    } catch (e) {
      _error = 'Failed to load jobs';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> postJob({
    required String title,
    required String company,
    required String description,
    required List<String> requiredSkills,
    required String location,
    required String salary,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _jobService.postJob(
      title: title,
      company: company,
      description: description,
      requiredSkills: requiredSkills,
      location: location,
      salary: salary,
    );

    _isLoading = false;

    if (result['success']) {
      await loadJobs(); // Refresh job list
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }
}
