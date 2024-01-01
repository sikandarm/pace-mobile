import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class Sequence2Model {
  final String? sequenceName;
  final String? jobId;
  final String? jobName;
  Sequence2Model({
    this.sequenceName,
    this.jobId,
    this.jobName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sequenceName': sequenceName,
      'jobId': jobId,
      'jobName': jobName,
    };
  }

  factory Sequence2Model.fromMap(Map<String, dynamic> map) {
    return Sequence2Model(
      sequenceName:
          map['sequenceName'] != null ? map['sequenceName'] as String : null,
      jobId: map['jobId'] != null ? map['jobId'] as String : null,
      jobName: map['jobName'] != null ? map['jobName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sequence2Model.fromJson(String source) =>
      Sequence2Model.fromMap(json.decode(source) as Map<String, dynamic>);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class Tasks2Model {
  int? id;
  String? pmkNumber;
  String? heatNo;
  int? jobId;
  int? userId;
  int? estimatedHour;
  String? description;
  String? startedAt;
  String? completedAt;
  String? approvedAt;
  String? approvedBy;
  String? status;
  String? image;
  String? comments;
  List<String>? rejectionReason;
  String? projectManager;
  String? qCI;
  String? fitter;
  String? welder;
  String? painter;
  String? foreman;
  String? cOPQ;
  Tasks2Model({
    this.id,
    this.pmkNumber,
    this.heatNo,
    this.jobId,
    this.userId,
    this.estimatedHour,
    this.description,
    this.startedAt,
    this.completedAt,
    this.approvedAt,
    this.approvedBy,
    this.status,
    this.image,
    this.comments,
    this.rejectionReason,
    this.projectManager,
    this.qCI,
    this.fitter,
    this.welder,
    this.painter,
    this.foreman,
    this.cOPQ,
  });

  Tasks2Model copyWith({
    int? id,
    String? pmkNumber,
    String? heatNo,
    int? jobId,
    int? userId,
    int? estimatedHour,
    String? description,
    String? startedAt,
    DateTime? completedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? status,
    String? image,
    String? comments,
    List<String>? rejectionReason,
    String? projectManager,
    String? qCI,
    String? fitter,
    String? welder,
    String? painter,
    String? foreman,
    String? cOPQ,
  }) {
    return Tasks2Model(
      id: id ?? this.id,
      pmkNumber: pmkNumber ?? this.pmkNumber,
      heatNo: heatNo ?? this.heatNo,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      estimatedHour: estimatedHour ?? this.estimatedHour,
      description: description ?? this.description,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt.toString() ?? this.completedAt,
      approvedAt: approvedAt.toString() ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      status: status ?? this.status,
      image: image ?? this.image,
      comments: comments ?? this.comments,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      projectManager: projectManager ?? this.projectManager,
      qCI: qCI ?? this.qCI,
      fitter: fitter ?? this.fitter,
      welder: welder ?? this.welder,
      painter: painter ?? this.painter,
      foreman: foreman ?? this.foreman,
      cOPQ: cOPQ ?? this.cOPQ,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'pmkNumber': pmkNumber,
      'heatNo': heatNo,
      'jobId': jobId,
      'userId': userId,
      'estimatedHour': estimatedHour,
      'description': description,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'approvedAt': approvedAt,
      'approvedBy': approvedBy,
      'status': status,
      'image': image,
      'comments': comments,
      'rejectionReason': rejectionReason,
      'projectManager': projectManager,
      'qCI': qCI,
      'fitter': fitter,
      'welder': welder,
      'painter': painter,
      'foreman': foreman,
      'cOPQ': cOPQ,
    };
  }

  factory Tasks2Model.fromMap(Map<String, dynamic> map) {
    return Tasks2Model(
      id: map['id'] != null ? map['id'] as int : null,
      pmkNumber: map['pmkNumber'] != null ? map['pmkNumber'] as String : null,
      heatNo: map['heatNo'] != null ? map['heatNo'] as String : null,
      jobId: map['jobId'] != null ? map['jobId'] as int : null,
      userId: map['userId'] != null ? map['userId'] as int : null,
      estimatedHour:
          map['estimatedHour'] != null ? map['estimatedHour'] as int : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      startedAt: map['startedAt'] != null ? map['startedAt'] as String : null,
      completedAt: map['completedAt'] != null ? map['completedAt'] : null,
      approvedAt: map['approvedAt'] != null ? map['approvedAt'] : null,
      approvedBy:
          map['approvedBy'] != null ? map['approvedBy'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      comments: map['comments'] != null ? map['comments'] as String : null,
      rejectionReason: map['rejectionReason'] != null
          ? List<String>.from((map['rejectionReason'] as List<dynamic>))
          : null,
      projectManager: map['projectManager'] != null
          ? map['projectManager'] as String
          : null,
      qCI: map['qCI'] != null ? map['qCI'] as String : null,
      fitter: map['fitter'] != null ? map['fitter'] as String : null,
      welder: map['welder'] != null ? map['welder'] as String : null,
      painter: map['painter'] != null ? map['painter'] as String : null,
      foreman: map['foreman'] != null ? map['foreman'] as String : null,
      cOPQ: map['cOPQ'] != null ? map['cOPQ'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tasks2Model.fromJson(String source) =>
      Tasks2Model.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Tasks2Model(id: $id, pmkNumber: $pmkNumber, heatNo: $heatNo, jobId: $jobId, userId: $userId, estimatedHour: $estimatedHour, description: $description, startedAt: $startedAt, completedAt: $completedAt, approvedAt: $approvedAt, approvedBy: $approvedBy, status: $status, image: $image, comments: $comments, rejectionReason: $rejectionReason, projectManager: $projectManager, qCI: $qCI, fitter: $fitter, welder: $welder, painter: $painter, foreman: $foreman, cOPQ: $cOPQ)';
  }
}

// Future<List<Tasks2Model>> getAllTasksWithSequence(
Future<Map<String, dynamic>> getAllTasksWithSequence(
    {required String jobID}) async {
  Map<String, dynamic> map = {
    'tasks2ModelList': [],
    'sequence2model': Sequence2Model(),
  };
  List<Tasks2Model> tasks2ModelList = [];
  Sequence2Model sequence2model = Sequence2Model();
  final tokenBox = await Hive.openBox('tokenBox');

  final token = tokenBox.get('token');
  final response =
      await http.get(Uri.parse('$BASE_URL/task?jobId=$jobID'), headers: {
    'Authorization': 'Bearer $token',
  });

  // print(response.body);

  final Map<String, dynamic> decodedResponse = jsonDecode(response.body);

  if (decodedResponse['message'] == 'Successful') {
    final allTasks = decodedResponse['data']['tasks']['data'] as List;

    print('check sequences:' +
        decodedResponse['data']['tasks']['Sequences'].toString());
    final allSequences = decodedResponse['data']['tasks']['Sequences'][0]
        as Map<String, dynamic>;

    //  Sequences;
    //  print(allSequences);
    //tasks
    // print(allTasks);

    tasks2ModelList = allTasks.map((e) => Tasks2Model.fromMap(e)).toList();
    sequence2model = Sequence2Model(
      sequenceName: allSequences['sequenceName'],
      jobId: allSequences['jobId'].toString(),
      jobName: allSequences['jobName'],
    );

    // print('Sequence2Model: ' + sequence2model.toString());

    //  print('All Tasks: ' + tasks2ModelList.toString());

    map = {
      'tasks2ModelList': allTasks,
      'sequence2model': sequence2model,
    };
  }

  return map;
}
