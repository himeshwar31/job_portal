import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final data = response.data;
      await ApiService.saveToken(data['token']);
      await _saveUserData(data['user']);

      return {'success': true, 'user': User.fromJson(data['user'])};
    } catch (e) {
      return {'success': false, 'error': _getErrorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      await ApiService.saveToken(data['token']);
      await _saveUserData(data['user']);

      return {'success': true, 'user': User.fromJson(data['user'])};
    } catch (e) {
      return {'success': false, 'error': _getErrorMessage(e)};
    }
  }

  Future<void> logout() async {
    await ApiService.removeToken();
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      try {
        final dioError = error as dynamic;
        if (dioError.response?.data != null) {
          return dioError.response.data['error'] ?? 'Something went wrong';
        }
      } catch (_) {}
    }
    return 'Connection error. Please check your internet.';
  }
}
