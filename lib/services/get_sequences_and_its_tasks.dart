import 'dart:convert';

import 'package:com_a3_pace/utils/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class SequenceModelNew {
  int? sequenceId;
  String? jobId;
  String? sequenceName;
  List<TaskModel>? tasks;

  SequenceModelNew(
      {this.sequenceId, this.jobId, this.sequenceName, this.tasks});

  SequenceModelNew.fromJson(Map<String, dynamic> json) {
    sequenceId = json['SequenceId'];
    jobId = json['JobId'];
    sequenceName = json['sequenceName'];
    if (json['tasks'] != null) {
      tasks = <TaskModel>[];
      json['tasks'].forEach((v) {
        tasks!.add(TaskModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['SequenceId'] = this.sequenceId;
    data['JobId'] = this.jobId;
    data['sequenceName'] = this.sequenceName;
    if (this.tasks != null) {
      data['tasks'] = this.tasks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TaskModel {
  int? id;
  String? pmkNumber;
  String? description;
  String? status;
  String? startedAt;
  String? completedAt;

  TaskModel(
      {this.id,
      this.pmkNumber,
      this.description,
      this.status,
      this.startedAt,
      this.completedAt});

  TaskModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pmkNumber = json['PmkNumber'];
    description = json['description'];
    status = json['status'];
    startedAt = json['startedAt'];
    completedAt = json['completedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['PmkNumber'] = this.pmkNumber;
    data['description'] = this.description;
    data['status'] = this.status;
    data['startedAt'] = this.startedAt;
    data['completedAt'] = this.completedAt;
    return data;
  }
}

Future<List<dynamic>> getAllSequencesWithItsTasks({required int jobID}) async {
  List<dynamic> sequencesList = [];

  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');

  final response = await http.get(
      Uri.parse('$BASE_URL/sequencestask/getsequenceandtask/$jobID'),
      headers: {
        'Authorization': 'Bearer $token',
      });

  // print(response.body);

  Map<String, dynamic> decodedResponse = jsonDecode(response.body);

  // print('decodedResponse :' + decodedResponse.toString());

  if (decodedResponse['data'] is List && decodedResponse['data'] != []) {
    sequencesList = decodedResponse['data'] as List<dynamic>;
  }

  // if (decodedResponse['data'] != []) {
  //   print(decodedResponse['data'][0]);
  // }

  // print('sequencesList:' + sequencesList.toString());
  // print('sequencesList Length:' + sequencesList.length.toString());

  return sequencesList;
}
