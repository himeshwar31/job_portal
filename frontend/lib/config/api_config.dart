import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API configuration for the JobConnect app.
class ApiConfig {
  /// Base URL for the API.
  /// Automatically detects if it should use '10.0.2.2' (Android Emulator)
  /// or 'localhost' (Web/Desktop/iOS).
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    try {
      if (Platform.isAndroid) {
        // Use local IP for physical devices, 10.0.2.2 is only for emulators
        return 'http://172.16.11.68:5000';
      }
    } catch (_) {
      // Platform.isAndroid can throw on web even with kIsWeb check in some cases
    }
    return 'http://localhost:5000';
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
