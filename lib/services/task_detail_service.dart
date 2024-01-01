import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class TaskDetailObj {
  final int id;
  final String? pmkNumber;
  final String? heatNo;
  final int? jobId;
  final int? userId;
  final String? description;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? status;
  final String? comments;
  final String? image;
  final String? projectManager;
  final String? QCI;
  final String? fitter;
  final String? welder;
  final String? painter;
  final String? foreman;

  TaskDetailObj({
    required this.id,
    required this.pmkNumber,
    required this.heatNo,
    required this.jobId,
    required this.userId,
    required this.description,
    required this.startedAt,
    required this.completedAt,
    required this.approvedAt,
    required this.approvedBy,
    required this.status,
    required this.comments,
    required this.image,
    required this.projectManager,
    required this.QCI,
    required this.fitter,
    required this.welder,
    required this.painter,
    required this.foreman,
  });
}

Future<List<TaskDetailObj>> fetchTaskDetail(int taskId) async {
  final response = await http.get(Uri.parse('$BASE_URL/task/$taskId'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    if (responseBody['success'] == true) {
      final dynamic taskData = responseBody['data']['task'];
      print(taskData);

      if (taskData != null && taskData is Map<String, dynamic>) {
        final TaskDetailObj task = TaskDetailObj(
          id: taskData['id'],
          pmkNumber: taskData['pmkNumber'] ??
              '', // Use null-coalescing operator to provide a default value
          heatNo: taskData['heatNo'] ?? '',

          jobId: taskData['jobId'] ?? 0,

          userId: taskData['userId'] ?? 0,

          description: taskData['description'] ?? '',
          startedAt: taskData['startedAt'] != null
              ? DateTime.parse(taskData['startedAt'])
              : null, // Use null-aware operator to safely parse DateTime
          completedAt: taskData['completedAt'] != null
              ? DateTime.parse(taskData['completedAt'])
              : null,
          approvedAt: taskData['approvedAt'] != null
              ? DateTime.parse(taskData['approvedAt'])
              : null,
          approvedBy: taskData['approvedBy'] ?? '',
          status: taskData['status'] ?? '',
          comments: taskData['comments'] ?? '',
          image: taskData['image'] ?? '',

          projectManager: taskData['projectManager'] ?? '',
          QCI: taskData['QCI'] ?? '',
          fitter: taskData['fitter'] ?? '',
          welder: taskData['welder'] ?? '',
          painter: taskData['painter'] ?? '',
          foreman: taskData['foreman'] ?? '',
        );

        return [task];
      }
    }
  }

  throw Exception('Failed to fetch tasks');
}
