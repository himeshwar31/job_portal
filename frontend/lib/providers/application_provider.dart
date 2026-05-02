import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/application_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationService _service = ApplicationService();

  List<Application> _applications = [];
  List<Application> _applicants = [];
  bool _isLoading = false;
  String? _error;

  List<Application> get applications => _applications;
  List<Application> get applicants => _applicants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> applyForJob(int jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.applyForJob(jobId);
    _isLoading = false;

    if (result['success']) {
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  Future<void> loadApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await _service.getApplications();
    } catch (e) {
      _error = 'Failed to load applications';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadApplicants({int? jobId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applicants = await _service.getApplicants(jobId: jobId);
    } catch (e) {
      _error = 'Failed to load applicants';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus(int applicationId, String status) async {
    final result = await _service.updateStatus(applicationId, status);
    if (result['success']) {
      await loadApplicants();
      return true;
    }
    _error = result['error'];
    notifyListeners();
    return false;
  }

  Future<bool> scheduleInterview(int applicationId, String date) async {
    final result = await _service.scheduleInterview(applicationId, date);
    if (result['success']) {
      await loadApplicants();
      return true;
    }
    _error = result['error'];
    notifyListeners();
    return false;
  }
}
