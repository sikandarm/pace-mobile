import 'dart:async';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../api/auth_interceptor.dart';
import '../utils/constants.dart';

enum JobStatus {
  inProcess,
  priority,
  completed,
}

class Job {
  final int id;
  final String name;
  final String description;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int totalTasks;
  final int completedTasks;

  Job(
      {required this.id,
      required this.name,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.totalTasks,
      required this.completedTasks,
      required this.status});

  String get formattedDate => DateFormat(US_DATE_FORMAT).format(startDate);
}

Future<List<Job>> fetchJobs() async {
  final String bearerToken = await getStringFromSF(BL_USER_TOKEN);
  final Dio dio = Dio();
  dio.interceptors.add(AuthInterceptor(bearerToken));
  final response = await dio.get("$BASE_URL/job");

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = response.data;
    final List<dynamic> data = responseBody['data']['jobs'];

    final List<Job> jobs = data.map((item) {
      DateTime? startDate;
      if (item['startDate'] != null) {
        startDate = DateTime.tryParse(item['startDate']);
      }

      DateTime? endDate;
      if (item['endDate'] != null) {
        endDate = DateTime.tryParse(item['endDate']);
      }

      return Job(
        id: item['id'] ?? 0,
        name: item['name'] ?? '',
        description: item['description'] ?? '',
        startDate: startDate ?? DateTime(1970), // Provide a default value
        endDate: endDate ?? DateTime(1970), // Provide a default value
        totalTasks: item['totalTasks'] ?? 0,
        completedTasks: item['completedTasks'] ?? 0,
        status: item['status'] ?? '',
      );
    }).toList();
    return jobs;
  } else {
    throw Exception('Failed to fetch tasks');
  }
}
