import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API configuration for the JobConnect app.
class ApiConfig {
  /// Base URL for the API.
  /// Points to the deployed backend on Render.
  static String get baseUrl {
    return 'https://job-portal-knv8.onrender.com';
  }

  // Auth endpoints
  static const String register = '/register';
  static const String login = '/login';

  // Profile endpoints
  static const String profile = '/profile';

  // Job endpoints
  static const String jobs = '/jobs';
  static const String postJob = '/post-job';

  // Application endpoints
  static const String apply = '/apply';
  static const String applications = '/applications';
  static const String applicants = '/applicants';
  static const String updateStatus = '/update-status';
  static const String scheduleInterview = '/schedule-interview';

  // Chat endpoints
  static const String sendMessage = '/send-message';
  static const String messages = '/messages';
  static const String conversations = '/conversations';
}
