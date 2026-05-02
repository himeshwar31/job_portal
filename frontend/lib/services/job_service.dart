import '../config/api_config.dart';
import '../models/job.dart';
import 'api_service.dart';

class JobService {
  final _api = ApiService();

  Future<List<Job>> getJobs({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _api.dio.get(
        ApiConfig.jobs,
        queryParameters: queryParams,
      );

      final List<dynamic> jobsData = response.data['jobs'] ?? [];
      return jobsData.map((j) => Job.fromJson(j)).toList();
    } catch (e) {
      throw Exception('Failed to load jobs');
    }
  }

  Future<Map<String, dynamic>> postJob({
    required String title,
    required String company,
    required String description,
    required List<String> requiredSkills,
    required String location,
    required String salary,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiConfig.postJob,
        data: {
          'title': title,
          'company': company,
          'description': description,
          'required_skills': requiredSkills,
          'location': location,
          'salary': salary,
        },
      );
      return {'success': true, 'job': Job.fromJson(response.data['job'])};
    } catch (e) {
      return {'success': false, 'error': 'Failed to post job'};
    }
  }
}
