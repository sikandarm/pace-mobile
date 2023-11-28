import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

enum TaskStatus {
  inProcess,
  priority,
  completed,
}

class Task {
  final int id;
  final String pmkNumber;
  final String? description;
  final DateTime? taskDate;
  final String status;

  Task(
      {required this.id,
      required this.pmkNumber,
      required this.description,
      required this.taskDate,
      required this.status});
}

Future<List<Task>> fetchTasks(int jobId) async {
  final response = await http.get(Uri.parse("$BASE_URL/task?jobId=$jobId"));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    final dynamic tasksData = responseBody['data'];

    if (tasksData != null &&
        tasksData is Map<String, dynamic> &&
        tasksData.isEmpty) {
      return []; // Return an empty list when no tasks are found
    }

    final dynamic tasksList = tasksData['tasks']['data'];

    if (tasksList != null && tasksList is List<dynamic>) {
      final List<Task> tasks = tasksList.map((item) {
        return Task(
          id: item['id'],
          pmkNumber: item['pmkNumber'],
          description: item['description'] ?? '',
          taskDate: item['startedAt'] != null
              ? DateTime.parse(item['startedAt'])
              : null,
          status: item['status'],
        );
      }).toList();
      return tasks;
    }
  }
  throw Exception('Failed to fetch tasks');
}
