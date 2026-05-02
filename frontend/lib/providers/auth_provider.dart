import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isRecruiter => _user?.role == 'recruiter';
  bool get isJobSeeker => _user?.role == 'job_seeker';

  /// Try to restore session from stored token
  Future<bool> tryAutoLogin() async {
    final isLogged = await _authService.isLoggedIn();
    if (isLogged) {
      _user = await _authService.getStoredUser();
      if (_user != null) {
        // Fetch fresh profile
        try {
          final api = ApiService();
          final response = await api.dio.get(ApiConfig.profile);
          _user = User.fromJson(response.data);
        } catch (_) {
          // Use stored data if API fails
        }
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    _isLoading = false;
    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    _isLoading = false;
    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    List<String>? skills,
    String? education,
    String? experience,
  }) async {
    try {
      final api = ApiService();
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (skills != null) data['skills'] = skills;
      if (education != null) data['education'] = education;
      if (experience != null) data['experience'] = experience;

      final response = await api.dio.put(ApiConfig.profile, data: data);
      _user = User.fromJson(response.data['user']);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
