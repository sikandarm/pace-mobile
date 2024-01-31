import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class TasklogModel {
  int? id;
  int? taskId;
  String? breakStart;
  String? breakEnd;
  String? comment;
  int? iteration;

  TasklogModel(
      {this.id,
      this.taskId,
      this.breakStart,
      this.breakEnd,
      this.comment,
      this.iteration});

  TasklogModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taskId = json['task_id'];
    breakStart = json['break_start'];
    breakEnd = json['break_end'];
    comment = json['comment'];
    iteration = json['iteration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['task_id'] = this.taskId;
    data['break_start'] = this.breakStart;
    data['break_end'] = this.breakEnd;
    data['comment'] = this.comment;
    data['iteration'] = this.iteration;
    return data;
  }
}

Future<List<TasklogModel>> getTaskLogs({required int taskId}) async {
  List<TasklogModel> taskLogList = [];
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');

  final response = await http.get(
      Uri.parse('$BASE_URL/break-task/check-break-logs/$taskId'),
      headers: {
        'Authorization': 'Bearer $token',
      });
  final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

  // print(decodedResponse);

  // final logsList=decodedResponse['data'] as List;

  if (response.statusCode == 200) {
    taskLogList = (decodedResponse['data'] as List)
        .map((e) => TasklogModel.fromJson(e))
        .toList();
  } else {
    'Something went wrong';
  }

  return taskLogList;
}
