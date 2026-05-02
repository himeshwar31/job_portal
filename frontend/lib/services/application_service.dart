import '../config/api_config.dart';
import '../models/application.dart';
import 'api_service.dart';

class ApplicationService {
  final _api = ApiService();

  Future<Map<String, dynamic>> applyForJob(int jobId) async {
    try {
      final response = await _api.dio.post(
        ApiConfig.apply,
        data: {'job_id': jobId},
      );
      return {
        'success': true,
        'application': Application.fromJson(response.data['application']),
      };
    } catch (e) {
      String msg = 'Failed to apply';
      try {
        final dioError = e as dynamic;
        msg = dioError.response?.data?['error'] ?? msg;
      } catch (_) {}
      return {'success': false, 'error': msg};
    }
  }

  Future<List<Application>> getApplications() async {
    try {
      final response = await _api.dio.get(ApiConfig.applications);
      final List<dynamic> data = response.data['applications'] ?? [];
      return data.map((a) => Application.fromJson(a)).toList();
    } catch (e) {
      throw Exception('Failed to load applications');
    }
  }

  Future<List<Application>> getApplicants({int? jobId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (jobId != null) {
        queryParams['job_id'] = jobId;
      }
      final response = await _api.dio.get(
        ApiConfig.applicants,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['applicants'] ?? [];
      return data.map((a) => Application.fromJson(a)).toList();
    } catch (e) {
      throw Exception('Failed to load applicants');
    }
  }

  Future<Map<String, dynamic>> updateStatus(int applicationId, String status) async {
    try {
      await _api.dio.post(
        ApiConfig.updateStatus,
        data: {
          'application_id': applicationId,
          'status': status,
        },
      );
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': 'Failed to update status'};
    }
  }

  Future<Map<String, dynamic>> scheduleInterview(
      int applicationId, String interviewDate) async {
    try {
      await _api.dio.post(
        ApiConfig.scheduleInterview,
        data: {
          'application_id': applicationId,
          'interview_date': interviewDate,
        },
      );
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': 'Failed to schedule interview'};
    }
  }
}
