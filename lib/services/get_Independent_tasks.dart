// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class IndependentTaskModel {
  int? id;
  String? pmkNumber;
  String? heatNo;
  int? jobId;
  int? userId;
  int? estimatedHour;
  String? description;
  DateTime? startedAt;
  DateTime? completedAt;
  DateTime? approvedAt;
  String? approvedBy;
  String? status;
  String? image;
  String? comments;
  String? rejectionReason;
  String? projectManager;
  String? qCI;
  String? fitter;
  String? welder;
  String? painter;
  String? foreman;
  String? cOPQ;
  IndependentTaskModel({
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

  IndependentTaskModel copyWith({
    int? id,
    String? pmkNumber,
    String? heatNo,
    int? jobId,
    int? userId,
    int? estimatedHour,
    String? description,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? status,
    String? image,
    String? comments,
    String? rejectionReason,
    String? projectManager,
    String? qCI,
    String? fitter,
    String? welder,
    String? painter,
    String? foreman,
    String? cOPQ,
  }) {
    return IndependentTaskModel(
      id: id ?? this.id,
      pmkNumber: pmkNumber ?? this.pmkNumber,
      heatNo: heatNo ?? this.heatNo,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      estimatedHour: estimatedHour ?? this.estimatedHour,
      description: description ?? this.description,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      approvedAt: approvedAt ?? this.approvedAt,
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
      'startedAt': startedAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'approvedAt': approvedAt?.millisecondsSinceEpoch,
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

  factory IndependentTaskModel.fromMap(Map<String, dynamic> map) {
    return IndependentTaskModel(
      id: map['id'] != null ? map['id'] as int : null,
      pmkNumber: map['pmkNumber'] != null ? map['pmkNumber'] as String : null,
      heatNo: map['heatNo'] != null ? map['heatNo'] as String : null,
      jobId: map['jobId'] != null ? map['jobId'] as int : null,
      userId: map['userId'] != null ? map['userId'] as int : null,
      estimatedHour:
          map['estimatedHour'] != null ? map['estimatedHour'] as int : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      startedAt: map['startedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startedAt'] as int)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
      approvedAt: map['approvedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['approvedAt'] as int)
          : null,
      approvedBy:
          map['approvedBy'] != null ? map['approvedBy'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      comments: map['comments'] != null ? map['comments'] as String : null,
      rejectionReason: map['rejectionReason'] != null
          ? map['rejectionReason'] as String
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

  factory IndependentTaskModel.fromJson(String source) =>
      IndependentTaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'IndependentTaskModel(id: $id, pmkNumber: $pmkNumber, heatNo: $heatNo, jobId: $jobId, userId: $userId, estimatedHour: $estimatedHour, description: $description, startedAt: $startedAt, completedAt: $completedAt, approvedAt: $approvedAt, approvedBy: $approvedBy, status: $status, image: $image, comments: $comments, rejectionReason: $rejectionReason, projectManager: $projectManager, qCI: $qCI, fitter: $fitter, welder: $welder, painter: $painter, foreman: $foreman, cOPQ: $cOPQ)';
  }

  @override
  bool operator ==(covariant IndependentTaskModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.pmkNumber == pmkNumber &&
        other.heatNo == heatNo &&
        other.jobId == jobId &&
        other.userId == userId &&
        other.estimatedHour == estimatedHour &&
        other.description == description &&
        other.startedAt == startedAt &&
        other.completedAt == completedAt &&
        other.approvedAt == approvedAt &&
        other.approvedBy == approvedBy &&
        other.status == status &&
        other.image == image &&
        other.comments == comments &&
        other.rejectionReason == rejectionReason &&
        other.projectManager == projectManager &&
        other.qCI == qCI &&
        other.fitter == fitter &&
        other.welder == welder &&
        other.painter == painter &&
        other.foreman == foreman &&
        other.cOPQ == cOPQ;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        pmkNumber.hashCode ^
        heatNo.hashCode ^
        jobId.hashCode ^
        userId.hashCode ^
        estimatedHour.hashCode ^
        description.hashCode ^
        startedAt.hashCode ^
        completedAt.hashCode ^
        approvedAt.hashCode ^
        approvedBy.hashCode ^
        status.hashCode ^
        image.hashCode ^
        comments.hashCode ^
        rejectionReason.hashCode ^
        projectManager.hashCode ^
        qCI.hashCode ^
        fitter.hashCode ^
        welder.hashCode ^
        painter.hashCode ^
        foreman.hashCode ^
        cOPQ.hashCode;
  }
}

Future<List<IndependentTaskModel>> getIndependentTasks(
    {required String jobID}) async {
  List<IndependentTaskModel> list = [];
  // final response = await http
  //     .get(Uri.parse('http://192.168.100.4:3000/allSequencesWithTasks'));

  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');

  final response = await http.get(
      Uri.parse('$BASE_URL/sequencestask/indenpendent-task/$jobID'),
      headers: {
        'Authorization': 'Bearer $token',
      });

  // print(response.body);

  if (response.statusCode == 200) {
    // list = jsonDecode(response.body['data']);
    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
    // print(decodedResponse['data']);

    //list = decodedResponse['data'];
    final dataList = decodedResponse['data'] as List<dynamic>;

    list = dataList.map((e) => IndependentTaskModel.fromMap(e)).toList();

    print('final list: ' + list.toString());
  } else {
    final decodedResponseMessage =
        jsonDecode(response.body) as Map<String, dynamic>;
    final msg = decodedResponseMessage['message'];
    throw msg;
  }

  return list;
}
